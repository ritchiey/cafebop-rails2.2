class MenuTemplatesController < ApplicationController
  def index
    @menu_templates = MenuTemplate.all
  end
  
  def show
    @menu_template = MenuTemplate.find(params[:id])
  end
  
  def new
    @menu_template = MenuTemplate.new
  end
  
  def create
    @menu_template = MenuTemplate.new(params[:menu_template])
    if @menu_template.save
      flash[:notice] = "Successfully created menu template."
      redirect_to @menu_template
    else
      render :action => 'new'
    end
  end
  
  def edit
    @menu_template = MenuTemplate.find(params[:id])
  end
  
  def update
    @menu_template = MenuTemplate.find(params[:id])
    if @menu_template.update_attributes(params[:menu_template])
      flash[:notice] = "Successfully updated menu template."
      redirect_to @menu_template
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @menu_template = MenuTemplate.find(params[:id])
    @menu_template.destroy
    flash[:notice] = "Successfully destroyed menu template."
    redirect_to menu_templates_url
  end
end
