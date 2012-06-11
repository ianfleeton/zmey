class PermutationsController < ApplicationController
  layout 'admin'
  before_filter :admin_or_manager_required

  def update
    permutation = Permutation.find(params[:id])
    if permutation
      if permutation.update_attributes(params[:permutation])
        redirect_to edit_component_path(permutation.component), notice: 'Updated'
      else
        redirect_to edit_component_path(permutation.component), notice: 'Could not update'
      end
    else
      redirect_to products_path, notice: 'Permutation not found'
    end
  end
end
