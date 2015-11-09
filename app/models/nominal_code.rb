class NominalCode < ActiveRecord::Base
  validates_uniqueness_of :code, case_sensitive: false
  validates_presence_of :code, :description

  has_many :purchase_products, class_name: 'Product', foreign_key: 'purchase_nominal_code_id', dependent: :nullify
  has_many :sales_products, class_name: 'Product', foreign_key: 'sales_nominal_code_id', dependent: :nullify

  default_scope { order(:code) }

  def to_s
    "#{code} #{description}"
  end
end
