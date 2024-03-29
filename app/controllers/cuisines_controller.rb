require 'stringio'

class CuisinesController < ApplicationController

  before_filter :require_login
  before_filter :require_admin_rights


  def index
    @cuisines = Cuisine.is_not_franchise.all
    @franchises = Cuisine.is_franchise.all
  end
  
  def show
    @cuisine = Cuisine.find(params[:id])
  end
  
  def new
    @cuisine = Cuisine.new
  end
  
  def create
    @cuisine = Cuisine.new(params[:cuisine])
    if @cuisine.save
      redirect_to cuisines_path
    else
      render :action => 'new'
    end
  end
  
  def edit
    @cuisine = Cuisine.find(params[:id])
  end
  
  def update
    @cuisine = Cuisine.find(params[:id])
    if @cuisine.update_attributes(params[:cuisine])
      redirect_to cuisines_path
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @cuisine = Cuisine.find(params[:id])
    @cuisine.destroy
    redirect_to cuisines_url
  end      
  
  
  def import_form
  end


  def import  
    data = params[:data]
    franchise = params[:type] == 'franchise'
    StringIO.open(data, 'r') do |io|
      io.each_line do |line|
        Cuisine.find_or_create_by_name(:name=>line, :franchise=>franchise)
      end
    end
    redirect_to cuisines_path
  end
  
end
