require 'rails_helper'

RSpec.describe Admin::ExtraAttributesHelper, type: :helper do
  describe '#extra_attribute_field' do
    let(:object) { Page.new(extra: '{"discount_rate": "10"}') }
    let(:extra_attribute) { ExtraAttribute.create(attribute_name: 'discount_rate', class_name: 'Page') }

    subject { extra_attribute_field(object, extra_attribute) }

    it { is_expected.to have_selector('div.form-group') }
    it { is_expected.to have_selector('label[for="discount_rate"]', text: 'Discount rate') }
    it { is_expected.to have_selector('input[name="discount_rate"]') }
    it { is_expected.to have_selector('input[id="discount_rate"]') }
    it { is_expected.to have_selector('input[value="10"]') }
  end
end
