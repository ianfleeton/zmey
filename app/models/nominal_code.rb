class NominalCode < ActiveRecord::Base
  validates_uniqueness_of :code, scope: :website_id
  validates_presence_of :code, :description, :website_id

  belongs_to :website, inverse_of: :nominal_codes
end
