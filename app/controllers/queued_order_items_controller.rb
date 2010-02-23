class QueuedOrderItemsController < ApplicationController

    before_filter :require_login
    before_filter :get_instance
    before_filter :only_if_can_access_queue

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
          # format.iphone {redirect_to order_path(@order_item.order)}
          # format.html {redirect_back_or_default}
          format.json {render :json=>true.to_json}
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
