require "rails_helper"

RSpec.describe OrderComment, type: :model do
  it { should validate_presence_of :order_id }
  it { should belong_to(:order).inverse_of(:order_comments) }
end
