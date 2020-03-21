require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#nl2br" do
    subject { nl2br(text) }

    context "when text has multiple lines" do
      let(:text) { "one\ntwo" }
      it { should eq "one<br>two" }
    end

    context "when text contains HTML" do
      let(:text) { "one <b>two</b>" }
      it { should eq "one &lt;b&gt;two&lt;/b&gt;" }
    end
  end
end
