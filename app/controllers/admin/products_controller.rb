class Admin::ProductsController < Admin::AdminController
  before_action :set_product, only: [:edit, :update, :destroy]

  def index
    @products = website.products.paginate(page: params[:page], per_page: 250).order('name')
  end

  def new
    @product = Product.new
  end

  def edit
  end

  def create
    @product = Product.new(product_params)
    @product.website_id = website.id

    if @product.save
      flash[:notice] = "Successfully added new product."
      redirect_to action: 'new'
    else
      render :new
    end
  end

  def update
    if @product.update_attributes(product_params)
      flash[:notice] = 'Product saved.'
      redirect_to edit_admin_product_path(@product)
    else
      render :edit
    end
  end

  def destroy
    @product.destroy
    redirect_to admin_products_path, notice: 'Product deleted.'
  end

  def search
    @products = Product.admin_search(website.id, params[:query])
    render json: @products
  end

  def upload_google_data_feed
    google_data_feed
    @xml = render_to_string(action: 'google_data_feed.xml.erb', layout: false)
    open('google_data_feed.xml', 'wb') { |file| file.write(@xml) }

    begin
      require 'net/ftp'
      Net::FTP::open('uploads.google.com') do |ftp|
        ftp.login @w.google_ftp_username, @w.google_ftp_password
        ftp.passive = true
        ftp.put 'google_data_feed.xml'
      end
      flash[:notice] = 'Uploaded'
    rescue
      flash[:notice] = 'Could not upload'
    end
    system('rm google_data_feed.xml')

    render formats: [:html]
  end

  private

    def set_product
      @product = Product.find_by(id: params[:id], website_id: website.id)
      not_found unless @product
    end

    def product_params
      params.require(:product).permit(
        :active, :age_group,
        :apply_shipping, :availability, :brand, :condition, :description,
        :full_detail, :gender, :gtin, :google_product_category, :google_title, :image_id,
        :meta_description, :mpn, :name,
        :nominal_code_id,
        :page_title, :price, :product_type, :rrp,
        :shipping_supplement, :sku, :submit_to_google, :tax_type, :weight)
    end
end
