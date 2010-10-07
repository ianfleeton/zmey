require File.expand_path(File.dirname(__FILE__) + '/../spec_helper') 

describe Website do 
  before(:each) do
    @website = Website.new(
      :subdomain => 'bonsai',
      :domain => 'www.artofbonsai.com',
      :name => 'Art of Bonsai',
      :email => 'artofbonsai@example.org',
      :google_analytics_code => 'UA-9999999-9')
  end

  describe "validations" do
    it "should be valid with valid attributes" do
      @website.should be_valid
    end

    it "should require a name" do
      @website.name = nil
      @website.should_not be_valid
    end

    it "should keep Google Analytics codes unique" do
      @website.save
      @copy = @website.clone
      @copy.save.should be_false
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
end