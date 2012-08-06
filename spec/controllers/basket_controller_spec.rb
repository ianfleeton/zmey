require 'spec_helper'

describe BasketController do
  let(:website) { mock_model(Website).as_null_object }

  describe 'POST place_order' do
    it 'deletes a previous unpaid order if one exists' do
      controller.should_receive(:delete_previous_unpaid_order_if_any)
      post 'place_order'
    end
  end
end
