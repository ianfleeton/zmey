require 'rails_helper'

feature 'Delete offline payment method' do
  let!(:website) { FactoryBot.create(:website) }
  let!(:offline_payment_method) { FactoryBot.create(:offline_payment_method) }

  background do
    sign_in_as_admin
  end

  scenario 'Delete offline payment method' do
    given_i_am_on_the_offline_payment_methods_page
    when_i_click_on_delete
    then_the_payment_method_is_deleted
  end

  def given_i_am_on_the_offline_payment_methods_page
    visit admin_offline_payment_methods_path
  end

  def when_i_click_on_delete
    click_link "Delete #{offline_payment_method}"
  end

  def then_the_payment_method_is_deleted
    expect(OfflinePaymentMethod.find_by(id: offline_payment_method.id)).to be_nil
  end
end
