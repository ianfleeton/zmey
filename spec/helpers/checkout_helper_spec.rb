require 'rails_helper'

RSpec.describe CheckoutHelper, type: :helper do
  describe '#upg_atlas_callbackdata' do
    let(:order) { FactoryGirl.build(:order, order_number: 'ORDER-1234') }

    subject { upg_atlas_callbackdata(order) }

    it { should include 'transactionamount|#transactionamount' }
    it { should include 'ordernumber|ORDER-1234' }
    it { should include 'cardholderaddr1|#cardholderaddr1' }
    it { should include 'cardholderaddr2|#cardholderaddr2' }
    it { should include 'cardholdercity|#cardholdercity' }
    it { should include 'cardholderstate|#cardholderstate' }
    it { should include 'cardholderpostcode|#cardholderpostcode' }
    it { should include 'cardholdercountry|#cardholdercountry' }
    it { should include 'cardholdersname|#cardholdersname' }
    it { should include 'cardholdersemail|#cardholdersemail' }
    it { should include 'cardholderstelephonenumber|#cardholderstelephonenumber' }
  end
end
