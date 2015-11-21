class Permutation < ActiveRecord::Base
  belongs_to :component

  def to_s
    permutation
  end
end
