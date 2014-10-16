class NominalCode < ActiveRecord::Base
  validates_uniqueness_of :code, scope: :website_id
  validates_presence_of :code, :description, :website_id

  belongs_to :website, inverse_of: :nominal_codes
  has_many :products, -> { order 'name' }, dependent: :nullify

  def to_s
    "#{code} #{description}"
  end
end
