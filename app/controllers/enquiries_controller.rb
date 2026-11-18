class EnquiriesController < ApplicationController
  include FormRateLimiting

  limit_submissions only: :create, to: 5, within: 15.minutes

  def new
    @title = "Enquiry"
    @enquiry = Enquiry.new
    unless @current_user.nil?
      @enquiry.name = @current_user.name
      @enquiry.email = @current_user.email
    end
    @enquiry.enquiry = params[:enquiry] unless params[:enquiry].nil?
  end

  def create
    @title = "Enquiry"
    @enquiry = Enquiry.new(enquiry_params)

    # Pretend a bot's submission succeeded so it doesn't try again.
    if params[:contact_me_by_fax_only].present?
      redirect_to(action: "thank_you")
      return
    end

    if @enquiry.save
      EnquiryNotifier.enquiry(website, @enquiry).deliver_later
      redirect_to(action: "thank_you")
    else
      render action: "new", layout: "application"
    end
  end

  def thank_you
    @title = "Thank you for your enquiry"
    render layout: "application"
  end

  private

  def enquiry_params
    params.require(:enquiry).permit(:address, :call_back, :country, :email, :enquiry, :hear_about, :name, :organisation, :postcode, :telephone)
  end
end
