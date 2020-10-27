require "rails_helper"

RSpec.describe Address, type: :model do
  describe "before validation" do
    context "with label present" do
      it "leaves the label untouched" do
        a = Address.new(label: "Home")
        a.save
        expect(a.label).to eq "Home"
      end
    end

    context "with label blank" do
      it "generates a label for the address based on name and postcode" do
        a = Address.new(full_name: "Ian Fleeton", postcode: "L0N D0N")
        a.save
        expect(a.label).to eq "Ian Fleeton - L0N D0N"
      end
    end
  end

  describe ".new_or_reuse" do
    it "returns a new address with nil user even if a matching address " \
    "exists" do
      address = FactoryBot.create(:address, user: nil)
      expect(Address.new_or_reuse(address.attributes).new_record?).to be_truthy
    end

    it "returns an existing address for user when a matching address exists" do
      user = FactoryBot.create(:user)
      address = FactoryBot.create(:address, user: user)
      expect(Address.new_or_reuse(address.attributes).persisted?).to be_truthy
    end

    it "returns a new address for user when no matching address exists" do
      user = FactoryBot.create(:user)
      address = FactoryBot.create(:address, user: user)
      expect(
        Address.new_or_reuse(
          address.attributes.merge(town_city: "Somewhere else")
        ).new_record?
      ).to be_truthy
    end
  end

  describe ".placeholder" do
    subject { Address.placeholder }

    context "when UK exists in database" do
      let(:uk) do
        FactoryBot.build_stubbed(:country, name: Country::UNITED_KINGDOM)
      end
      before { allow(Country).to receive(:uk).and_return(uk) }
      it "sets UK as the country" do
        expect(subject.country).to eq uk
      end
      it "returns a valid address" do
        expect(subject.valid?).to be_truthy
      end
    end
  end

  describe "#shipping_zone" do
    before { setup_address_with_shipping_classes }

    it "is delegated to country" do
      expect(@address.shipping_zone).to eq @shipping_zone
    end

    it "returns nil if no country" do
      expect(Address.new.shipping_zone).to be_nil
    end
  end

  describe "#shipping_classes" do
    context "with shipping zone" do
      before { setup_address_with_shipping_classes }

      it "returns the shipping zone's classes" do
        expect(@address.shipping_classes).to include(@shipping_class)
      end
    end

    context "without shipping zone" do
      it "returns an empty array" do
        expect(Address.new.shipping_classes).to eq []
      end
    end
  end

  describe "#default_shipping_class" do
    context "with shipping zone" do
      before { setup_address_with_shipping_classes }

      context "shipping zone has no default class" do
        it "returns nil" do
          expect(@address.default_shipping_class).to be_nil
        end
      end

      context "shipping_zone has a default class" do
        before do
          @shipping_zone.default_shipping_class = @shipping_class
          @shipping_zone.save
        end

        it "returns the default class" do
          expect(@address.default_shipping_class).to eq @shipping_class
        end
      end
    end

    context "without shipping zone" do
      it "returns nil" do
        expect(Address.new.default_shipping_class).to be_nil
      end
    end
  end

  def setup_address_with_shipping_classes
    @shipping_zone = FactoryBot.create(:shipping_zone)
    @shipping_class = FactoryBot.create(:shipping_class, shipping_zone: @shipping_zone)
    @country = FactoryBot.create(:country, shipping_zone: @shipping_zone)
    @address = FactoryBot.create(:address, country: @country)
  end

  describe "#to_s" do
    it "returns label attribute" do
      expect(Address.new(label: "x").to_s).to eq "x"
    end
  end
end
