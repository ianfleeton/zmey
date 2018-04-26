require 'rails_helper'

RSpec.describe ProductImage, type: :model do
  it { should validate_presence_of(:image_id) }
  it { should validate_presence_of(:product_id) }

  it { should belong_to(:image) }
  it { should belong_to(:product) }

  describe 'after create' do
    let(:product) { FactoryBot.create(:product, image: original_image) }
    let(:image) { FactoryBot.create(:image) }
    let(:original_image) { nil }

    before do
      ProductImage.create!(product: product, image: image)
    end

    context 'product has no image' do
      it 'sets itself as main product image' do
        expect(product.image).to eq image
      end
    end

    context 'product has image already' do
      let(:original_image) { FactoryBot.create(:image) }
      it 'leaves original image in place' do
        expect(product.image).to eq original_image
      end
    end
  end
end
