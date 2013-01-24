require 'spec_helper'

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

      it 'fetches website enquiries' do
        website.should_receive(:enquiries)
        get 'index'
      end

      it 'assigns @enquiries' do
        website.stub(:enquiries).and_return [mock_enquiry]
        get 'index'
        assigns(:enquiries).should == [mock_enquiry]
      end
    end
  end
end
