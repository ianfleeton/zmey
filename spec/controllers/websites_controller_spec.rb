require 'spec_helper'

describe WebsitesController do
  let(:website) { mock_model(Website).as_null_object }

  before do
    Website.stub(:for).and_return(website)
    website.stub(:private?).and_return(false)
    website.stub(:vat_number).and_return('')
  end

  def mock_website(stubs={})
    @mock_website ||= mock_model(Website, stubs)
  end

  describe 'POST create' do
    context 'when logged in as an administrator' do
      before { logged_in_as_admin }

      it "creates a new website with the given params" do
        params = { 'name' => 'foo' }

        Page.stub(:bootstrap)
        controller.stub(:create_latest_news)

        Website.should_receive(:new).with(params).and_return(website)
        post 'create', website: params
      end

      it "should populate the website's countries" do
        website = mock_website({save: true, id: 1, name: 'foo', :blog_id= => nil})
        Website.stub(:new).and_return(website)
        website.should_receive(:populate_countries!)
        post 'create'
      end
    end
  end
end
