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
end
