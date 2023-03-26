class Permutation < ApplicationRecord
  belongs_to :component

  def to_s
    permutation
  end
end
