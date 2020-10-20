require "rails_helper"

RSpec.describe Admin::ImagesController, type: :controller do
  before do
    logged_in_as_admin
  end

  describe "GET index" do
  end

  describe "POST create" do
    let(:red_image) { fixture_file_upload("images/red.png") }

    def post_create
      post :create, params: {image: {"file" => red_image, "name" => "red"}}
    end

    it "creates a new ImageUploader" do
      expect(ImageUploader).to receive(:new)
        .and_return double(ImageUploader).as_null_object
      post_create
    end

    it "sets a flash notice stating how many images were uploaded" do
      allow_any_instance_of(ImageUploader).to receive(:images).and_return [Image.new]
      post_create
      expect(flash[:notice]).to eq "1 image uploaded."
    end

    context "when some images uploaded" do
      before do
        allow_any_instance_of(Image).to receive(:save).and_return true
      end

      it "redirects to images index" do
        post_create
        expect(response).to redirect_to admin_images_path
      end
    end
  end
end
