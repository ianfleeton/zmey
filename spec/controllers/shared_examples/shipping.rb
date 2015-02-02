shared_examples_for 'a shipping class setter' do |method, action|
  let(:shipping_class) { FactoryGirl.create(:shipping_class) }
  let(:shipping_delivery_address) { FactoryGirl.create(:address) }

  before do
    session[:shipping_class_id] = session_shipping_class_id
    allow(controller).to receive(:delivery_address).and_return(shipping_delivery_address)
  end

  context 'when shipping_class_id in the session' do
    let(:session_shipping_class_id) { shipping_class.id }

    it 'sets @shipping_class from the session' do
      send(method, action)
      expect(assigns(:shipping_class)).to eq shipping_class
    end
  end

  context 'when shipping_class_id not in the session' do
    let(:session_shipping_class_id) { nil }

    it 'sets @shipping_class from the delivery address\'s first shipping class' do
      delivery_address_shipping_class = FactoryGirl.create(:shipping_class)
      allow(shipping_delivery_address)
        .to receive(:first_shipping_class)
        .and_return(delivery_address_shipping_class)
      send(method, action)
      expect(assigns(:shipping_class)).to eq delivery_address_shipping_class
    end
  end
end
