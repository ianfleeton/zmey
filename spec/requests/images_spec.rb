# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Images", type: :request do
  describe "GET /up/images/:id/:filename" do
    let(:image) { FactoryBot.create(:image) }
    let(:id) { image.id }
    let(:filename) { "longest_side.100.jpg" }

    it "gets a sized path from Image" do
      expect(Image).to receive(:sized_path).with(id.to_s, filename)
        .and_call_original
      get "/up/images/#{image.id}/#{filename}"
    end

    it "sends the image file in response" do
      path = Image.item_missing_path
      allow(Image).to receive(:sized_path).and_return(path)
      expect_any_instance_of(ImagesController).to receive(:send_file).with(path, disposition: :inline)
        .and_call_original
      get "/up/images/#{image.id}/#{filename}"
    end
  end
end
