shared_examples "an extra attributes form" do |class_name|
  let(:attribute_name) { SecureRandom.hex }

  before do
    FactoryBot.create(:extra_attribute, class_name: class_name, attribute_name: attribute_name)
  end

  it "renders text fields for extra attributes" do
    render
    expect(rendered).to have_selector "input##{attribute_name}"
  end
end
