require 'rails_helper'

describe Admin::PagesController do
  let(:website) { FactoryGirl.create(:website) }

  before do
    allow(controller).to receive(:website).and_return(website)
  end

  context 'when admin or manager' do
    before { allow(controller).to receive(:admin_or_manager?).and_return(true) }

    describe 'GET index' do
      let(:parent)     { FactoryGirl.create(:page) }

      context 'with parent_id' do
        let(:child)      { FactoryGirl.create(:page) }
        let(:grandchild) { FactoryGirl.create(:page) }

        before do
          child.children  << grandchild
          parent.children << child
          get :index, parent_id: parent.id
        end

        it 'finds and sets @parent' do
          expect(assigns(:parent)).to eq parent
        end

        it 'assigns child pages to @pages' do
          expect(assigns(:pages)).to eq parent.children
        end
      end

      context 'without parent_id' do
        before { get :index }

        it 'sets @parent to nil' do
          expect(defined?(assigns(:parent))).to be
          expect(assigns(:parent)).to be_nil
        end

        it 'assigns top level pages to @pages' do
          expect(assigns(:pages)).to eq [parent]
        end
      end
    end

    describe 'PATCH update' do
      context 'when update fails' do
        let!(:existing_page) { FactoryGirl.create(:page) }
        let(:page) { FactoryGirl.create(:page) }
        before { patch :update, id: page.id, page: {slug: existing_page.slug} }

        it 'responds 200' do
          expect(response.status).to eq 200
        end

        it 'renders :edit' do
          expect(response).to render_template :edit
        end
      end
    end

    describe 'POST create' do
      it 'creates a new page' do
        slug = SecureRandom.hex
        post :create, page: { slug: slug, title: 'T', name: 'N', description: 'D' }
        expect(Page.find_by(slug: slug)).to be
      end
    end
  end
end
