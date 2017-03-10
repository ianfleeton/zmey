require 'rails_helper'

RSpec.describe Admin::ProductImagesController do
  describe 'POST create' do
    let!(:product) { FactoryGirl.create(:product) }
    let(:image) { FactoryGirl.create(:image) }
    let(:image_id) { image.id }

    before do
      logged_in_as_admin
      post :create, params: { product_image: { product_id: product.id, image_id: image_id } }
    end

    context 'when image found' do
      it 'adds image to product' do
        expect(product.reload.images).to include(image)
      end

      it 'sets a successful flash notice' do
        expect(flash[:notice]).to eq I18n.t('controllers.admin.product_images.create.added')
      end
    end

    it 'redirects to edit product' do
      expect(response).to redirect_to(edit_admin_product_path(product))
    end
  end

  describe 'DELETE destroy' do
    let!(:product) { FactoryGirl.create(:product) }
    let(:image) { FactoryGirl.create(:image) }
    let(:image_id) { image.id }
    let(:main_image) { image }

    before do
      logged_in_as_admin
      product.images << image
      product.image = main_image
      product.save
      delete :destroy, params: { id: ProductImage.find_by(image_id: image.id).id }
    end

    context 'when image found' do
      it 'removes image from product' do
        expect(product.reload.images).not_to include(image)
      end

      context 'when main image' do
        it 'sets product image to nil' do
          expect(product.reload.image).to be_nil
        end
      end

      context 'when not main image' do
        let(:main_image) { FactoryGirl.create(:image) }

        it 'leaves product main image intact' do
          expect(product.reload.image).to eq main_image
        end
      end
    end

    it 'sets a flash notice' do
      expect(flash[:notice]).to eq I18n.t('controllers.admin.product_images.destroy.removed')
    end

    it 'redirects to edit product' do
      expect(response).to redirect_to(edit_admin_product_path(product))
    end
  end
end
