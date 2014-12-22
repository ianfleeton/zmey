require 'rails_helper'

feature 'Create extra attribute' do
  let!(:website) { FactoryGirl.create(:website) }

  background do
    sign_in_as_admin
  end

  scenario 'Create extra attribute successfully' do
    given_i_am_on_the_extra_attributes_path
  end

  def given_i_am_on_the_extra_attributes_path
    visit admin_extra_attributes_path
  end
end
