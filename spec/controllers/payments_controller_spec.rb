require 'spec_helper'

describe PaymentsController do
  let(:website) { mock_model(Website).as_null_object }

  before do
    Website.stub(:for).and_return(website)
    website.stub(:private?).and_return(false)
  end

  describe 'GET index' do
    context 'when logged in as admin' do
      before { logged_in_as_admin }

      it 'uses the admin layout' do
        get 'index'
        response.should render_template('layouts/admin')
      end
    end
  end
end
