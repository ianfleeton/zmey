require 'rails_helper'

module YorkshirePayments
  RSpec.describe FieldList do
    let(:merchant_id) { '101380' }
    let(:pre_shared_key) { 'xyzzy' }
    let(:callback_url) { 'https://zmey.co.uk/callback' }
    let(:redirect_url) { 'https://zmey.co.uk/redirect' }
    let(:field_list) { FieldList.new(order: order, merchant_id: merchant_id, pre_shared_key: pre_shared_key, callback_url: callback_url, redirect_url: redirect_url) }

    describe '#fields' do
      subject { field_list.fields }

      let(:order) { FactoryGirl.build(:order, order_number: order_number, total: 123.45, billing_full_name: 'A Shopper', billing_address_line_1: '123 Street', billing_town_city: 'Doncaster', billing_county: 'South Yorkshire', billing_postcode: 'POST CODE', billing_phone_number: '01234 567890', email_address: 'ashopper@example.org') }
      let(:order_number) { 'ORDER-1234' }
      let(:signature) { 'SHA512' }

      before do
        allow(field_list).to receive(:signature).and_return(signature)
      end

      it { should include ['amount', '12345'] }
      it { should include ['callbackURL', callback_url] }
      it { should include ['countryCode', '826'] }
      it { should include ['currencyCode', '826'] }
      it { should include ['customerAddress', "123 Street\nDoncaster\nSouth Yorkshire"] }
      it { should include ['customerEmail', 'ashopper@example.org'] }
      it { should include ['customerName', 'A Shopper'] }
      it { should include ['customerPhone', '01234 567890'] }
      it { should include ['customerPostCode', 'POST CODE'] }
      it { should include ['merchantID', merchant_id] }
      it { should include ['redirectURL', redirect_url] }
      it { should include ['transactionUnique', order_number] }

      context 'with pre-shared key set' do
        let(:pre_shared_key) { 'Engine0Milk12Next' }
        it { should include ['signature', signature] }
      end

      context 'with pre-shared key blank' do
        let(:pre_shared_key) { '' }
        it { should_not include ['signature', signature] }
      end
    end

    describe '#signature' do
      let(:order) { FactoryGirl.build(:order, order_number: 'ORDER-1234', total: 123.45) }
      subject { field_list.signature }
      it 'should be 128 hex chars long' do
        expect(subject.length).to eq 128
      end
    end
  end
end
