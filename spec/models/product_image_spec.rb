require 'rails_helper'

RSpec.describe ProductImage, type: :model do
  it { should validate_presence_of(:image_id) }
  it { should validate_presence_of(:product_id) }

  it { should belong_to(:image) }
  it { should belong_to(:product) }
end
