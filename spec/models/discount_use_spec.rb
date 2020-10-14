require "rails_helper"

RSpec.describe DiscountUse, type: :model do
  describe "associations" do
    it { should belong_to :discount }
    it { should belong_to :order }
  end
end
