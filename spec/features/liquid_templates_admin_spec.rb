require 'rails_helper'

feature 'Liquid Templates admin' do
  let(:website) { FactoryBot.create(:website) }

  background do
    website
    sign_in_as_admin
  end

  let(:liquid_template) { FactoryBot.build(:liquid_template, title: SecureRandom.hex) }

  scenario 'Create Liquid Template' do
    visit admin_liquid_templates_path
    click_link 'New'
    fill_in 'Name',   with: liquid_template.name
    fill_in 'Markup', with: liquid_template.markup
    fill_in 'Title',  with: liquid_template.title
    click_button 'Create Liquid template'
    expect(LiquidTemplate.find_by(name: liquid_template.name, title: liquid_template.title)).to be
  end

  scenario 'Edit Liquid Template' do
    liquid_template.save!
    visit admin_liquid_templates_path
    click_link "Edit #{liquid_template}"
    new_name = SecureRandom.hex
    fill_in 'Name', with: new_name
    click_button 'Update Liquid template'
    expect(LiquidTemplate.find_by(name: new_name)).to be
  end

  scenario 'Delete Liquid Template' do
    liquid_template.save!
    visit admin_liquid_templates_path
    click_link "Delete #{liquid_template}"
    expect(LiquidTemplate.find_by(id: liquid_template.id)).to be_nil
  end
end
