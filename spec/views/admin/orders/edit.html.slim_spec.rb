require 'rails_helper'

RSpec.describe 'admin/orders/edit.html.slim', type: :view do
  let(:order) { FactoryGirl.create(:order) }
  let(:website) { FactoryGirl.create(:website) }

  before do
    assign(:order, order)
    allow(view).to receive(:website).and_return(website)
  end

  it 'has an input field for PO number' do
    render
    expect(rendered).to have_selector 'input[name="order[po_number]"]'
  end

  context 'when locked' do
    before { allow(order).to receive(:locked?).and_return(true) }
    it 'displays a warning' do
      render
      expect(rendered).to have_content I18n.t('admin.orders.edit.locked_warning')
    end
  end

  context 'when fully shipped' do
    let(:now) { Time.zone.now }

    before do
      allow(order).to receive(:fully_shipped?).and_return(true)
      allow(order).to receive(:shipped_at).and_return(now)
      allow(order).to receive(:shipping_tracking_number).and_return('TRACK-123')
      render
    end

    it 'displays the shipped_at time' do
      expect(rendered).to have_selector('.shipped-at')
    end

    it 'displays the shipping_tracking_number' do
      expect(rendered).to have_selector('.shipping-tracking-number')
    end
  end

  context 'when not fully shipped' do
    before do
      allow(order).to receive(:fully_shipped?).and_return(false)
    end

    it 'links to new shipment' do
      render
      expect(rendered).to have_selector "a[href='#{new_admin_shipment_path(order_id: order.id)}']"
    end
  end

  context 'with payments' do
    before do
      FactoryGirl.create(:payment, order: order)
    end

    it 'renders payments' do
      render
      expect(view).to render_template '_payments'
    end
  end

  context 'without comments' do
    it 'states no comments have been added yet' do
      render
      expect(rendered).to have_content t('admin.orders.edit.no_comments')
    end
  end

  context 'with comments' do
    before do
      FactoryGirl.create(:order_comment, order: order, comment: 'Refund requested')
    end

    it 'lists comments' do
      render
      expect(rendered).to have_content 'Refund requested'
    end
  end
end
