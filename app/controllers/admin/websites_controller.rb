module Admin
  class WebsitesController < Admin::AdminController
    before_action :admin_required
    before_action :find_website_subject, only: [:edit, :update, :destroy]

    def index
      @websites = Website.order("name")
    end

    def new
      Country.populate!
      @website_subject = Website.new
    end

    def edit
    end

    def create
      @website_subject = Website.new(website_params)

      if @website_subject.save
        Page.bootstrap @website_subject

        flash[:notice] = "Successfully added new website."
        redirect_to action: "index"
      else
        render :new
      end
    end

    def update
      if @website_subject.update(website_params)
        flash[:notice] = "Website saved."
        redirect_to edit_admin_website_path(@website_subject)
      else
        render :edit
      end
    end

    def destroy
      @website_subject.destroy
      flash[:notice] = "Website deleted."
      redirect_to action: "index"
    end

    protected

    def find_website_subject
      @website_subject = Website.find(params[:id])
    end

    def website_params
      params.require(:website).permit(:address_line_1, :address_line_2,
        :can_users_create_accounts, :cardsave_active,
        :cardsave_merchant_id, :cardsave_password, :cardsave_pre_shared_key,
        :country_id, :county,
        :css_url, :default_locale, :default_shipping_class_id, :domain, :email, :fax_number,
        :google_analytics_code, :google_domain_name, :google_ftp_password,
        :google_ftp_username, :invoice_details,
        :mandrill_subaccount,
        :name, :page_image_size,
        :page_thumbnail_size,
        :paypal_active, :paypal_email_address,
        :paypal_identity_token, :paypal_test_mode,
        :phone_number, :port, :postcode, :private,
        :product_image_size,
        :product_thumbnail_size,
        :sage_pay_active, :sage_pay_pre_shared_key,
        :sage_pay_test_mode, :sage_pay_vendor,
        :smtp_active, :smtp_host, :smtp_password, :smtp_port, :smtp_username,
        :staging_password,
        :theme,
        :worldpay_active, :worldpay_installation_id,
        :worldpay_payment_response_password, :worldpay_test_mode,
        :scheme, :send_pending_payment_emails, :shipping_amount,
        :shopping_suspended, :shopping_suspended_message,
        :show_vat_inclusive_prices, :skip_payment, :skype_name,
        :subdomain,
        :terms_and_conditions, :town_city, :twitter_username,
        :vat_number,
        :yorkshire_payments_active,
        :yorkshire_payments_merchant_id,
        :yorkshire_payments_pre_shared_key)
    end
  end
end
