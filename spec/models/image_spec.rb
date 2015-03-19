require 'rails_helper'

RSpec.describe Image, type: :model do
  describe 'sized_image_filename' do
    before { allow_any_instance_of(Image).to receive(:extension).and_return('jpg') }

    subject { Image.new.sized_image_filename(size, method) }

    context 'for size 100 and method :longest_side' do
      let(:size) { 100 }
      let(:method) { :longest_side }
      it { should eq 'longest_side_100.jpg' }
    end

    context 'for size [200, 100] and method :width' do
      let(:size) { [200, 100] }
      let(:method) { :width }
      it { should eq 'width_200x100.jpg' }
    end
  end
end
