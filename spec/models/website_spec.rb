require 'spec_helper'

describe Website do 
  before(:each) do
    @website = Website.new(
      :subdomain => 'bonsai',
      :domain => 'www.artofbonsai.com',
      :name => 'Art of Bonsai',
      :email => 'artofbonsai@example.org',
      :google_analytics_code => 'UA-9999999-9')
  end

  describe 'validations that need an existing record' do
    before do
      @website.save
    end

    it { should validate_uniqueness_of :google_analytics_code }
  end

  it { should validate_presence_of :name }

  describe "validations" do
    it "should be valid with valid attributes" do
      @website.should be_valid
    end

    it "should require a rbswp_installation_id and rbswp_payment_response_password when active" do
      @website.rbswp_active = true
      @website.should_not be_valid

      @website.rbswp_installation_id = '1234'
      @website.should_not be_valid

      @website.rbswp_installation_id = ''
      @website.rbswp_payment_response_password = 'abcde'
      @website.should_not be_valid

      @website.rbswp_installation_id = '1234'
      @website.rbswp_payment_response_password = 'abcde'
      @website.should be_valid
    end
  end

  it "should only accept payment on account when payment on account is accepted and no other payment methods are" do
    @website.accept_payment_on_account = true
    @website.rbswp_active = false
    @website.only_accept_payment_on_account?.should be_true

    @website.rbswp_active = true
    @website.only_accept_payment_on_account?.should be_false

    @website.accept_payment_on_account = false
    @website.rbswp_active = false
    @website.only_accept_payment_on_account?.should be_false
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

    @website.enquiries.first.should == enquiries.last
    @website.enquiries.second.should == enquiries.second
    @website.enquiries.third.should == enquiries.first
  end

  describe '#populate_countries!' do
    it 'should populate itself with a number of countries' do
      @website.save
      @website.populate_countries!
      @website.countries.should have(248).countries
    end
  end
end
