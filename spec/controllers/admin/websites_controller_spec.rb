require 'rails_helper'

describe Admin::WebsitesController do
  let(:website) { FactoryGirl.build(:website) }

  before do
    allow(controller).to receive(:website).and_return(website)
  end

  def mock_website(stubs={})
    @mock_website ||= double(Website, stubs)
  end

  describe 'GET new' do
    context 'when logged in as an administrator' do
      before { logged_in_as_admin }

      context 'when no countries' do
        it 'should populate countries' do
          expect(Country).to receive(:populate!)
          get :new
        end
      end
    end
  end

  describe 'POST create' do
    context 'when logged in as an administrator' do
      let(:valid_params) { { 'website' => { 'name' => 'foo' } } }

      before { logged_in_as_admin }

      it "creates a new website with the given params" do
        allow(Page).to receive(:bootstrap)
        allow(controller).to receive(:create_latest_news)

        expect(Website).to receive(:new).with(valid_params['website']).and_return(website)
        post 'create', valid_params
      end
    end
  end
end
