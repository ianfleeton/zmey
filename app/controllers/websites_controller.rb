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
      # create home page
      @home_page = Page.create(
        :title => @website.name,
        :name => 'Home',
        :keywords => 'change me',
        :description => 'change me',
        :content => 'Welcome to ' + @website.name
      ) {|hp| hp.website_id = @website}
      
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
