require 'rails_helper'

RSpec.describe WebKitHTMLToPDF do
  describe '.binary' do
    before do
      allow(WebKitHTMLToPDF).to receive(:ruby_platform).and_return(ruby_platform)
    end
    subject { WebKitHTMLToPDF.binary }

    context 'RUBY_PLATFORM is x86_64-darwin14' do
      let(:ruby_platform) { 'x86_64-darwin14' }
      it { should eq './wkhtmltopdf-macosx'}
    end

    context 'RUBY_PLATFORM is x86_64-linux' do
      let(:ruby_platform) { 'x86_64-linux' }
      it { should eq 'wkhtmltopdf' }
    end
  end
end
