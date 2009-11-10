class OperatingTimesController < ApplicationController

  def new
    @shop = Shop.find(params[:shop_id])
    @operating_time = @shop.operating_times.build
  end
  
  def create
    @shop = Shop.find(params[:shop_id])
    @operating_time = @shop.operating_times.build(params[:operating_time])
    if @operating_time.save
      flash[:notice] = "Successfully created operating times."
      redirect_to edit_shop_path(@shop)
    else
      render :action => 'new'
    end
  end
  
  def edit
    @operating_time = OperatingTime.find(params[:id])
  end
  
  def update
    @operating_time = OperatingTime.find(params[:id])
    if @operating_time.update_attributes(params[:operating_time])
      flash[:notice] = "Successfully updated operating times."
      redirect_to edit_shop_path(@shop)
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @operating_time = OperatingTime.find(params[:id])
    @operating_time.destroy
    flash[:notice] = "Successfully destroyed operating times."
    redirect_to edit_shop_path(@shop)
  end
end
