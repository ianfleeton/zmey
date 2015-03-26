class NominalCode < ActiveRecord::Base
  validates_uniqueness_of :code
  validates_presence_of :code, :description

  has_many :products, -> { order 'name' }, dependent: :nullify

  default_scope { order(:code) }

  def to_s
    "#{code} #{description}"
  end
end
