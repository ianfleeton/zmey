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

    it 'sets @shipping_class to the cheapest shipping class valid for the delivery address' do
      sc1 = double(ShippingClass, :valid_for_basket? => false, amount_for_basket: 5)
      sc2 = double(ShippingClass, :valid_for_basket? => true, amount_for_basket: 15)
      sc3 = double(ShippingClass, :valid_for_basket? => true, amount_for_basket: 10)
      allow(shipping_delivery_address).to receive(:shipping_classes).and_return [sc1, sc2, sc3]
      send(method, action)
      expect(assigns(:shipping_class)).to eq sc3
    end
  end
end

shared_examples_for 'a shipping amount setter' do |method, action|
  it 'sets @shipping_amount' do
    send(method, action)
    expect(assigns(:shipping_amount)).to be
  end

  it 'sets @shipping_tax_amount' do
    send(method, action)
    expect(assigns(:shipping_tax_amount)).to be
  end
end
