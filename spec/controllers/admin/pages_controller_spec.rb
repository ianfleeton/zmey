require 'rails_helper'

describe Admin::PagesController do
  let(:website) { FactoryGirl.create(:website) }

  before do
    allow(controller).to receive(:website).and_return(website)
  end

  context 'when admin or manager' do
    before { allow(controller).to receive(:admin_or_manager?).and_return(true) }

    describe 'GET index' do
      let(:parent)     { FactoryGirl.create(:page, website_id: website.id) }

      context 'with parent_id' do
        let(:child)      { FactoryGirl.create(:page, website_id: website.id) }
        let(:grandchild) { FactoryGirl.create(:page, website_id: website.id) }

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
  end
end
