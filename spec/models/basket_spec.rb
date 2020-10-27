require "rails_helper"

RSpec.describe Basket, type: :model do
  describe "#update_details" do
    it "sets email, mobile, name, phone, shipping_class_id from details hash" do
      basket = FactoryBot.build(:basket)
      details = {
        email: "sparklebatch@example.com",
        mobile: "07777 123456",
        name: "Sparklebatch Rumblesnack",
        phone: "01234 567890",
        shipping_class_id: 1
      }
      basket.update_details(details)
      basket.reload
      expect(basket.email).to eq "sparklebatch@example.com"
      expect(basket.mobile).to eq "07777 123456"
      expect(basket.name).to eq "Sparklebatch Rumblesnack"
      expect(basket.phone).to eq "01234 567890"
      expect(basket.shipping_class_id).to eq 1
    end
  end

  describe "#set_product_quantities" do
    let!(:basket) { FactoryBot.create(:basket) }
    let(:product) { FactoryBot.create(:product) }

    it "updates existing quantities" do
      basket.basket_items << BasketItem.new(product: product, quantity: 1)
      basket.set_product_quantities(product.id => 3)
      expect(basket.basket_items.first.quantity).to eq 3
    end

    it "adds new products" do
      basket.set_product_quantities(product.id => 2)
      expect(basket.basket_items.first.quantity).to eq 2
    end

    it "removes products with quantity < 1" do
      basket.basket_items << BasketItem.new(product: product, quantity: 1)
      basket.set_product_quantities(product.id => 0)
      expect(basket.basket_items.count).to eq 0
    end
  end

  describe "#quantity_of_product" do
    let!(:basket) { FactoryBot.create(:basket) }
    let(:product) { FactoryBot.create(:product) }

    context "with product in basket" do
      it "returns the quantity of that product" do
        basket.add(product, [], 1)
        expect(basket.quantity_of_product(product)).to eq 1
      end
    end

    context "without product in basket" do
      it "returns 0" do
        expect(basket.quantity_of_product(product)).to eq 0
      end
    end
  end

  describe "#can_update?" do
    let(:basket) { Basket.new(order: order) }
    subject { basket.can_update? }

    context "when not associated with an order" do
      let(:order) { nil }
      it { should be_truthy }
    end

    context "when associated with an order" do
      let(:order) { Order.new }
      before do
        allow(order).to receive(:can_update_basket?).and_return(can_update)
      end
      context "when order state can update basket" do
        let(:can_update) { true }
        it { should be_truthy }
      end
      context "when order state cannot update basket" do
        let(:can_update) { false }
        it { should be_falsey }
      end
    end
  end

  describe "#oversize?" do
    let(:basket) { Basket.new }
    let(:basket_item) { double(BasketItem, oversize?: oversize) }
    before do
      allow(basket).to receive(:basket_items).and_return([basket_item])
    end
    subject { basket.oversize? }
    context "with oversize items" do
      let(:oversize) { true }
      it { should eq true }
    end
    context "with no oversize items" do
      let(:oversize) { false }
      it { should eq false }
    end
  end

  describe "#overweight?" do
    let(:basket) { Basket.new }
    let(:basket_item) { double(BasketItem, product_weight: product_weight) }
    let(:max_product_weight) { 10 }
    before do
      allow(basket).to receive(:basket_items).and_return([basket_item])
    end
    subject { basket.overweight?(max_product_weight: max_product_weight) }
    context "with products exceeding max weight" do
      let(:product_weight) { 10.1 }
      it { should eq true }
    end
    context "with products at max weight" do
      let(:product_weight) { 10 }
      it { should eq false }
    end
    context "with products below max weight" do
      let(:product_weight) { 9.9 }
      it { should eq false }
    end
    context "when max_product_weight is zero" do
      let(:max_product_weight) { 0 }
      let(:product_weight) { 1 }
      it { should eq false }
    end
  end

  describe "#weight" do
    it "returns the sum of the weight of all basket items" do
      item1 = double(BasketItem, weight: 5)
      item2 = double(BasketItem, weight: 10)
      basket = Basket.new
      allow(basket).to receive(:basket_items).and_return [item1, item2]
      expect(basket.weight).to eq 15
    end
  end

  describe "#lead_time" do
    it "returns the highest value for lead time in basket items" do
      item1 = instance_double(BasketItem, lead_time: 3)
      item2 = instance_double(BasketItem, lead_time: 4)
      basket = Basket.new
      allow(basket).to receive(:basket_items).and_return [item1, item2]
      expect(basket.lead_time).to eq 4
    end

    it "returns 0 when the basket is empty" do
      basket = Basket.new
      expect(basket.lead_time).to eq 0
    end
  end

  describe "#total_for_shipping" do
    it "returns the basket total inc tax" do
      basket = Basket.new
      expect(basket).to receive(:total).with(true).and_return(12.0)
      expect(basket.total_for_shipping).to eq 12.0
    end
  end

  describe "#empty?" do
    let(:basket) { Basket.new }
    subject { basket.empty? }

    context "when the basket has some items" do
      before do
        basket.basket_items << BasketItem.new
      end

      it { should be_falsey }
    end

    context "when the basket has no items" do
      it { should be_truthy }
    end
  end

  describe "#contains?" do
    it "returns true when product or product_id is in basket" do
      p1 = FactoryBot.create(:product)
      p2 = FactoryBot.create(:product)
      basket = FactoryBot.create(:basket)
      basket.basket_items << BasketItem.new(product: p1)
      expect(basket.contains?(p1)).to eq true
      expect(basket.contains?(p1.id)).to eq true
      expect(basket.contains?(p2)).to eq false
      expect(basket.contains?(p2.id)).to eq false
    end
  end

  describe "#items_containing" do
    it "returns basket items that contain product or product_id" do
      p1 = FactoryBot.create(:product)
      p2 = FactoryBot.create(:product)
      basket = FactoryBot.create(:basket)
      i1 = BasketItem.create!(product: p1, basket: basket)
      i2 = BasketItem.create!(product: p2, basket: basket)
      i3 = BasketItem.create!(product: p1, basket: basket)
      expect(basket.items_containing(p1)).to include(i1)
      expect(basket.items_containing(p1.id)).to include(i1)
      expect(basket.items_containing(p1)).to include(i3)
      expect(basket.items_containing(p1.id)).to include(i3)
      expect(basket.items_containing(p1)).not_to include(i2)
      expect(basket.items_containing(p1.id)).not_to include(i2)
    end
  end

  describe "#vat_total" do
    let(:basket) { Basket.new }

    it "returns the total VAT for all items in the basket" do
      allow(basket).to receive(:basket_items).and_return(
        [double(BasketItem, tax_amount: 1), double(BasketItem, tax_amount: 3)]
      )
      expect(basket.vat_total).to eq 4
    end
  end

  describe "#deep_clone" do
    it "returns a copy of the basket" do
      b = Basket.new
      expect(b.deep_clone).not_to eq b
    end

    it "copies the basket information" do
      note = SecureRandom.hex
      b = Basket.new(customer_note: note)
      expect(b.deep_clone.customer_note).to eq note
    end

    it "generates a new token for the clone" do
      b = Basket.new
      b.generate_token
      expect(b.deep_clone.token).not_to eq b.token
    end

    it "saves the clone" do
      expect(Basket.new.deep_clone.new_record?).to be_falsey
    end

    it "copies basket items" do
      p = FactoryBot.create(:product)
      b = FactoryBot.create(:basket)
      b.basket_items << BasketItem.new(product_id: p.id)
      expect(b.deep_clone.basket_items.count).to eq 1
      expect(b.basket_items.count).to eq 1
    end
  end

  describe "#delete_rewards" do
    it "removes basket items that were added as rewards" do
      basket = FactoryBot.create(:basket)
      bi1 = FactoryBot.create(:basket_item, basket: basket, reward: false)
      bi2 = FactoryBot.create(:basket_item, basket: basket, reward: true)

      basket.delete_rewards

      expect(basket.basket_items).to include(bi1)
      expect(basket.basket_items).not_to include(bi2)
    end
  end

  describe "#reward_items" do
    it "returns basket items that are rewards" do
      basket = FactoryBot.create(:basket)
      bi1 = FactoryBot.build(:basket_item, reward: false)
      bi2 = FactoryBot.build(:basket_item, reward: true)
      basket.basket_items = [bi1, bi2]

      reward_items = basket.reward_items

      expect(reward_items).to include(bi2)
      expect(reward_items).not_to include(bi1)
    end
  end
end
