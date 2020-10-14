require "rails_helper"

RSpec.describe LocationOrdersExceededEntry, type: :model do
  describe "associations" do
    it { should belong_to :location }
  end

  describe "validations" do
    it { should validate_presence_of :exceeded_on }
  end
end
