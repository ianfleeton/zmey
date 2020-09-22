require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it { should belong_to(:managed_website).optional }
  end

  describe "validations" do
    it { should validate_uniqueness_of(:customer_reference).allow_blank }
  end
end
