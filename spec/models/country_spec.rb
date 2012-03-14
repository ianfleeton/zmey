require 'spec_helper'

describe Country do
  before do
    Country.create!(name: 'United Kingdom', iso_3166_1_alpha_2: 'GB')
  end

  it { should validate_uniqueness_of(:iso_3166_1_alpha_2) }
end
