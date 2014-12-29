require 'rails_helper'

RSpec.describe ExtraAttribute, type: :model do
  describe '#to_s' do
    it 'returns ClassName#attribute_name' do
      expect(ExtraAttribute.new(attribute_name: 'volume', class_name: 'Product').to_s)
      .to eq 'Product#volume'
    end
  end
end
