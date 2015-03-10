class TopicsController < ApplicationController
  include SpamProtection
  before_action :admin_required, only: [:destroy, :destroy_post]

  def new
    @title = 'New Topic - Forum'
    @forum = Forum.find(params[:forum_id])
    @topic = Topic.new
    @topic.forum_id = @forum.id
    @topic.topic = ""
    @post = Post.new
    if admin?
      @post.author = website.name
      @post.email = website.email
    end
  end

  def create_reply
    @topic = Topic.find(params[:post][:topic_id])

    @post = Post.new(post_params)
    @post.topic = @topic

    unless good_token?
      render action: 'show', id: @topic
      return
    end

    if @post.save
      update_topic_with_post @post
      flash[:notice] = "Your reply has been posted"
      redirect_to action: 'show', id: @topic
    else
      if params[:post][:topic_id].nil?
        @topic.destroy!
        render :new
      else
        @posts = Post.find_all_by_topic_id(@topic.id, order: 'updated_at ASC')
        render action: 'show', id: @topic
      end
    end
  end

  def create
    @topic = Topic.new
    @topic.topic = params[:topic]
    @topic.forum_id = params[:forum_id]
    @post = Post.new(post_params)

    @forum = Forum.find(params[:forum_id])

    render :new and return unless good_token?

    @topic.last_post_at = Time.now
    @topic.save

    @post.topic_id = @topic.id

    if @post.save
      update_topic_with_post @post
      flash[:notice] = "Your new topic has been posted"
      redirect_to action: 'show', id: @topic
    else
      @topic.destroy

      render :new
    end
  end

  def show
    @topic = Topic.eager_load(:posts).find(params[:id])
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
    redirect_to @topic.forum
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
      redirect_to action: 'show', id: @topic.id
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

  def post_params
    params.require(:post).permit(:author, :content, :email)
  end
end
