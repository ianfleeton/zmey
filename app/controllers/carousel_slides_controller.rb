class CarouselSlidesController < ApplicationController
  layout 'admin'
  before_filter :admin_or_manager_required
  before_filter :find_carousel_slide, only: [:edit, :update, :destroy]

  def index
    @carousel_slides = @w.carousel_slides
  end

  def new
    @carousel_slide = CarouselSlide.new
  end

  def edit
  end

  def create
    @carousel_slide = CarouselSlide.new(params[:carousel_slide])
    @carousel_slide.website_id = @w.id

    if @carousel_slide.save
      redirect_to carousel_slides_path, notice: 'Successfully added new carousel slide.'
    else
      render action: 'new'
    end
  end

  def update
    if @carousel_slide.update_attributes(params[:carousel_slide])
      redirect_to carousel_slides_path, notice: 'Carousel slide successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @carousel_slide.destroy
    redirect_to carousel_slides_path, notice: 'Carousel slide deleted.'
  end

  protected

  def find_carousel_slide
    @carousel_slide = CarouselSlide.find_by_id_and_website_id(params[:id], @w.id)
    not_found unless @carousel_slide
  end
end
