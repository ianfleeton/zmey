class ImagesController < ApplicationController
  before_filter :require_website

  def index
    @images = Image.find(:all, :conditions => { :website_id => @w })
  end

  def new
    @image = Image.new
  end

  def create
    @image = Image.new(params[:image])
    # TODO: change to admin's website ID
    @image.website_id = @w
    
    if @image.save
      flash[:notice] = 'Image uploaded.'
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end

  def edit
    @image = Image.find(params[:id])
  end

  def update
    @image = Image.find(params[:id])

    if @image.update_attributes(params[:image])
      flash[:notice] = 'Image saved.'
      redirect_to :action => 'index'
    else
      render :action => 'edit'
    end
  end

  def destroy
    @image = Image.find(params[:id])
    @image.destroy
    flash[:notice] = 'Image deleted.'
    redirect_to :action => 'index'
  end
end