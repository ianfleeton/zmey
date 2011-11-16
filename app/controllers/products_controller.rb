class ProductsController < ApplicationController
  before_filter :find_product, :only => [:show, :edit, :update, :destroy]
  before_filter :admin_or_manager_required, :except => [:show, :google_data_feed]

  def index
    @products = Product.all(:conditions => {:website_id => @w.id}, :order => :name)
  end
  
  def show
    @title = @product.name + ' at ' + @w.name
  end
  
  def new
    @product = Product.new
  end
  
  def edit
  end
  
  def create
    @product = Product.new(params[:product])
    @product.website_id = @w.id

    if @product.save
      flash[:notice] = "Successfully added new product."
      redirect_to :action => "new"
    else
      render :action => "new"
    end
  end
  
  def update
    if @product.update_attributes(params[:product])
      flash[:notice] = 'Product saved.'
      redirect_to product_path(@product)
    else
      render :action => 'edit'
    end
  end

  def destroy
    @product.destroy
    flash[:notice] = "Product deleted."
    redirect_to products_path
  end

  def google_data_feed
    @products = @w.products_in_stock
  end

  def upload_google_data_feed
    google_data_feed
    @xml = render_to_string(:action => 'products/google_data_feed.xml.erb', :layout => false)
    open('google_data_feed.xml', 'wb') { |file| file.write(@xml) }

    require 'net/ftp'
    Net::FTP::open('uploads.google.com') do |ftp|
      ftp.login @w.google_ftp_username, @w.google_ftp_password
      ftp.passive = true
      ftp.put 'google_data_feed.xml'
    end
    system('rm google_data_feed.xml')

    flash[:notice] = 'Uploaded'
  end

  protected
  
  def find_product
    @product = Product.find_by_id_and_website_id(params[:id], @w.id)
    render :file => "#{::Rails.root.to_s}/public/404.html", :status => "404 Not Found" if @product.nil?
  end

end
