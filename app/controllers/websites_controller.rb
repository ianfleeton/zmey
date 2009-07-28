class WebsitesController < ApplicationController
  def index
    @websites = Website.find(:all)
  end
  
  def new
    @website = Website.new
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
end
