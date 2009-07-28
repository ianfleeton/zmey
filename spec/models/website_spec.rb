require File.expand_path(File.dirname(__FILE__) + '/../spec_helper') 

describe Website do 
  describe "validations" do
    before(:each) do
      @website = Website.new(
        :subdomain => 'bonsai',
        :domain => 'www.artofbonsai.com',
        :name => 'Art of Bonsai',
        :email => 'artofbonsai@example.org',
        :google_analytics_code => 'UA-9999999-9')
    end

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

  end
end