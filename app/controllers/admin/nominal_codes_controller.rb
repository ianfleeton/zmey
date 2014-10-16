class Admin::NominalCodesController < Admin::AdminController
  before_action :set_nominal_code, only: [:edit, :destroy, :update]

  def index
    @nominal_codes = website.nominal_codes
  end

  def new
    @nominal_code = NominalCode.new
  end

  def create
    @nominal_code = NominalCode.new(nominal_code_params)
    @nominal_code.website = website

    if @nominal_code.save
      flash[:notice] = 'Nominal code added.'
      redirect_to admin_nominal_codes_path
    else
      render :new
    end
  end

  def update
    if @nominal_code.update_attributes(nominal_code_params)
      flash[:notice] = 'Nominal code updated.'
      redirect_to admin_nominal_codes_path
    else
      render :edit
    end
  end

  def edit
  end

  def destroy
    @nominal_code.destroy
    flash[:notice] = 'Nominal code deleted.'
    redirect_to admin_nominal_codes_path
  end

  private

    def set_nominal_code
      @nominal_code = NominalCode.find_by(id: params[:id], website_id: website.id)
      redirect_to admin_nominal_codes_path and return unless @nominal_code
    end

    def nominal_code_params
      params.require(:nominal_code).permit(:code, :description)
    end
end
