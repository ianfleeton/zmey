require 'spec_helper'

describe 'payments/index.html.erb' do
  let(:alice) { mock_model(Payment, name: 'Alice', amount: '123').as_null_object }
  let(:bob) { mock_model(Payment, name: 'Bob', amount: '456').as_null_object }

  it 'displays each payment' do
    assign(:payments, [alice, bob])
    render
    expect(rendered).to have_content('Alice')
    expect(rendered).to have_content('Bob')
  end

  it 'links to the full detail of the payment' do
    assign(:payments, [alice])
    render
    expect(rendered).to have_selector("a[href='/payments/#{alice.id}']")
  end

  context 'with associated orders' do
    it 'links to the orders' do
      order = mock_model(Order, order_number: 'ORDER123')
      alice.stub(:order).and_return(order)
      assign(:payments, [alice])
      render
      expect(rendered).to have_content('ORDER123')
      expect(rendered).to have_selector("a[href='/orders/#{order.id}']")
    end
  end
end
