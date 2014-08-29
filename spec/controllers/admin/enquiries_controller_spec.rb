require 'rails_helper'
require 'shared_examples_for_controllers'

describe Admin::EnquiriesController do
  let(:website) { double(Website).as_null_object }

  def mock_enquiry(stubs={})
    @mock_enquiry ||= double(Enquiry, stubs)
  end

  before do
    allow(Website).to receive(:for).and_return(website)
    allow(website).to receive(:private?).and_return(false)
    allow(website).to receive(:vat_number).and_return('')
  end

  describe 'GET index' do
    context 'when logged in as an administrator' do
      before { logged_in_as_admin }

      it_behaves_like 'a website owned objects finder', :enquiry
    end
  end
end
