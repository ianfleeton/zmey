class Admin::CarouselSlidesController < ApplicationController
  layout 'admin'
  before_action :admin_or_manager_required
  before_action :find_carousel_slide, only: [:edit, :update, :destroy, :move_up, :move_down]

  def index
    @carousel_slides = @w.carousel_slides
  end

  def new
    @carousel_slide = CarouselSlide.new(active_until: DateTime.now + 5.years)
  end

  def edit
  end

  def create
    @carousel_slide = CarouselSlide.new(carousel_slide_params)
    @carousel_slide.website_id = @w.id

    if @carousel_slide.save
      redirect_to admin_carousel_slides_path, notice: 'Successfully added new carousel slide.'
    else
      render :new
    end
  end

  def update
    if @carousel_slide.update_attributes(carousel_slide_params)
      redirect_to admin_carousel_slides_path, notice: 'Carousel slide successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @carousel_slide.destroy
    redirect_to admin_carousel_slides_path, notice: 'Carousel slide deleted.'
  end

  def move_up
    @carousel_slide.move_higher
    moved
  end
  
  def move_down
    @carousel_slide.move_lower
    moved
  end

  private

    def find_carousel_slide
      @carousel_slide = CarouselSlide.find_by(id: params[:id], website_id: @w.id)
      not_found unless @carousel_slide
    end

    def carousel_slide_params
      params.require(:carousel_slide).permit(:active_from, :active_until, :caption, :image_id, :link, :position)
    end

    def moved
      flash[:notice] = 'Moved'
      redirect_to action: 'index'
    end
end
