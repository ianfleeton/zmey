class Country < ActiveRecord::Base
  validates_presence_of :name
  validates_length_of :iso_3166_1_alpha_2, :is => 2

  belongs_to :website
end
