require "rails_helper"

RSpec.describe ShippingZone, type: :model do
  it { should validate_presence_of(:name) }

  it { should belong_to(:default_shipping_class).class_name("ShippingClass").optional }
end
