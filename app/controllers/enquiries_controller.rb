class EnquiriesController < ApplicationController
  include SpamProtection

  def new
    @title = 'Enquiry'
    @enquiry = Enquiry.new
    unless @current_user.nil?
      @enquiry.name = @current_user.name
      @enquiry.email = @current_user.email
    end
    @enquiry.enquiry = params[:enquiry] unless params[:enquiry].nil?
  end

  def create
    @title = 'Enquiry'
    @enquiry = Enquiry.new(enquiry_params)
    
    unless good_token?
      render action: 'new', layout: 'application'
      return
    end
    
    @enquiry.website = website

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

  private

    def enquiry_params
      params.require(:enquiry).permit(:address, :call_back, :country, :email, :enquiry, :fax, :hear_about, :name, :organisation, :postcode, :telephone)
    end
end
