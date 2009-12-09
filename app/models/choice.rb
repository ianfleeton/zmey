class Choice < ActiveRecord::Base
  belongs_to :feature
  validates_uniqueness_of :name, :scope => :feature_id
end
