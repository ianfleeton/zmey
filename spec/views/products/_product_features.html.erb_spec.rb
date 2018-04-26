require 'rails_helper'

RSpec.describe 'products/_product_features.html.erb', type: :view do
  context 'feature with radio buttons' do
    let(:product) { FactoryBot.create(:product) }

    before do
      feature = FactoryBot.create(:feature, product: product, ui_type: Feature::RADIO_BUTTONS)
      FactoryBot.create(:choice, feature: feature)
      allow(view).to receive(:product).and_return(product)
      render
    end

    it 'renders radio buttons' do
      expect(rendered).to have_selector 'input[type=radio]'
    end
  end
end
