class WebsitesController < ApplicationController
  def index
    @websites = Website.find(:all)
  end
  
  def new
    @website = Website.new
  end
  
  def edit
    @website = Website.find(params[:id])
  end
  
  def create
    @website = Website.new(params[:website])

    if @website.save
      flash[:notice] = "Successfully added new website."
      redirect_to :action => "index"
    else
      render :action => "new"
    end
  end

  def update
    @website = Website.find(params[:id])

    if @website.update_attributes(params[:website])
      flash[:notice] = 'Website saved.'
      redirect_to websites_path
    else
      render :action => 'edit'
    end
  end
end
