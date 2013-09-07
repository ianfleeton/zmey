require 'spec_helper'

describe 'products/_admin_controls.html.erb' do
  let(:product) { mock_model(Product).as_null_object }

  context 'when admin or manager' do
    before do
      view.stub(:admin_or_manager?).and_return(true)
    end

    it 'renders' do
      render 'products/admin_controls', product: product
    end
  end
end
