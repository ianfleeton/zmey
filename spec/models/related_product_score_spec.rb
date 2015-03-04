require 'rails_helper'

RSpec.describe RelatedProductScore, type: :model do
  it { should validate_presence_of(:product_id) }
  it { should validate_presence_of(:related_product_id) }
  it { should validate_presence_of(:score) }

  it { should belong_to(:product) }
  it { should belong_to(:related_product).class_name('Product') }
end
