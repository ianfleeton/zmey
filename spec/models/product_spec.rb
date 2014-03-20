require 'spec_helper'

describe Product do
  before(:each) do
    @product = Product.new(:price => 1.0)
  end

  it { should ensure_inclusion_of(:gender).in_array(%w{female male unisex}) }

  describe "#name_with_sku" do
    it "returns the name followed by the SKU in square brackets" do
      @product.name = 'Banana'
      @product.sku = 'BAN'
      expect(@product.name_with_sku).to eq 'Banana [BAN]'
    end
  end

  describe "tax" do
    it "should be added and tax amount calculated when price is ex-VAT" do
      @product.tax_type = Product::EX_VAT
      expect(@product.price_inc_tax).to eq 1.2
      expect(@product.price_ex_tax).to eq 1.0
      expect(@product.tax_amount).to eq 0.2
    end

    it "should not be added but tax amount is calculated when price is inc-VAT" do
      @product.tax_type = Product::INC_VAT
      expect(@product.price_inc_tax).to eq 1.0
      expect(@product.price_ex_tax).to be_within(0.001).of(0.8333)
      expect(@product.tax_amount).to be_within(0.001).of(0.1667)
    end

    it "should not be added nor calculated when product has no tax" do
      @product.tax_type = Product::NO_TAX
      expect(@product.price_inc_tax).to eq 1.0
      expect(@product.price_ex_tax).to eq 1.0
      expect(@product.tax_amount).to eq 0
    end
  end

  describe '#reduced?' do
    it 'returns false if rrp is blank' do
      expect(@product.reduced?).to be_false
    end

    it 'returns true if price < rrp' do
      @product.price = 1.0
      @product.rrp = 1.5
      expect(@product.reduced?).to be_true
    end

    it 'returns false if price >= rrp' do
      @product.price = 1.5
      @product.rrp = 1.0
      expect(@product.reduced?).to be_false

      @product.price = 1.0
      expect(@product.reduced?).to be_false
    end
  end
end
