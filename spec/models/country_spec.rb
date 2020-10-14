require "rails_helper"

RSpec.describe Country, type: :model do
  describe "validations" do
    subject { FactoryBot.build(:country, iso_3166_1_alpha_2: "GB") }
    it { should validate_uniqueness_of(:iso_3166_1_alpha_2).case_insensitive }
    it { should validate_uniqueness_of(:name).case_insensitive }
    it { should validate_length_of(:name).is_at_most(100) }
  end

  describe ".populate!" do
    it "should create a number of countries" do
      Country.populate!
      expect(Country.count).to eq 248
    end
  end

  describe ".uk" do
    subject { Country.uk }
    context "when no UK country in database" do
      it { should be_nil }
    end
    context "when UK country in database" do
      let!(:uk) { FactoryBot.create(:country, name: Country::UNITED_KINGDOM) }
      it { should eq uk }
    end
  end

  describe "#uk?" do
    it "returns truthy if the name is UNITED_KINGDOM" do
      expect(Country.new(name: Country::UNITED_KINGDOM).uk?).to be_truthy
    end

    it "returns falsey if the name is anything other than UNITED_KINGDOM" do
      expect(Country.new(name: "France").uk?).to be_falsey
    end
  end

  describe ".shipping" do
    it "returns only countries with a shipping zone assigned" do
      zone = FactoryBot.create(:shipping_zone)
      c1 = FactoryBot.create(:country, shipping_zone: zone)
      c2 = FactoryBot.create(:country)
      expect(Country.shipping).to include(c1)
      expect(Country.shipping).not_to include(c2)
    end

    context "when none with shipping zone" do
      it "returns all countries" do
        c1 = FactoryBot.create(:country)
        expect(Country.shipping).to include(c1)
      end
    end
  end
end
