require 'rails_helper'

RSpec.describe '/error', type: :request do
  before { FactoryGirl.create(:website) }

  it 'raises an exception' do
    expect { get '/error' }.to raise_error
  end
end
