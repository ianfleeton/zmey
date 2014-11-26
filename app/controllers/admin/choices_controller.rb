class Admin::ChoicesController < Admin::AdminController
  before_action :find_choice, except: [:new, :create]

  def new
    @choice = Choice.new
    @choice.feature_id = params[:feature_id]
    redirect_to admin_products_path and return unless feature_valid?
  end

  def edit
    @feature = @choice.feature
  end

  def update
    redirect_to products_path and return unless feature_valid?
    if @choice.update_attributes(choice_params)
      flash[:notice] = "Choice successfully updated."
      redirect_to edit_admin_feature_path(@choice.feature)
    else
      render :edit
    end
  end

  def create
    @choice = Choice.new(choice_params)
    redirect_to admin_products_path and return unless feature_valid?

    if @choice.save
      flash[:notice] = "Successfully added new choice."
      redirect_to edit_admin_feature_path(@choice.feature)
    else
      render :new
    end
  end

  def destroy
    redirect_to admin_products_path and return unless feature_valid?
    @choice.destroy
    flash[:notice] = "Choice deleted."
    redirect_to edit_admin_feature_path(@choice.feature)
  end

  protected

  def find_choice
    @choice = Choice.find(params[:id])
  end

  def feature_valid?
    @feature = Feature.find_by(id: @choice.feature_id)
    if @feature
      true
    else
      flash[:notice] = 'Invalid feature.'
      false
    end
  end

  def choice_params
    params.require(:choice).permit(:feature_id, :name)
  end
end
