require 'rails_helper'

module UpgAtlas
  RSpec.describe FieldList do
    let(:checkcode) { 'CHECKCODE' }
    let(:shreference) { 'SHREF' }
    let(:callbackurl) { 'https://callback.url' }
    let(:filename) { 'payment.html' }
    let(:secuphrase) { 'secret' }
    let(:field_list) { FieldList.new(order: order, checkcode: checkcode, shreference: shreference, callbackurl: callbackurl, filename: filename, secuphrase: secuphrase) }

    describe '#fields' do
      subject { field_list.fields }

      let(:order) { FactoryGirl.build(
        :order,
        billing_full_name: 'A Shopper',
        email_address: 'shopper@example.org',
        billing_address_line_1: '123 Street',
        billing_address_line_2: 'Locality',
        billing_town_city: 'City',
        billing_county: 'County',
        billing_postcode: 'POST CODE',
        billing_country: FactoryGirl.create(:country, name: 'United Kingdom'),
        billing_phone_number: '01234 567890'
      ) }
      let(:callbackdata) { 'amount|#amount|ordernumber|ORDER-1234|cardholdersname|#cardholdersname|cardholdersemail|#cardholdersemail' }
      let(:secuitems) { '[pd1|sku1|Product 1: size medium|10.00|2|20.00]' }

      before do
        allow(field_list).to receive(:callbackdata).and_return(callbackdata)
        allow(field_list).to receive(:secuitems).and_return(secuitems)
      end

      it { should include ['checkcode', checkcode] }
      it { should include ['filename', 'SHREF/payment.html'] }
      it { should include ['shreference', shreference] }
      it { should include ['callbackurl', callbackurl] }
      it { should include ['callbackdata', callbackdata] }
      it { should include ['cardholdersname', order.billing_full_name] }
      it { should include ['cardholdersemail', order.email_address] }
      it { should include ['cardholderaddr1', order.billing_address_line_1] }
      it { should include ['cardholderaddr2', order.billing_address_line_2] }
      it { should include ['cardholdercity', order.billing_town_city] }
      it { should include ['cardholderstate', order.billing_county] }
      it { should include ['cardholderpostcode', order.billing_postcode] }
      it { should include ['cardholdercountry', order.billing_country.name] }
      it { should include ['cardholdertelephonenumber', order.billing_phone_number] }
      it { should include ['secuitems', secuitems] }
      it { should include ['secuphrase', secuphrase] }
    end

    describe '#callbackdata' do
      let(:order) { FactoryGirl.build(:order, order_number: 'ORDER-1234') }

      subject { field_list.callbackdata }

      it { should include 'transactionamount|#transactionamount' }
      it { should include 'transactioncurrency|#transactioncurrency' }
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

    describe '#secuitems' do
      let(:order) { FactoryGirl.create(:order) }
      it 'returns a formatted string containing order line details' do
        product_1 = FactoryGirl.create(
          :product,
          sku: 'SKU1',
          name: 'P1',
          price: 1.5,
        )
        product_2 = FactoryGirl.create(
          :product,
          sku: 'SKU2',
          name: 'P2',
          price: 2.49,
        )
        FactoryGirl.create(:order_line, order: order, product: product_1, quantity: 3, product_sku: product_1.sku, product_name: product_1.name, product_price: product_1.price)
        FactoryGirl.create(:order_line, order: order, product: product_2, quantity: 1.6, product_sku: product_2.sku, product_name: product_2.name, product_price: product_2.price)
        expect(field_list.secuitems).to eq '[SKU1|SKU1|P1|1.50|3|4.50][SKU2|SKU2|P2|2.49|2|3.98]'
      end
    end
  end
end
