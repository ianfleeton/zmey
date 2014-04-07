class Admin::EnquiriesController < Admin::AdminController
  before_action :set_enquiry, except: [:index]

  def index
    @enquiries = website.enquiries
  end

  def show
  end

  def edit
  end

  def update
    if @enquiry.update_attributes(enquiry_params)
      redirect_to([:admin, @enquiry], notice: 'Enquiry was successfully updated.')
    else
      render :edit
    end
  end

  def destroy
    @enquiry.destroy
    redirect_to(admin_enquiries_path)
  end

  private

    def set_enquiry
      @enquiry = Enquiry.find_by(id: params[:id], website_id: website.id)
      not_found unless @enquiry
    end

    def enquiry_params
      params.require(:enquiry).permit(:address, :call_back, :country, :email, :enquiry, :fax, :hear_about, :name, :organisation, :postcode, :telephone)
    end
end
