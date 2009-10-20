class WebsitesController < ApplicationController
  before_filter :admin_required
  before_filter :find_website, :only => [:edit, :update, :destroy]
  
  def index
    @websites = Website.find(:all, :order => :name)
  end
  
  def new
    @website = Website.new
  end
  
  def edit
  end
  
  def create
    @website = Website.new(params[:website])

    if @website.save
      Page.bootstrap @website
      
      flash[:notice] = "Successfully added new website."
      redirect_to :action => "index"
    else
      render :action => "new"
    end
  end

  def update
    if @website.update_attributes(params[:website])
      flash[:notice] = 'Website saved.'
      redirect_to websites_path
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @website.destroy
    flash[:notice] = "Website deleted."
    redirect_to :action => "index"
  end
  
  protected
  
  def find_website
    @website = Website.find(params[:id])
  end
end
