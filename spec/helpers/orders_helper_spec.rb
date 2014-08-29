require 'rails_helper'

describe OrdersHelper do
  describe '#sage_pay_form_url' do
    it 'returns a live URL when test_mode false' do
      expect(sage_pay_form_url(false)).to eq(
        'https://live.sagepay.com/gateway/service/vspform-register.vsp'
      )
    end

    it 'returns a test URL when test_mode true' do
      expect(sage_pay_form_url(true)).to eq(
        'https://test.sagepay.com/gateway/service/vspform-register.vsp'
      )
    end
  end
end
