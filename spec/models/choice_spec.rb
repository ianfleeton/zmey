require "rails_helper"

RSpec.describe Choice, type: :model do
  describe "#to_s" do
    it "returns its name" do
      expect(Choice.new(name: "Blue").to_s).to eq "Blue"
    end
  end

  describe "#create_permutations" do
    let(:component) { FactoryBot.create(:component) }
    let(:red) { FactoryBot.create(:choice) }

    context "the choice's feature is not part of a component" do
      it "creates no permuations" do
        red.create_permutations
        expect(Permutation.count).to eq 0
      end
    end

    context "the component has only a single feature" do
      before do
        colour = red.feature
        colour.component = component
        colour.save
        red.save
      end

      it "adds a permutation for itself" do
        red.create_permutations
        p = "_#{red.id}_"
        expect(Permutation.find_by(permutation: p)).to be
      end
    end

    context "component has multiple features but this is its feature's first choice" do
      let(:red) { FactoryBot.build(:choice) }

      before do
        size = FactoryBot.create(:feature, component_id: component.id)
        @large = FactoryBot.create(:choice, feature_id: size.id)
        @small = FactoryBot.create(:choice, feature_id: size.id)

        colour = red.feature
        colour.component = component
        colour.save
        red.save
      end

      it "is appends its ID to the existing two permutations" do
        expect(Permutation.count).to eq 2
        expect(Permutation.first.permutation).to eq "_#{@large.id}__#{red.id}_"
        expect(Permutation.last.permutation).to eq "_#{@small.id}__#{red.id}_"
      end
    end

    context "component has multiple features and this is not its feature's first choice" do
      let(:red) { FactoryBot.build(:choice) }

      before do
        size = FactoryBot.create(:feature, component_id: component.id)
        @large = FactoryBot.create(:choice, feature_id: size.id)
        @small = FactoryBot.create(:choice, feature_id: size.id)

        colour = red.feature
        colour.component = component
        colour.save

        @blue = FactoryBot.create(:choice, feature_id: colour.id)

        red.save
      end

      it "is creates a matrix of sorted permutations" do
        expect(Permutation.count).to eq 4
        expect(Permutation.first.permutation).to eq "_#{@large.id}__#{@blue.id}_"
        expect(Permutation.second.permutation).to eq "_#{@small.id}__#{@blue.id}_"
        expect(Permutation.third.permutation).to eq "_#{@large.id}__#{red.id}_"
        expect(Permutation.fourth.permutation).to eq "_#{@small.id}__#{red.id}_"
      end
    end
  end
end
