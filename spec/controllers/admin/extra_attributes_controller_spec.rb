require 'rails_helper'

RSpec.describe Admin::ExtraAttributesController, type: :controller do
  context 'as admin' do
    before do
      logged_in_as_admin
    end

    describe 'POST create' do
      context 'when successful' do
        it 'creates a new ExtraAttribute' do
          expect { post_create }.to change { ExtraAttribute.count }.by 1
        end

        it 'redirects to index' do
          post_create
          expect(response).to redirect_to admin_extra_attributes_path
        end
      end

      def post_create
        post :create, params: { extra_attribute: { attribute_name: 'a', class_name: 'Page' } }
      end
    end

    describe 'PATCH update' do
      let(:extra_attribute) { FactoryBot.create(:extra_attribute) }
      let(:new_attribute_name) { SecureRandom.hex }
      let(:new_class_name) { SecureRandom.hex }

      context 'when successful' do
        it 'updates the extra attribute' do
          patch_update
          extra_attribute.reload
          expect(extra_attribute.attribute_name).to eq new_attribute_name
          expect(extra_attribute.class_name).to eq new_class_name
        end

        it 'redirects to index' do
          patch_update
          expect(response).to redirect_to admin_extra_attributes_path
        end
      end

      def patch_update
        patch :update, params: { id: extra_attribute.id, extra_attribute: { attribute_name: new_attribute_name, class_name: new_class_name } }
      end
    end

    describe 'DELETE destroy' do
      let(:a) { FactoryBot.create(:extra_attribute) }

      before do
        delete :destroy, params: { id: a.id }
      end

      it 'destroys the attribute' do
        expect(ExtraAttribute.find_by(id: a.id)).to be_nil
      end

      it 'redirects to index' do
        expect(response).to redirect_to admin_extra_attributes_path
      end
    end
  end
end
