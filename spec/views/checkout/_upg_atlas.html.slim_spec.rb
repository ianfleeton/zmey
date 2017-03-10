require 'rails_helper'

RSpec.describe 'checkout/_upg_atlas.html.slim' do
  let(:website) { FactoryGirl.build(:website) }
  let(:order) { FactoryGirl.build(:order) }

  before do
    allow_any_instance_of(UpgAtlas::FieldList).to receive(:secustring).and_return('encrypted')
    allow(view).to receive(:website).and_return(website)
    assign(:order, order)
    render
  end

  context 'rendered' do
    subject { rendered }
    it { should have_selector "form[action='https://www.secure-server-hosting.com/secutran/secuitems.php'][method='post']" }
  end
end
