require 'rails_helper'

RSpec.describe CheckoutHelper, type: :helper do
  describe '#upg_atlas_hidden_fields' do
    let(:fields) { [
      ['name', 'val']
    ] }
    let(:field_list) { double(UpgAtlas::FieldList) }
    it 'delegates the work to UpgAtlas::FieldList' do
      allow(UpgAtlas::FieldList).to receive(:new).and_return(field_list)
      allow(field_list).to receive(:fields).and_return(fields)
      expect(upg_atlas_hidden_fields(order: Order.new, checkcode: 'CHECKCODE', shreference: 'SHREF', callbackurl: 'https://callback.url', filename: 'payment.html', secuphrase: 'secret')).to eq fields
    end
  end

  describe '#yorkshire_payments_hidden_fields' do
    let(:fields) { [
      ['name', 'val']
    ] }
    let(:field_list) { double(YorkshirePayments::FieldList) }
    it 'delegates the work to YorkshirePayments::FieldList' do
      allow(YorkshirePayments::FieldList).to receive(:new).and_return(field_list)
      allow(field_list).to receive(:fields).and_return(fields)
      expect(yorkshire_payments_hidden_fields(order: Order.new, merchant_id: 'MERCHANT', callback_url: 'https://callback.url', redirect_url: 'https://redirect.url', pre_shared_key: 'secret')).to eq fields
    end
  end
end
