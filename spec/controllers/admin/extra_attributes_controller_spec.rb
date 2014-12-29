require 'rails_helper'

describe Admin::ExtraAttributesController do
  let(:website) { FactoryGirl.build(:website) }

  before do
    allow(controller).to receive(:website).and_return(website)
  end

  context 'as admin' do
    before do
      logged_in_as_admin
    end

    describe 'GET index' do
      it 'assigns all extra attributes to @extra_attributes' do
        a = FactoryGirl.create(:extra_attribute)
        get :index
        expect(assigns(:extra_attributes)).to include(a)
      end
    end

    describe 'GET new' do
      it 'assigns a new ExtraAttribute to @extra_attribute' do
        get :new
        expect(assigns(:extra_attribute)).to be_instance_of ExtraAttribute
      end
    end

    describe 'POST create' do
      context 'when successful' do
        it 'creates a new ExtraAttribute' do
          expect{post_create}.to change{ExtraAttribute.count}.by 1
        end

        it 'redirects to index' do
          post_create
          expect(response).to redirect_to admin_extra_attributes_path
        end
      end

      context 'when fail' do
        before do
          allow_any_instance_of(ExtraAttribute).to receive(:save).and_return(false)
        end

        it 'renders new' do
          post_create
          expect(response).to render_template 'new'
        end

        it 'assigns @extra_attribute' do
          post_create
          expect(assigns(:extra_attribute)).to be_instance_of(ExtraAttribute)
        end
      end

      def post_create
        post :create, extra_attribute: {attribute_name: 'a', class_name: 'Page'}
      end
    end

    describe 'DELETE destroy' do
      let(:a) { FactoryGirl.create(:extra_attribute) }

      before do
        delete :destroy, id: a.id
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
