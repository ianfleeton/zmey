shared_examples_for 'a discounts calculator' do |method, action|
  it 'assigns @discount_lines' do
    send(method, action)
    expect(assigns(:discount_lines)).to be
  end
end
