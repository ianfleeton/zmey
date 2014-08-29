require 'rails_helper'

describe 'payments/show.html.slim' do
  let(:payment) { FactoryGirl.create(:payment) }

  before do
    assign(:payment, payment)
  end

  it 'displays a heading' do
    render
    expect(rendered).to have_content(t('payments.show.heading'))
  end

  it 'displays the payment amount' do
    payment.amount = 9.99
    render
    expect(rendered).to have_content(payment.amount)
  end

  context 'without an associated order' do
    it 'does not mention an order' do
      expect(rendered).not_to have_content(t('payments.show.order'))
    end
  end

  context 'with associated order' do
    let(:order) { FactoryGirl.create(:order) }

    before do
      payment.order = order
      payment.save!
    end

    it 'links to the order' do
      render
      expect(rendered).to have_content(t('payments.show.order'))
      expect(rendered).to have_content(order.order_number)
      expect(rendered).to have_selector("a[href='#{admin_order_path(order)}']")
    end
  end
end
