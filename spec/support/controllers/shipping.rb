shared_examples_for 'a shipping class setter' do |method, action|
  let(:shipping_class) { FactoryGirl.create(:shipping_class) }

  it 'sets @shipping_class from the session' do
    session[:shipping_class_id] = shipping_class.id
    send(method, action)
    expect(assigns(:shipping_class)).to eq shipping_class
  end
end
