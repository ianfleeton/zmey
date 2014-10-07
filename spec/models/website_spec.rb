require 'rails_helper'

describe Website do
  before(:each) do
    @website = Website.new(
      subdomain: 'bonsai',
      domain: 'www.artofbonsai.com',
      name: 'Art of Bonsai',
      email: 'artofbonsai@example.org',
      google_analytics_code: 'UA-9999999-9',
      country: FactoryGirl.create(:country))
  end

  describe 'validations that need an existing record' do
    before do
      Website.delete_all
      @website.save
    end

    it { should validate_uniqueness_of :google_analytics_code }
    it { should validate_uniqueness_of :subdomain }
  end

  it { should validate_presence_of :email }
  it { should validate_presence_of :name }
  it { should validate_presence_of :subdomain }
  it { should validate_inclusion_of(:custom_view_resolver).in_array(%w{CustomView::DatabaseResolver CustomView::ThemeResolver}) }

  describe "validations" do
    it "should be valid with valid attributes" do
      expect(@website).to be_valid
    end

    it "should require a worldpay_installation_id and worldpay_payment_response_password when active" do
      @website.worldpay_active = true
      expect(@website).to_not be_valid

      @website.worldpay_installation_id = '1234'
      expect(@website).to_not be_valid

      @website.worldpay_installation_id = ''
      @website.worldpay_payment_response_password = 'abcde'
      expect(@website).to_not be_valid

      @website.worldpay_installation_id = '1234'
      @website.worldpay_payment_response_password = 'abcde'
      expect(@website).to be_valid
    end

    it 'validates format of subdomain' do
      ['123host', '123-host', 'HOST123'].each do |valid|
        @website.subdomain = valid
        expect(@website).to be_valid
      end

      ['-123host', 'two.parts'].each do |invalid|
        @website.subdomain = invalid
        expect(@website).not_to be_valid
      end
    end
  end

  it "should only accept payment on account when payment on account is accepted and no other payment methods are" do
    @website.accept_payment_on_account = true
    @website.worldpay_active = false
    expect(@website.only_accept_payment_on_account?).to be_truthy

    @website.worldpay_active = true
    expect(@website.only_accept_payment_on_account?).to be_falsey

    @website.accept_payment_on_account = false
    @website.worldpay_active = false
    expect(@website.only_accept_payment_on_account?).to be_falsey
  end

  it 'orders enquiries in reverse chronological order' do
    @website.save

    params = {name: 'Alice', telephone: '123', email: 'alice@example.org', enquiry: 'Hello'}

    enquiries = []
    enquiries << Enquiry.create!(params)
    enquiries << Enquiry.create!(params)
    enquiries << Enquiry.create!(params)

    [ 1.hour.ago, 5.minutes.ago, 1.minute.ago ].each_with_index do |time, index|
      enquiry = enquiries[index]
      enquiry.created_at = time
      enquiry.website_id = @website.id
      enquiry.save!
    end

    expect(@website.enquiries.first).to eq enquiries.last
    expect(@website.enquiries.second).to eq enquiries.second
    expect(@website.enquiries.third).to eq enquiries.first
  end

  describe '#populate_countries!' do
    it 'should populate itself with a number of countries' do
      @website.save
      @website.populate_countries!
      expect(@website.countries.size).to eq 248
    end
  end

  describe '#image_uploader' do
    let(:params)   { { image: fixture_file_upload('images/red.png'), name: 'Red' } }
    let(:website)  { Website.new }
    let(:uploader) { website.image_uploader(params) }

    it 'returns an ImageUploader' do
      expect(uploader).to be_instance_of ImageUploader
    end

    it 'associates the image with the itself' do
      image = FactoryGirl.create(:image)
      allow(Image).to receive(:new).and_return(image)
      uploader
      expect(image.website).to eq website
    end

    it 'yields the image' do
      image = nil
      website.image_uploader(params) do |yielded|
        image = yielded
      end
      expect(image).to be_instance_of Image
    end
  end

  describe '#active_carousel_slides' do
    it 'returns carousel slides that, based on current time, are currently active' do
      @website.save
      active_slide   = FactoryGirl.build(:carousel_slide, active_from: Date.today - 1.day, active_until: Date.today + 1.day)
      inactive_slide = FactoryGirl.build(:carousel_slide, active_from: Date.today + 1.day, active_until: Date.today + 2.days)
      expired_slide  = FactoryGirl.build(:carousel_slide, active_from: Date.today - 2.days, active_until: Date.today - 1.day)
      @website.carousel_slides << active_slide
      @website.carousel_slides << inactive_slide
      @website.carousel_slides << expired_slide
      expect(@website.active_carousel_slides.count).to eq 1
      expect(@website.active_carousel_slides.first).to eq active_slide
    end
  end

  describe '#build_custom_view_resolver' do
    it 'returns nil when no custom view resolver set' do
      expect(Website.new.build_custom_view_resolver).to be_nil
    end

    it 'builds a new custom view resolver initialized with itself' do
      website = Website.new(custom_view_resolver: 'CustomView::DatabaseResolver')
      expect(CustomView::DatabaseResolver).to receive(:new).with(website).and_call_original
      expect(website.build_custom_view_resolver).to be_instance_of CustomView::DatabaseResolver
    end
  end

  describe '#destroy' do
    it 'destroys associations in an order to prevent restriction dependencies' do
      website = FactoryGirl.create(:website)
      country = FactoryGirl.create(:country, website_id: website.id)
      address = FactoryGirl.create(:address, country_id: country.id)
      user = FactoryGirl.create(:user, website_id: website.id)
      user.addresses << address
      expect { website.destroy }.to_not raise_error
    end

    it 'deletes addresses associated through country' do
      website = FactoryGirl.create(:website)
      country = FactoryGirl.create(:country, website_id: website.id)
      address = FactoryGirl.create(:address, country_id: country.id)
      expect { website.destroy }.to_not raise_error
    end
  end

  describe '#to_s' do
    it 'returns subdomain' do
      expect(Website.new(subdomain: 'xyzzy').to_s).to eq 'xyzzy'
    end
  end
end
