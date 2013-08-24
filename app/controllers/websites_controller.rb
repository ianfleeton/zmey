class WebsitesController < ApplicationController
  layout 'admin'
  before_action :admin_required, :except => [:edit, :update]
  before_action :find_website, :only => [:edit, :update, :destroy]
  before_action :permission_check, :only => [:edit, :update]

  def index
    @websites = Website.order('name')
  end
  
  def new
    @website = Website.new
  end
  
  def edit
  end
  
  def create
    @website = Website.new(website_params)

    if @website.save
      @website.populate_countries!
      Page.bootstrap @website

      create_latest_news
      
      flash[:notice] = "Successfully added new website."
      redirect_to action: 'index'
    else
      render action: 'new'
    end
  end

  def update
    if @website.update_attributes(website_params)
      flash[:notice] = 'Website saved.'
      redirect_to edit_website_path(@website)
    else
      render action: 'edit'
    end
  end
  
  def destroy
    @website.destroy
    flash[:notice] = "Website deleted."
    redirect_to action: 'index'
  end
  
  protected

  def permission_check
    admin_or_manager_required
    return if admin?
    if manager? && @w.id != @website.id
      flash[:notice] = 'You do not manage this website.'
      redirect_to controller: 'sessions', action: 'new'
    end
  end

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
      ' is now complete. We hope you find it useful and easy to use.'
    post.email = @website.email
    post.author = @website.name
    post.save
    
    topic.last_post_id = post.id
    topic.last_post_author = post.author
    topic.last_post_at = post.created_at
    topic.save
  end

  def website_params
    params.require(:website).permit(:blog_id, :can_users_create_accounts, :cardsave_active,
      :cardsave_merchant_id, :cardsave_password, :cardsave_pre_shared_key,
      :css_url, :default_locale, :domain, :email, :footer_html,
      :google_analytics_code, :google_domain_name, :google_ftp_password,
      :google_ftp_username, :invoice_details, :name, :page_image_size,
      :page_thumbnail_size, :paypal_active, :paypal_email_address,
      :paypal_identity_token, :private, :product_image_size,
      :product_thumbnail_size, :worldpay_active, :worldpay_installation_id,
      :worldpay_payment_response_password, :worldpay_test_mode, :shipping_amount,
      :shop, :show_vat_inclusive_prices, :skip_payment, :subdomain,
      :terms_and_conditions, :use_default_css, :vat_number)
  end
end
