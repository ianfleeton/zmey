class WebsitesController < ApplicationController
  before_filter :admin_required
  before_filter :find_website, :only => [:edit, :update, :destroy]
  
  def index
    @websites = Website.find(:all, :order => :name)
  end
  
  def new
    @website = Website.new
  end
  
  def edit
  end
  
  def create
    @website = Website.new(params[:website])

    if @website.save
      Page.bootstrap @website

      create_latest_news
      
      flash[:notice] = "Successfully added new website."
      redirect_to :action => "index"
    else
      render :action => "new"
    end
  end

  def update
    if @website.update_attributes(params[:website])
      flash[:notice] = 'Website saved.'
      redirect_to websites_path
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @website.destroy
    flash[:notice] = "Website deleted."
    redirect_to :action => "index"
  end
  
  protected
  
  def find_website
    @website = Website.find(params[:id])
  end

  def create_latest_news
    # create latest news forum and link it as the website's blog
    latest_news = Forum.new
    latest_news.name = 'Latest News'
    latest_news.website_id = @website.id
    latest_news.locked = true
    latest_news.save
    @website.blog_id = latest_news.id
    @website.save
    
    # create a vapid placeholder topic to introduce the new website
    topic = Topic.new
    topic.topic = 'New Website Launched'
    topic.posts_count = 1
    topic.forum_id = latest_news.id
    topic.views = 1
    topic.last_post_at = Time.now
    topic.save

    post = Post.new
    post.topic_id = topic.id
    post.content = 'The new website for ' + @website.name +
      'is now complete. We hope you find it useful and easy to use.'
    post.email = @website.email
    post.author = @website.name
    post.save
    
    topic.last_post_id = post.id
    topic.last_post_author = post.author
    topic.last_post_at = post.created_at
    topic.save
  end
end
