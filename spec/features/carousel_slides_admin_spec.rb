require 'rails_helper'

feature 'Carousel slides admin' do
  let(:website) { FactoryGirl.create(:website) }

  background do
    Website.delete_all
    website
    sign_in_as_admin
  end

  let(:image) { FactoryGirl.create(:image, website: website) }
  let(:carousel_slide) { FactoryGirl.build(:carousel_slide, image: image) }

  scenario 'Create carousel slide', js: true do
    image
    visit admin_carousel_slides_path
    click_link 'New'
    fill_in 'Caption', with: carousel_slide.caption
    fill_in 'Link', with: '#'
    click_button 'Pick'
    click_link "image-#{image.id}"

    select Date.today.year, from: :carousel_slide_active_from_1i
    select 'January',       from: :carousel_slide_active_from_2i
    select '1',             from: :carousel_slide_active_from_3i
    select '00',            from: :carousel_slide_active_from_4i
    select '00',            from: :carousel_slide_active_from_5i

    select Date.today.year, from: :carousel_slide_active_until_1i
    select 'December',      from: :carousel_slide_active_until_2i
    select '31',            from: :carousel_slide_active_until_3i
    select '23',            from: :carousel_slide_active_until_4i
    select '59',            from: :carousel_slide_active_until_5i

    click_button 'Create Carousel slide'
    expect(CarouselSlide.find_by(
      caption: carousel_slide.caption,
      active_from:  DateTime.new(Date.today.year, 1, 1, 0, 0),
      active_until: DateTime.new(Date.today.year, 12, 31, 23, 59)
    )).to be
  end

  scenario 'Edit carousel slide' do
    carousel_slide.save
    visit admin_carousel_slides_path
    click_link "Edit #{carousel_slide}"
    new_caption = SecureRandom.hex
    fill_in 'Caption', with: new_caption
    click_button 'Update Carousel slide'
    expect(CarouselSlide.find_by(caption: new_caption)).to be
  end

  scenario 'Delete carousel slide' do
    carousel_slide.save
    visit admin_carousel_slides_path
    click_link "Delete #{carousel_slide}"
    expect(CarouselSlide.find_by(caption: carousel_slide.caption)).to be_nil
  end
end
