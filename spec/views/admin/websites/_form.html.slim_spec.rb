require 'rails_helper'

RSpec.describe 'admin/websites/_form.html.slim', type: :view do
  before do
    assign(:website_subject, Website.new)
    allow(view).to receive(:website).and_return(Website.new)
  end

  context 'rendered' do
    before do
      render partial: 'admin/websites/form', locals: { submit_label: 'Save' }
    end

    subject { rendered }

    it { should have_selector "input[type=text][name='website[upg_atlas_secuphrase]']" }
  end
end
