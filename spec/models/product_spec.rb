require 'rails_helper'

describe Product do
  before(:each) do
    @product = Product.new(price: 1.0)
  end

  it { should validate_inclusion_of(:age_group).in_array(Product::AGE_GROUPS) }
  it { should validate_inclusion_of(:gender).in_array(Product::GENDERS) }
  it { should validate_inclusion_of(:tax_type).in_array(Product::TAX_TYPES) }

  it { should ensure_length_of(:meta_description).is_at_most(255) }
  it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }

  describe 'image validations' do
    it 'allows an image to be absent' do
      product = FactoryGirl.build(:product, image_id: nil)
      expect(product.valid?).to be_truthy
    end

    it 'validates that given image exists' do
      product = FactoryGirl.build(:product)
      Image.destroy_all
      product.image_id = 1
      product.valid?
      expect(product.errors[:image]).to include "can't be blank"
    end

    it 'validates that image belongs to same website' do
      image = FactoryGirl.create(:image)
      product = FactoryGirl.build(:product, image_id: image.id)
      product.valid?
      expect(product.errors[:image]).to include I18n.t('activerecord.errors.models.product.attributes.image.invalid')
    end
  end

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
      expect(@product.reduced?).to be_falsey
    end

    it 'returns true if price < rrp' do
      @product.price = 1.0
      @product.rrp = 1.5
      expect(@product.reduced?).to be_truthy
    end

    it 'returns false if price >= rrp' do
      @product.price = 1.5
      @product.rrp = 1.0
      expect(@product.reduced?).to be_falsey

      @product.price = 1.0
      expect(@product.reduced?).to be_falsey
    end
  end
end
