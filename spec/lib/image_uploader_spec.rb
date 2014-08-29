require 'rails_helper'

include ActionDispatch::TestProcess

describe ImageUploader do
  let(:upload) { fixture_file_upload('images/red.png') }

  describe '.initialize' do
    it 'creates an image' do
      expect(Image).to receive(:new)
        .with(hash_including(image: upload, name: 'image'))
        .and_return(double(Image).as_null_object)
      ImageUploader.new(image: upload, name: 'image')
    end

    it 'yields each image if block given' do
      image = nil
      ImageUploader.new(image: upload, name: 'image') do |yielded|
        image = yielded
      end
      expect(image).to be_instance_of Image
    end

    it 'saves the image' do
      image = double(Image).as_null_object
      allow(Image).to receive(:new).and_return(image)
      expect(image).to receive(:save)
      ImageUploader.new(image: upload, name: 'image')
    end

    it 'makes accessible the saved images via #images' do
      image = double(Image, save: true)
      allow(Image).to receive(:new).and_return(image)
      uploader = ImageUploader.new(image: upload, name: 'image')
      expect(uploader.images).to eq [image]
      expect(uploader.failed).to eq []
    end

    it 'makes accessible via #failed images that failed to save' do
      image = double(Image, save: false).as_null_object
      allow(Image).to receive(:new).and_return(image)
      uploader = ImageUploader.new(image: upload, name: 'image')
      expect(uploader.images).to eq []
      expect(uploader.failed).to eq [image]
    end

    context 'with two images in a ZIP archive' do
      let(:upload) { fixture_file_upload('images/two-images.zip') }

      it 'creates both images' do
        expect{ImageUploader.new(image: upload, name: 'image')}.to change{Image.count}.by(2)
      end
    end
  end
end
