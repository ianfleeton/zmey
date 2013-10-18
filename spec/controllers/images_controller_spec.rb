require 'spec_helper'
require 'shared_examples_for_controllers'

describe ImagesController do
  before { logged_in_as_admin }

  describe 'GET index' do
    it_behaves_like 'a website owned objects finder', :image
  end
end
