require 'spec_helper'

describe Product do
  before(:each) do
    @product = Product.new(:price => 1.0)
  end

  describe "tax" do
    it "should be added and tax amount calculated when price is ex-VAT" do
      @product.tax_type = Product::EX_VAT
      @product.price_inc_tax.should == 1.175
      @product.price_ex_tax.should == 1.0
      @product.tax_amount.should == 0.175
    end

    it "should not be added but tax amount is calculated when price is inc-VAT" do
      @product.tax_type = Product::INC_VAT
      @product.price_inc_tax.should == 1.0
      @product.price_ex_tax.should be_close(0.8511, 0.001)
      @product.tax_amount.should be_close(0.1489, 0.001)
    end

    it "should not be added nor calculated when product has no tax" do
      @product.tax_type = Product::NO_TAX
      @product.price_inc_tax.should == 1.0
      @product.price_ex_tax.should == 1.0
      @product.tax_amount.should == 0
    end
  end
end
