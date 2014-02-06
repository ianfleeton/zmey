require 'spec_helper'

describe PagesController do
  describe 'GET terms' do
    it 'populates @terms from the website config' do
      controller.stub(:website).and_return(
        mock_model(Website, terms_and_conditions: 'T&C')
      )
      get :terms
      expect(assigns(:terms)).to eq 'T&C'
    end
  end
end
