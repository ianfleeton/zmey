require 'rails_helper'

describe SagePay do
  describe '#encrypt' do
    it 'returns the tx_string xor-ed with key, base 64 encoded' do
      sp = SagePay.new(pre_shared_key: 'XXX')
      allow(sp).to receive(:tx_string).and_return('AAA')
      expect(sp.encrypt).to eq "GRkZ\n"
    end
  end

  describe '#tx_string' do
    it 'returns a valid query string for the tx_vars' do
      sp = SagePay.new({})
      allow(sp).to receive(:tx_vars).and_return(
        'VendorTxCode' => 'Order',
        'Amount' => '123'
      )
      expect(sp.tx_string).to eq 'VendorTxCode=Order&Amount=123'
    end
  end

  describe '#tx_vars' do
    it 'returns the hash of transaction variables' do
      sp = SagePay.new(
        vendor_tx_code: 'YESL',
        amount: 15.95,
        success_url: 'http://example.org/success',
        failure_url: 'http://example.org/failure',
        delivery_surname: 'Fleeton',
        delivery_firstnames: 'Ian',
        delivery_address: '123 Street',
        delivery_city: 'Doncaster',
        delivery_post_code: 'DN1 9ZZ',
        delivery_country: 'GB'
      )
      expected = {
        'VendorTxCode'=>'YESL',
        'Amount'=>15.95,
        'Currency'=>'GBP',
        'Description'=>'Web purchase',
        'SuccessURL'=>'http://example.org/success',
        'FailureURL'=>'http://example.org/failure',
        'BillingSurname'=>'',
        'BillingFirstnames'=>'',
        'BillingAddress'=>'',
        'BillingCity'=>'',
        'BillingPostCode'=>'',
        'BillingCountry'=>'',
        'DeliverySurname'=>'Fleeton',
        'DeliveryFirstnames'=>'Ian',
        'DeliveryAddress'=>'123 Street',
        'DeliveryCity'=>'Doncaster',
        'DeliveryPostCode'=>'DN1 9ZZ',
        'DeliveryCountry'=>'GB'
      }
      expect(sp.tx_vars).to eq expected
    end
  end
end
