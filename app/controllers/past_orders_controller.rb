class PastOrdersController < OrdersRelatedController
  
  before_filter :order_with_items_from_id, :except => [:index]
  before_filter :only_if_staff_or_admin
  
  def index
    @page = params[:page]
    @orders = @shop.orders.state_eq_any('made', 'delivered', 'cancelled').paginate(:per_page=>20, :page=>@page)
  end

  def show
  end
  
end
