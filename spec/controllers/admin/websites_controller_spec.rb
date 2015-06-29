require 'rails_helper'

RSpec.describe Admin::WebsitesController, type: :controller do
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
      let(:valid_params) {{
        'country_id' => FactoryGirl.create(:country).id,
        'email' => 'merchant@example.com',
        'name' => 'foo',
        'subdomain' => 'shop',
        'upg_atlas_secuphrase' => 'SECRET',
      }}

      before { logged_in_as_admin }

      it "creates a new website with the given params" do
        allow(Page).to receive(:bootstrap)
        allow(controller).to receive(:create_latest_news)

        post 'create', website: valid_params

        expect(Website.find_by(valid_params)).to be
      end
    end
  end
end
