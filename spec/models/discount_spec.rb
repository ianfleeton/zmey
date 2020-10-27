require "rails_helper"

RSpec.describe Discount, type: :model do
  describe "associations" do
    it { should have_many(:discount_uses).dependent(:delete_all) }
  end

  describe "validations" do
    it { should validate_numericality_of(:reward_amount).is_less_than(10_000_000).is_greater_than_or_equal_to(0) }
    it { should validate_inclusion_of(:reward_type).in_array(Discount::REWARD_TYPES) }
    it { should validate_numericality_of(:threshold).is_less_than(10_000_000).is_greater_than_or_equal_to(0) }
  end

  describe "#to_s" do
    it "returns its name" do
      discount = Discount.new(name: "20% Off")
      expect(discount.to_s).to eq "20% Off"
    end
  end

  describe "#uppercase_coupon_code" do
    it "transforms the coupon attribute to uppercase" do
      discount = Discount.new(coupon: "Coupon")
      discount.uppercase_coupon_code
      expect(discount.coupon).to eq "COUPON"
    end
  end

  describe ".currently_valid" do
    subject { Discount.currently_valid }
    context "with currently valid discount" do
      let!(:discount) do
        FactoryBot.create(
          :discount,
          valid_from: Time.current - 1.day, valid_to: Time.current + 1.day
        )
      end
      it { should include(discount) }
    end

    context "with expired discount" do
      let!(:discount) do
        FactoryBot.create(
          :discount,
          valid_from: Time.current - 2.days, valid_to: Time.current - 1.day
        )
      end
      it { should_not include(discount) }
    end

    context "with future discount" do
      let!(:discount) do
        FactoryBot.create(
          :discount,
          valid_from: Time.current + 1.day, valid_to: Time.current + 2.days
        )
      end
      it { should_not include(discount) }
    end

    context "with unset date range" do
      let!(:discount) do
        FactoryBot.create(:discount, valid_from: nil, valid_to: nil)
      end
      it { should include(discount) }
    end

    context "with uses remaining" do
      let!(:discount) do
        FactoryBot.create(:discount, uses_remaining: 1)
      end
      it { should include(discount) }
    end

    context "with no uses remaining" do
      let!(:discount) do
        FactoryBot.create(:discount, uses_remaining: 0)
      end
      it { should_not include(discount) }
    end

    context "with discount code unset" do
      let!(:discount) { FactoryBot.create(:discount, code: "APRILSAVE") }
      it { should_not include(discount) }
    end

    context "with discount code set" do
      subject { Discount.currently_valid(code: "MAYSAVE") }
      let!(:discount1) { FactoryBot.create(:discount, code: "APRILSAVE") }
      let!(:discount2) { FactoryBot.create(:discount, code: "MAYSAVE") }
      it { should_not include(discount1) }
      it { should include(discount2) }
    end

    context "with discount code set to mismatched case" do
      subject { Discount.currently_valid(code: "maysave") }
      let!(:discount) { FactoryBot.create(:discount, code: "MAYSAVE") }
      it { should include(discount) }
    end
  end

  describe ".current_percentage_off_order_discounts" do
    let(:discount) { Discount }
    let(:percentage_off_order) { FactoryBot.build(:discount, reward_type: "percentage_off_order") }
    let(:amount_off_order) { FactoryBot.build(:discount, reward_type: "amount_off_order") }
    let(:discounts) { [percentage_off_order, amount_off_order] }

    before { allow(discount).to receive(:currently_valid).and_return(discounts) }

    it "returns currently valid percentage off order discounts" do
      expect(discount.current_percentage_off_order_discounts).to eq [percentage_off_order]
    end
  end

  describe "#record_use" do
    it "reduces uses remaining by one when uses is a number" do
      discount = FactoryBot.create(:discount, uses_remaining: 3)
      discount.record_use
      expect(discount.uses_remaining).to eq 2
    end

    it "saves the discount" do
      discount = FactoryBot.create(:discount, uses_remaining: 3)
      discount.record_use
      discount.reload
      expect(discount.uses_remaining).to eq 2
    end

    it "leaves uses remaining as nil when nil" do
      discount = FactoryBot.create(:discount, uses_remaining: nil)
      discount.record_use
      expect(discount.uses_remaining).to be_nil
    end
  end
end
