class PermutationsController < ApplicationController
  layout 'admin'
  before_filter :admin_or_manager_required

  def update
    permutation = Permutation.find(params[:id])
    if permutation
      if permutation.update_attributes(permutation_params)
        redirect_to edit_component_path(permutation.component), notice: 'Updated'
      else
        redirect_to edit_component_path(permutation.component), notice: 'Could not update'
      end
    else
      redirect_to products_path, notice: 'Permutation not found'
    end
  end

  private

    def permutation_params
      params.require(:permutation).permit(:component_id, :permutation, :price, :valid_selection, :weight)
    end
end
