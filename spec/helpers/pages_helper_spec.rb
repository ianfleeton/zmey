require 'rails_helper'

RSpec.describe PagesHelper, type: :helper do
  describe 'pages_cache_key' do
    it 'returns an array' do
      expect(pages_cache_key).to be_kind_of(Array)
    end
  end
end
