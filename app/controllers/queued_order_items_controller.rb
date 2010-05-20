class QueuedOrderItemsController < ApplicationController

    before_filter :require_login
    before_filter :get_instance, :except=>[:make_all]
    before_filter :only_if_can_access_queue, :except=>[:make_all]


    def show
      respond_to do |format|
        format.json {
          render :json=>@order_item.to_json(
            :only=>[:id, :quantity, :description],
            :methods=>[:cost]
          )
        }
      end
    end
    
    def make
      @order_item.make!
      case params[:fragment]
      when 'order': render :partial=>'orders/order', :object=>@order_item.order
      else
        respond_to do |format|
          # format.mobile {redirect_to order_path(@order_item.order)}
          # format.html {redirect_back_or_default}
          format.json {render :json=>true.to_json}
        end
      end
    end    

    def make_all
      @order_items = OrderItem.id_eq_any(params[:order_item_ids])
      return unauthorized unless (@order_items.all? {|oi| current_user.can_access_queues_of?(oi.shop)})
      @order_items.each do |order_item|
        order_item.make!
      end
      respond_to do |format|
        # send back the whole order
        format.json do
          unless @order_items.empty?
            @order = @order_items.first.order
            json = @order.to_json(
              :only=>[:id, :notes, :name, :state],
              :methods=>[:grand_total_with_fees, :summary, :summarized_order_items, :effective_name, :queued_at_utc, :reputation_s,
                :deliver,
                :address,
                :phone,
                :effective_delivery_fee
                ]
            )
            render :json=>json
          else
            render :nothing
          end
        end
      end
    end
    
    
  private

    def only_if_can_access_queue
      unauthorized unless current_user and @order_item and
                  current_user.can_access_queues_of?(@order_item.shop)
    end

    def get_instance
      @order_item = OrderItem.find(params[:id], :include=>[:order, :shop])
    end

end
