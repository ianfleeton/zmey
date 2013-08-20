class EnquiriesController < ApplicationController
  include SpamProtection

  layout 'admin', except: [:new, :create, :thank_you, :current_time]
  before_filter :admin_or_manager_required, except: [:new, :create, :thank_you, :current_time]
  
  def index
    @enquiries = @w.enquiries
  end

  def show
    @enquiry = Enquiry.find(params[:id])
  end

  def new
    @title = 'Enquiry'
    @enquiry = Enquiry.new
    unless @current_user.nil?
      @enquiry.name = @current_user.name
      @enquiry.email = @current_user.email
    end
    @enquiry.enquiry = params[:enquiry] unless params[:enquiry].nil?
  end

  def edit
    @enquiry = Enquiry.find(params[:id])
  end

  def create
    @title = 'Enquiry'
    @enquiry = Enquiry.new(enquiry_params)
    
    unless good_token?
      render action: 'new', layout: 'application'
      return
    end
    
    @enquiry.website_id = @w.id

    if @enquiry.save
      EnquiryNotifier.enquiry(@w, @enquiry).deliver
      redirect_to(action: 'thank_you')
    else
      render action: 'new', layout: 'application'
    end
  end

  def thank_you
    @title = 'Thank you for your enquiry'
    render layout: 'application'
  end

  def update
    @enquiry = Enquiry.find(params[:id])

    if @enquiry.update_attributes(enquiry_params)
      redirect_to(@enquiry, notice: 'Enquiry was successfully updated.')
    else
      render action: 'edit'
    end
  end

  def destroy
    @enquiry = Enquiry.find(params[:id])
    @enquiry.destroy
    redirect_to(enquiries_url)
  end

  private

    def enquiry_params
      params.require(:enquiry).permit(:address, :call_back, :country, :email, :enquiry, :fax, :hear_about, :name, :organisation, :postcode, :telephone)
    end
end
