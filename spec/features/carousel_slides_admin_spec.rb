require 'spec_helper'

feature 'Carousel slides admin' do
  fixtures :websites

  background do
    sign_in_as_admin
  end

  let(:image) { FactoryGirl.create(:image, website: websites(:guitar_gear)) }
  let(:carousel_slide) { FactoryGirl.build(:carousel_slide, image: image, website: websites(:guitar_gear)) }

  scenario 'Create carousel slide' do
    image
    visit admin_carousel_slides_path
    click_link 'New'
    fill_in 'Caption', with: carousel_slide.caption
    fill_in 'Link', with: '#'
    select image.name, from: 'Image'
    click_button 'Create Carousel slide'
    expect(CarouselSlide.find_by(caption: carousel_slide.caption)).to be
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
