require 'rails_helper'

RSpec.describe 'Search for product' do
  let!(:product) { FactoryBot.create(:product, name: 'Organic Cotton Romper') }

  before do
    FactoryBot.create(:website)
    sign_in_as_admin
  end

  scenario 'Search for and navigate to product', js: true do
    given_i_am_on_the_product_index
    and_i_search_for 'Organic'
    when_i_click_on 'Organic Cotton Romper'
    then_i_should_be_on_the_edit_product_page
  end

  def given_i_am_on_the_product_index
    visit admin_products_path
  end

  def and_i_search_for query
    fill_in 'query', with: query
    click_button 'Search'
  end

  def when_i_click_on link_text
    within(:css, '#search-results') do
      click_link link_text
    end
  end

  def then_i_should_be_on_the_edit_product_page
    expect(page).to have_css(:h1, text: 'Edit Product')
  end
end
