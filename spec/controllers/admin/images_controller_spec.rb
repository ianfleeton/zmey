require 'spec_helper'
require 'shared_examples_for_controllers'

describe Admin::ImagesController do
  let(:website) { FactoryGirl.build(:website) }

  before do
    Website.stub(:for).and_return(website)
    logged_in_as_admin
  end

  describe 'GET index' do
    it_behaves_like 'a website owned objects finder', :image
  end

  describe 'POST create' do
    let(:red_image) { fixture_file_upload('images/red.png') }

    def post_create
      post :create, image: { 'image' => red_image, 'name' => 'red' }
    end

    it 'creates a new ImageUploader' do
      ImageUploader.should_receive(:new)
        .with(hash_including('image' => red_image, 'name' => 'red'))
        .and_return double(ImageUploader).as_null_object
      post_create
    end

    it 'associates the image with the current website' do
      image = FactoryGirl.create(:image)
      Image.stub(:new).and_return(image)
      post_create
      expect(image.website).to eq controller.website
    end

    it 'sets a flash notice stating how many images were uploaded' do
      ImageUploader.any_instance.stub(:images).and_return [Image.new]
      post_create
      expect(flash[:notice]).to eq '1 image uploaded.'
    end

    context 'when some images uploaded' do
      before do
        Image.any_instance.stub(:save).and_return true
      end

      it 'redirects to images index' do
        post_create
        expect(response).to redirect_to admin_images_path
      end
    end

    context 'when no images uploaded' do
      before do
        Image.any_instance.stub(:save).and_return false
      end

      it 'assigns the first failed image to @image if there is one' do
        image = Image.new
        ImageUploader.any_instance.stub(:failed).and_return [image]
        post_create
        expect(assigns(:image)).to eq image
      end

      it 'assigns a new Image to @image if none in failed' do
        ImageUploader.any_instance.stub(:failed).and_return []
        post_create
        expect(assigns(:image)).to be_instance_of Image
      end

      it 'renders new' do
        post_create
        expect(response).to render_template :new
      end
    end
  end
end
