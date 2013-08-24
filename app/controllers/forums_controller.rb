class ForumsController < ApplicationController
  before_action :find_forum, only: [:show, :feed]
  before_action :admin_required, only: [:new, :edit, :create, :update, :destroy]

  def index
    @forums = @w.forums
  end

  def show
    @title = 'Recent Topics'
    @topics = Topic.find(:all, conditions: {forum_id: @forum.id}, order: 'last_post_at DESC')
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
      render action: 'new'
    end
  end

  def feed
    respond_to do |format| 
      format.xml { render layout: false } 
    end 
  end

  protected
  
  def find_forum
    @forum = Forum.find(params[:id])
    not_found if @forum.website_id != @w.id
  end

  def forum_params
    params.require(:forum).permit(:name)
  end
end
