require 'rails_helper'

module PriceCalculator
  RSpec.describe Base do
    let(:product_price) { 123 }
    let(:tax_type) { Product::INC_VAT }
    let(:product) { Product.new(price: product_price, tax_type: tax_type) }

    subject { Base.new(product, tax_type) }
    it { should delegate_method(:ex_tax).to(:taxer) }
    it { should delegate_method(:inc_tax).to(:taxer) }
    it { should delegate_method(:with_tax).to(:taxer) }

    describe '#price' do
      it "returns the product's price" do
        base = Base.new(product, nil)
        expect(base.price).to eq product_price
      end
    end

    describe '#tax_type' do
      it "returns the product's tax_type" do
        base = Base.new(product, nil)
        expect(base.tax_type).to eq tax_type
      end
    end

    describe '#taxer' do
      subject { Base.new(product, nil).taxer }
      it { should be_kind_of(Taxer) }
    end
  end
end
