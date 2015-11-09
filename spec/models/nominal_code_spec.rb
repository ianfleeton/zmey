require 'rails_helper'

RSpec.describe NominalCode, type: :model do
  it { should have_many(:purchase_products).class_name('Product').with_foreign_key('purchase_nominal_code_id') }
  it { should have_many(:sales_products).class_name('Product').with_foreign_key('sales_nominal_code_id') }

  context 'uniqueness' do
    before { FactoryGirl.create(:nominal_code) }
    it { should validate_uniqueness_of(:code).case_insensitive }
  end
end
