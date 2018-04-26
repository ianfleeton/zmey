require 'rails_helper'

describe 'payments/index.html.erb' do
  let(:alice) { FactoryBot.create(:payment, name: 'Alice', amount: '123') }
  let(:bob)   { FactoryBot.create(:payment, name: 'Bob', amount: '456') }

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
      order = FactoryBot.create(:order)
      allow(alice).to receive(:order).and_return(order)
      assign(:payments, [alice])
      render
      expect(rendered).to have_content(order.order_number)
      expect(rendered).to have_selector("a[href='/orders/#{order.id}']")
    end
  end
end
