require 'rails_helper'

feature 'Add order comments' do
  let(:order) { FactoryBot.create(:order) }

  before do
    FactoryBot.create(:website)
    sign_in_as_admin
  end

  scenario 'Add order comments when editing order' do
    visit edit_admin_order_path(order)
    click_link 'Add Comment'
    fill_in 'Comment', with: 'Refund requested'
    click_button 'Save'
    expect(OrderComment.find_by(comment: 'Refund requested')).to be
  end
end
