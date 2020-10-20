require "rails_helper"

RSpec.describe Image, type: :model do
  describe "#path_for_filename" do
    before do
      allow_any_instance_of(Image).to receive(:directory_path)
        .and_return "/up/images/123"
    end

    subject { Image.new.path_for_filename("image.jpg") }

    it { should eq "/up/images/123/image.jpg" }
  end

  describe "#write_file" do
    it "writes a copy of the supplied image data to disk" do
      img = FactoryBot.create(:image)
      original = "spec/fixtures/images/red.png"
      File.open(original) do |image|
        img.file = image
        img.determine_filename
        img.write_file
      end
      expect(File.read(original)).to eq(
        File.read("public/up/images-test/#{img.id}/image.jpg")
      )
      img.delete_files
    end

    it "updates the md5 hash attribute to match the file data" do
      img = FactoryBot.create(:image)
      original = "spec/fixtures/images/red.png"
      File.open(original) do |image|
        img.file = image
        img.determine_filename
        img.write_file
      end
      expect(img.md5_hash).to eq "9c8dacbf245c6d7f89248c9e39c5d4ba"
      img.delete_files
    end
  end

  describe "#sized_url" do
    context "destination file does not exist" do
      let(:rmagick_image_list) { double(Magick::ImageList).as_null_object }
      before do
        allow(FileTest).to receive(:exist?).and_return(false)
        allow(Magick::ImageList).to receive(:new).and_return(rmagick_image_list)
        allow_any_instance_of(Image)
          .to receive(:original_image)
          .and_return(rmagick_image_list)
      end

      context "method is :longest_side" do
        let(:method) { :longest_side }

        it "calls #size_longest_side" do
          image = Image.new
          expect(image).to receive(:size_longest_side)
            .with(rmagick_image_list, 100)
          image.sized_url(100, :longest_side)
        end
      end
    end
  end

  describe "#sized_item_filename" do
    before do
      allow_any_instance_of(Image).to receive(:extension).and_return("jpg")
    end

    subject { Image.new.sized_item_filename(size, method) }

    context "for size 100 and method :longest_side" do
      let(:size) { 100 }
      let(:method) { :longest_side }
      it { should eq "longest_side.100.jpg" }
    end

    context "for size [200, 100] and method :width" do
      let(:size) { [200, 100] }
      let(:method) { :width }
      it { should eq "width.200x100.jpg" }
    end
  end

  describe ".sized_path" do
    let(:image) { FactoryBot.create(:image) }
    let(:filename) { "image.jpg" }

    subject { Image.sized_path(id, filename) }

    context "when image found" do
      let(:id) { image.id }

      context "when filename is invalid" do
        it { should include(IMAGE_MISSING) }
      end

      context "when filename is valid" do
        let(:filename) { "longest_side.100.jpg" }

        before do
          allow(Image).to receive(:find_by).and_return(image)
          allow(image).to receive(:sized_path).and_return("path")
        end

        it { should eq "path" }
      end
    end

    context "when image missing" do
      let(:id) { image.id + 1 }

      it { should include(IMAGE_MISSING) }
    end
  end

  describe ".parse_filename" do
    subject { Image.parse_filename(filename) }

    context "filename is invalid.jpg" do
      let(:filename) { "invalid.jpg" }
      it { should be_nil }
    end

    context "filename is longest_side.100.jpg" do
      let(:filename) { "longest_side.100.jpg" }
      it { should eq(method: :longest_side, size: 100) }
    end

    context "filename is cropped.640x480.jpg" do
      let(:filename) { "cropped.640x480.jpg" }
      it { should eq(method: :cropped, size: [640, 480]) }
    end
  end

  describe "#destroy" do
    it "removes product_image relationships" do
      i = FactoryBot.create(:image)
      p = FactoryBot.create(:product)
      pi = ProductImage.create!(product: p, image: i)
      i.destroy
      expect(ProductImage.find_by(id: pi.id)).to be_nil
    end
  end
end
