class Permutation < ActiveRecord::Base
  attr_accessible :component_id, :permutation, :price, :valid_selection, :weight

  belongs_to :component
end
