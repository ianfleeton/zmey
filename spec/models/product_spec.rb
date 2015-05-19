require 'rails_helper'
require_relative 'shared_examples/extra_attributes_shared.rb'

describe Product do
  before(:each) do
    @product = Product.new(price: 1.0)
  end

  it { should belong_to(:purchase_nominal_code).class_name('NominalCode') }
  it { should belong_to(:sales_nominal_code).class_name('NominalCode') }
  it { should have_many(:product_images).dependent(:delete_all) }
  it { should have_many(:images).through(:product_images) }

  it { should have_many(:order_lines).dependent(:nullify) }
  it 'really does nullify order lines' do
    @product = FactoryGirl.create(:product)
    @order_line = FactoryGirl.create(:order_line, product: @product)
    @product.destroy
    expect(@order_line.reload.product_id).to be_nil
  end

  it { should validate_inclusion_of(:age_group).in_array(Product::AGE_GROUPS) }
  it { should validate_inclusion_of(:gender).in_array(Product::GENDERS) }
  it { should validate_inclusion_of(:tax_type).in_array(Product::TAX_TYPES) }

  it { should validate_length_of(:meta_description).is_at_most(255) }
  it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }

  it { should have_many(:orders).through(:order_lines) }
  it { should have_many(:related_product_scores).dependent(:delete_all) }
  it { should have_many(:related_products).through(:related_product_scores) }

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
  end

  describe "#name_with_sku" do
    it "returns the name followed by the SKU in square brackets" do
      @product.name = 'Banana'
      @product.sku = 'BAN'
      expect(@product.name_with_sku).to eq 'Banana [BAN]'
    end
  end

  describe '#image_name' do
    it 'returns the name of the main image' do
      image = FactoryGirl.create(:image, name: 'product.jpg')
      product = Product.new(image: image)
      expect(product.image_name).to eq 'product.jpg'
    end

    it 'returns nil if main image unset' do
      product = Product.new
      expect(product.image_name).to be_nil
    end
  end

  describe '#image_name=' do
    it 'associates image with named image' do
      image = FactoryGirl.create(:image, name: 'product.jpg')
      product = Product.new
      product.image_name = 'product.jpg'
      expect(product.image).to eq image
    end
  end

  describe '#image_names' do
    let!(:image1) { FactoryGirl.create(:image, name: 'front.jpg') }
    let!(:image2) { FactoryGirl.create(:image, name: 'back.jpg') }
    let(:product) { Product.new }

    before do
      product.images << [image1, image2]
    end

    it 'returns image names delimited with the pipe character' do
      expect(product.image_names).to eq 'front.jpg|back.jpg'
    end
  end

  describe '#image_names=' do
    let!(:image1) { FactoryGirl.create(:image, name: 'front.jpg') }
    let!(:image2) { FactoryGirl.create(:image, name: 'back.jpg') }
    let(:product) { Product.new }

    it 'associates multiple named images from a pipe separated string' do
      product.image_names = 'front.jpg|back.jpg'
      expect(product.images).to include(image1)
      expect(product.images).to include(image2)
    end

    it 'associates multiple named images from an array' do
      product.image_names = ['front.jpg', 'back.jpg']
      expect(product.images).to include(image1)
      expect(product.images).to include(image2)
    end

    it 'removes existing images' do
      product.image_names = image1.name
      product.image_names = image2.name
      expect(product.images).to include(image2)
      expect(product.images).not_to include(image1)
    end
  end

  shared_examples_for 'a nominal code setter' do |code_type|
    let(:getter) { "#{code_type}_nominal_code".to_sym }
    let(:setter) { "#{code_type}_nominal_code=".to_sym }
    before do
      @product.send(setter, new_code)
    end
    context 'when param is a NominalCode' do
      let(:new_code) { FactoryGirl.create(:nominal_code, code: '1234') }
      it 'sets to the nominal code' do
        expect(@product.send(getter)).to eq new_code
      end
    end
    context 'when param is a string' do
      let(:nominal_code) { FactoryGirl.create(:nominal_code, code: '1234') }
      let(:new_code) { "#{nominal_code.code} Desription of code" }
      it 'sets to the nominal code whose code matches the first part of the string' do
        expect(@product.send(getter)).to eq nominal_code
      end
    end
  end

  describe '#purchase_nominal_code=' do
    it_behaves_like 'a nominal code setter', :purchase
  end

  describe '#sales_nominal_code=' do
    it_behaves_like 'a nominal code setter', :sales
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

  describe '.admin_search' do
    it 'finds products by SKU' do
      x = FactoryGirl.create(:product, sku: 'X')
      y = FactoryGirl.create(:product, sku: 'Y')
      products = Product.admin_search('X')
      expect(products).to include(x)
      expect(products).not_to include(y)
    end
  end

  describe '#title_for_google' do
    subject { Product.new(name: 'Original Name', google_title: google_title).title_for_google }

    context 'when google_title blank' do
      let(:google_title) { nil }
      it { should eq 'Original Name' }
    end

    context 'when google_title set' do
      let(:google_title) { 'Google Name' }
      it { should eq 'Google Name' }
    end
  end

  describe 'before_save' do
    it 'sets nil weight to zero' do
      product = FactoryGirl.build(:product, weight: nil)
      product.save
      expect(product.weight).to eq 0
    end
  end

  describe '.importable_attributes' do
    subject { Product.importable_attributes }
    ['image_name', 'image_names', 'purchase_nominal_code', 'sales_nominal_code'].each do |additional_attr|
      it { should include(additional_attr) }
    end
    ['purchase_nominal_code_id', 'sales_nominal_code_id'].each do |excluded_attr|
      it { should_not include(excluded_attr) }
    end
  end

  it_behaves_like 'an object with extra attributes'
end
