# frozen_string_literal: true

require "rails_helper"

module Shipping
  RSpec.describe Selection do
    describe "#update" do
      let(:session) { {} }
      let(:basket) { Basket.new }
      let(:option) { "collection" }
      let!(:collection) { FactoryBot.create(:shipping_class, name: ShippingClass::COLLECTION) }
      let!(:mainland) { FactoryBot.create(:shipping_class, name: ShippingClass::MAINLAND) }
      let(:other_shipping_class) { FactoryBot.create(:shipping_class) }
      let!(:address) { nil }
      let(:postcode) { nil }
      let(:selection) {
        Selection.new(
          option: option,
          postcode: postcode,
          session: session,
          address: address,
          basket: basket
        )
      }

      it "updates shipping_class_id in session hash" do
        selection.update
        expect(session[:shipping_class_id]).to eq collection.id
      end

      context "when option is collection" do
        let(:option) { "collection" }

        it "sets shipping class to collection" do
          selection.update
          expect(selection.shipping_class).to eq collection
        end

        it "updates shipping_class_id in session hash to collection id" do
          selection.update
          expect(session[:shipping_class_id]).to eq collection.id
        end
      end

      context "option is not collection" do
        let(:option) { "other" }
        let(:shipping_classes_found) { [] }
        let(:basket_matched) { true }
        let(:basket) { FactoryBot.build(:basket) }
        let(:scbp) { instance_double(ShippingClassByPostcode, find_all: shipping_classes_found) }
        let(:scbm) { instance_double(ShippingClassShoppingMatch, valid?: basket_matched) }

        before do
          allow(ShippingClassByPostcode).to receive(:new).and_return(scbp)
        end

        it "calls ShippingClassByPostcode.new.find_all" do
          allow(ShippingClassShoppingMatch).to receive(:new).and_return(scbm)
          expect(scbp).to receive(:find_all)
          selection.update
        end

        context "when postcode has not changed" do
          let!(:address) { FactoryBot.build(:address, postcode: "DN1 2BC") }
          let(:postcode) { "DN1 2BC" }
          it "sets postcode changed to false" do
            selection.update
            expect(selection.postcode_changed?).to be_falsey
          end
        end

        context "when postcode has changed" do
          let!(:address) { FactoryBot.build(:address, postcode: "SH7 9ZY") }
          let(:postcode) { "DN1 2BC" }
          it "sets postcode changed to true" do
            selection.update
            expect(selection.postcode_changed?).to be_truthy
          end
        end
      end
    end
  end
end
