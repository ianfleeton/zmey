class ForumsController < ApplicationController
  before_action :set_forum, only: [:show, :feed]
  before_action :admin_required, only: [:new, :edit, :create, :update, :destroy]

  def index
    @forums = @w.forums
  end

  def show
    @title = 'Recent Topics'
    @topics = @forum.topics.order('last_post_at DESC')
  end

  def new
    @forum = Forum.new
  end

  def create
    @forum = Forum.new(forum_params)
    @forum.website_id = @w.id

    if @forum.save
      flash[:notice] = "Successfully added new forum."
      redirect_to action: 'index'
    else
      render :new
    end
  end

  def feed
    respond_to do |format|
      format.xml { render layout: false }
    end
  end

  protected

    def set_forum
      @forum = Forum.find(params[:id])
    end

  def forum_params
    params.require(:forum).permit(:name)
  end
end
