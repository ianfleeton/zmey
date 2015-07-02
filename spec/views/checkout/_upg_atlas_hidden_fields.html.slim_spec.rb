require 'rails_helper'

RSpec.describe 'checkout/_upg_atlas_hidden_fields.html.slim', type: :view do
  let(:website) { FactoryGirl.build(
    :website,
    upg_atlas_check_code: 'CHECKCODE',
    upg_atlas_filename: 'payment.html',
    upg_atlas_sh_reference: 'SH12345'
  ) }
  let(:order) { FactoryGirl.create(:order) }

  before do
    allow_any_instance_of(UpgAtlas::FieldList).to receive(:secustring).and_return('encrypted')
    allow(view).to receive(:website).and_return(website)
    assign(:order, order)
    render
  end

  it 'renders' do
    render
  end
end
