class Admin::ComponentsController < Admin::AdminController
  before_action :set_component, only: [:edit, :destroy, :update]

  def new
    @component = Component.new
    @component.product_id = params[:product_id]
    redirect_to admin_products_path and return unless product_valid?
  end

  def create
    @component = Component.new(component_params)
    redirect_to admin_products_path and return unless product_valid?

    if @component.save
      flash[:notice] = "Successfully added new component."
      redirect_to edit_admin_product_path(@component.product)
    else
      render :new
    end
  end

  def update
    if @component.update_attributes(component_params)
      flash[:notice] = "Component successfully updated."
      redirect_to edit_admin_product_path(@component.product)
    else
      render :edit
    end
  end

  def edit
    @features = @component.features.sort {|a,b| b.choices.count <=> a.choices.count}

    num_permutations = 1
    @choice_array = []
    f_index = 0

    @headings = []

    @rows = []

    @features.each do |feature|
      @headings = @headings.unshift(feature.name)
      choices = feature.choices
      num_permutations *= choices.count
      @choice_array[f_index] = []

      choices.each {|choice| @choice_array[f_index] << choice.id}
      f_index += 1
    end

    (0...num_permutations).each do |c_index|
      permutation_array = []
      change = 1
      @rows[c_index] = {}
      @rows[c_index][:choices] = []
      (0...@choice_array.count).each do |f_index|
        permutation_array[f_index] = @choice_array[f_index][(c_index / change) % @choice_array[f_index].count]
        @rows[c_index][:choices] = @rows[c_index][:choices].unshift(Choice.find(permutation_array[f_index]).name)
        change *= @choice_array[f_index].count
      end

      permutation_array.sort!
      string = ''
      (0...permutation_array.count).each {|i| string += "_#{permutation_array[i]}_"}
      @rows[c_index][:permutation] = Permutation.find_by(permutation: string)
    end
  end

  def destroy
    @component.destroy
    flash[:notice] = I18n.t('components.destroy.deleted')
    redirect_to edit_admin_product_path(@component.product)
  end

  private

    def set_component
      @component = Component.find(params[:id])
      redirect_to admin_products_path and return unless product_valid?
    end

    def product_valid?
      if Product.find_by(id: @component.product_id)
        true
      else
        flash[:notice] = 'Invalid product.'
        false
      end
    end

    def component_params
      params.require(:component).permit(:name, :product_id)
    end
end
