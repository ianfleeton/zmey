require 'spec_helper'
require 'shared_examples_for_controllers'

describe EnquiriesController do
  let(:website) { mock_model(Website).as_null_object }

  def mock_enquiry(stubs={})
    @mock_enquiry ||= mock_model(Enquiry, stubs)
  end

  before do
    Website.stub(:for).and_return(website)
    website.stub(:private?).and_return(false)
    website.stub(:vat_number).and_return('')
  end

  describe 'GET index' do
    context 'when logged in as an administrator' do
      before { logged_in_as_admin }

      it_behaves_like 'a website owned objects finder', :enquiry
    end
  end
end
