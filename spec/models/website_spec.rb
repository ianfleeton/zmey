require "rails_helper"

RSpec.describe Website, type: :model do
  include ActionDispatch::TestProcess

  before(:each) do
    @website = Website.new(
      subdomain: "bonsai",
      domain: "www.artofbonsai.com",
      name: "Art of Bonsai",
      email: "artofbonsai@example.org",
      google_analytics_code: "UA-9999999-9",
      country: FactoryBot.create(:country)
    )
  end

  describe "validations that need an existing record" do
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
  it { should validate_inclusion_of(:custom_view_resolver).in_array(%w[CustomView::DatabaseResolver CustomView::ThemeResolver]) }

  describe "validations" do
    it "should be valid with valid attributes" do
      expect(@website).to be_valid
    end

    it "should require a worldpay_installation_id and worldpay_payment_response_password when active" do
      @website.worldpay_active = true
      expect(@website).to_not be_valid

      @website.worldpay_installation_id = "1234"
      expect(@website).to_not be_valid

      @website.worldpay_installation_id = ""
      @website.worldpay_payment_response_password = "abcde"
      expect(@website).to_not be_valid

      @website.worldpay_installation_id = "1234"
      @website.worldpay_payment_response_password = "abcde"
      expect(@website).to be_valid
    end

    it "validates format of subdomain" do
      ["123host", "123-host", "HOST123"].each do |valid|
        @website.subdomain = valid
        expect(@website).to be_valid
      end

      ["-123host", "two.parts"].each do |invalid|
        @website.subdomain = invalid
        expect(@website).not_to be_valid
      end
    end
  end

  it { should belong_to(:default_shipping_class).class_name("ShippingClass").optional }

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

  describe "#address" do
    it "returns the address as a string formatted in single line" do
      website = Website.new(
        address_line_1: "123 Pythagoras Place",
        address_line_2: "Balby",
        town_city: "Doncaster",
        county: "South Yorkshire",
        postcode: "DN1 2QP"
      )
      expect(website.address).to eq(
        "123 Pythagoras Place, Balby, Doncaster, South Yorkshire, DN1 2QP"
      )
    end
  end

  describe "#image_uploader" do
    let(:params) { {file: fixture_file_upload("images/red.png"), name: "Red"} }
    let(:website) { Website.new }
    let(:uploader) { website.image_uploader(params) }

    it "returns an ImageUploader" do
      expect(uploader).to be_instance_of ImageUploader
    end

    it "yields the image" do
      image = nil
      website.image_uploader(params) do |yielded|
        image = yielded
      end
      expect(image).to be_instance_of Image
    end
  end

  describe "#build_custom_view_resolver" do
    it "returns nil when no custom view resolver set" do
      expect(Website.new.build_custom_view_resolver).to be_nil
    end

    it "builds a new custom view resolver initialized with itself" do
      website = Website.new(custom_view_resolver: "CustomView::DatabaseResolver")
      expect(CustomView::DatabaseResolver).to receive(:new).with(website).and_call_original
      expect(website.build_custom_view_resolver).to be_instance_of CustomView::DatabaseResolver
    end
  end

  describe "#email_address" do
    let(:email) { "merchant@example.com" }
    let(:website) { Website.new(email: email, name: name) }
    subject { website.email_address }
    context 'name is "Merchant"' do
      let(:name) { "Merchant" }
      it { should eq "Merchant <merchant@example.com>" }
    end
    context 'name is "9" Nail Shop"' do
      let(:name) { '9" Nail Shop' }
      it { should eq '"9\\" Nail Shop" <merchant@example.com>' }
    end
  end

  describe "#to_s" do
    it "returns subdomain" do
      expect(Website.new(subdomain: "xyzzy").to_s).to eq "xyzzy"
    end
  end

  describe "#smtp_settings" do
    it "returns a hash of settings usable with ActionMailer" do
      website = Website.new(smtp_username: "u", smtp_password: "p", smtp_host: "h", smtp_port: 465)
      expect(website.smtp_settings).to eq({
        address: "h",
        password: "p",
        port: 465,
        user_name: "u"
      })
    end
  end
end
