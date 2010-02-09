class UserSessionsController < ApplicationController 
  def new
    @user_session = UserSession.new
    @user_session.errors.clear
    @user_session.remember_me = true
    flash[:email] and @user_session.email = flash[:email]
    respond_to do |format|
        format.iphone do 
          render :layout => false
        end
        format.html
    end
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    respond_to do |format|
      format.iphone do
        if @user_session.save
          render :json=>@user_session.user.name.to_json
        else
          render :json=>false.to_json
        end
      end
      format.html do
        if @user_session.save
          if user = @user_session.user
            user.add_favourite(@shop.id) if @shop
            if @order and @order.mine?(nil, session[:order_token])
              @order.user = user
              @order.save
            end            
          end
          if @order
            redirect_to @order
          elsif @shop
            redirect_to @shop 
          else
            redirect_to root_path
          end
        else
          render :action => :new
        end
      end
    end
  end

  def destroy
    current_user_session.andand.destroy
    redirect_to root_path
  end
  
  def not_me
    current_user_session.andand.destroy
    redirect_to login_path
  end
  
  
end