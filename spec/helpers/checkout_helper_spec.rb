require 'rails_helper'

RSpec.describe CheckoutHelper, type: :helper do
  describe '#upg_atlas_callbackdata' do
    let(:order) { FactoryGirl.build(:order, order_number: 'ORDER-1234') }

    subject { upg_atlas_callbackdata(order) }

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

  describe '#upg_atlas_secuitems' do
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
      order = FactoryGirl.create(:order)
      FactoryGirl.create(:order_line, order: order, product: product_1, quantity: 3, product_sku: product_1.sku, product_name: product_1.name, product_price: product_1.price)
      FactoryGirl.create(:order_line, order: order, product: product_2, quantity: 1.6, product_sku: product_2.sku, product_name: product_2.name, product_price: product_2.price)
      expect(upg_atlas_secuitems(order.order_lines)).to eq '[SKU1|SKU1|P1|1.50|3|4.50][SKU2|SKU2|P2|2.49|2|3.98]'
    end
  end
end
