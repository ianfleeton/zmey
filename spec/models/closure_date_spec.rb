require "rails_helper"

RSpec.describe ClosureDate, type: :model do
  describe "validations" do
    it { should validate_presence_of(:closed_on) }
  end
end
