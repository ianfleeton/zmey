require "rails_helper"

RSpec.describe "admin/orders/edit.html.slim", type: :view do
  let(:order) { FactoryBot.create(:order) }
  let(:website) { FactoryBot.create(:website) }

  before do
    assign(:order, order)
    without_partial_double_verification do
      allow(view).to receive(:website).and_return(website)
    end
  end

  it "has an input field for PO number" do
    render
    expect(rendered).to have_selector 'input[name="order[po_number]"]'
  end

  it "has an input field for email address" do
    render
    expect(rendered).to have_selector 'input[name="order[email_address]"]'
  end

  it "has an textarea for delivery instructions" do
    render
    expect(rendered).to have_selector 'textarea[name="order[delivery_instructions]"]'
  end

  context "when locked" do
    before { allow(order).to receive(:locked?).and_return(true) }
    it "displays a warning" do
      render
      expect(rendered).to have_content I18n.t("admin.orders.edit.locked_warning")
    end
  end

  context "when processed" do
    before { allow(order).to receive(:processed_at?).and_return(true) }
    it "displays a warning" do
      render
      expect(rendered).to have_content I18n.t("admin.orders.edit.processed_warning")
    end
    it "displays a link to mark as unprocessed" do
      render
      expect(rendered).to have_css "a[href='#{mark_unprocessed_admin_order_path(order)}']"
    end
  end

  context "when unprocessed" do
    before { allow(order).to receive(:processed_at?).and_return(false) }
    it "displays a link to mark as processed" do
      render
      expect(rendered).to have_css "a[href='#{mark_processed_admin_order_path(order)}']"
    end
  end

  context "with shipments" do
    let(:now) { Time.zone.now }
    let!(:shipment) { FactoryBot.create(:shipment, order: order) }

    before do
      render
    end

    it "displays the shipped_at time" do
      expect(rendered).to have_selector(".shipped-at")
    end

    it "displays the shipment's consignment_number" do
      expect(rendered).to have_selector(".shipping-consignment-number")
    end
  end

  context "when not fully shipped" do
    before do
      allow(order).to receive(:fully_shipped?).and_return(false)
    end

    it "links to new shipment" do
      render
      expect(rendered).to have_selector "a[href='#{new_admin_shipment_path(order_id: order.id)}']"
    end
  end

  context "without comments" do
    it "states no comments have been added yet" do
      render
      expect(rendered).to have_content t("admin.orders.edit.no_comments")
    end
  end

  context "with comments" do
    before do
      FactoryBot.create(:order_comment, order: order, comment: "Refund requested")
    end

    it "lists comments" do
      render
      expect(rendered).to have_content "Refund requested"
    end
  end
end
