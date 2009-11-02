class TopicsController < ApplicationController
  include SpamProtection
  before_filter :admin_required, :only => [:destroy, :destroy_post]

  def new
    @title = 'New Topic - Forum'
    @forum = Forum.find(params[:forum_id])
    @topic = Topic.new
    @topic.forum_id = @forum.id
    @topic.topic = ""
    @post = Post.new
    if admin?
      @post.author = @w.name
      @post.email = @w.email
    end
  end
  
  def create_reply
    @topic = Topic.find(params[:post][:topic_id])

    @post = Post.new(params[:post])

    unless good_token?
      render :action => 'show', :id => @topic
      return
    end

    if @post.save
      update_topic_with_post @post
      flash[:notice] = "Your reply has been posted"
      redirect_to :action => 'show', :id => @topic
    else
      if params[:post][:topic_id].nil?
        @topic.destroy!
        render :action => "new"
      else
        @posts = Post.find_all_by_topic_id(@topic.id, :order => 'updated_at asc')
        render :action => "show", :id => @topic
      end
    end
  end
  
  def create
    @topic = Topic.new
    @topic.topic = params[:topic]

    unless good_token?
      render :action => 'new'
      return
    end
    
    # check forum
    @forum = Forum.find(params[:forum_id])
    if @forum.website_id != @w.id
      flash[:notice] = 'Invalid forum.'
      render :action => 'new' and return
    end
    
    @topic.forum_id = @forum.id
    @topic.last_post_at = Time.now
    @topic.save
    
    @post = Post.new(params[:post])
    @post.topic_id = @topic.id

    if @post.save
      update_topic_with_post @post
      flash[:notice] = "Your new topic has been posted"
      redirect_to :action => 'show', :id => @topic
    else
      @topic.destroy
      
      render :action => "new"
    end
  end

  def show
    @topic = Topic.find(params[:id], :include => :posts)
    @title = @topic.topic + ' - Forum'
    @topic.views += 1
    @topic.save

    # for creation of replies
    @post = Post.new
    @post.topic_id = @topic.id
  end
  
  def destroy
    @topic = Topic.find(params[:id])
    @topic.destroy
    flash[:notice] = "The topic and all its posts have been deleted."
    redirect_to :action => "index"
  end
  
  # destroys a post
  # destroys its topic if the post is the last in the topic
  def destroy_post
    @post = Post.find(params[:post_id])
    @topic = Topic.find(@post.topic_id)
    @post.destroy
    # destroy topic if last post is destroyed
    if @topic.posts.length == 0
      params[:id] = @topic.id
      destroy
      return
    else
      update_topic_with_post @topic.posts.last, -1
      flash[:notice] = 'Post deleted.'
      redirect_to :action => 'show', :id => @topic.id
    end
  end
  
  protected

  def update_topic_with_post p, adjust_post_count = 1
    @topic.last_post_id = p.id
    @topic.last_post_author = p.author
    @topic.last_post_at = p.updated_at
    @topic.posts_count += adjust_post_count
    @topic.save
  end
end
