require 'rails_helper'

RSpec.describe ImagesController, type: :controller do
  describe 'GET sized_image' do
    let(:image)    { FactoryGirl.create(:image) }
    let(:id)       { image.id }
    let(:filename) { 'longest_side.100.jpg' }

    it 'gets a sized path from Image' do
      expect(Image).to receive(:sized_path).with(id.to_s, filename).and_call_original
      get :sized_image, id: id, filename: filename
    end

    it 'sends the image file in response' do
      path = Image.image_missing_path
      allow(Image).to receive(:sized_path).and_return(path)
      expect(controller).to receive(:send_file).with(path, disposition: :inline).and_call_original
      get :sized_image, id: id, filename: filename
    end
  end
end
