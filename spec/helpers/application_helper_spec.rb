require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  include ERB::Util

  describe "#formatted_time" do
    subject { formatted_time(time) }

    context "when time is nil" do
      let(:time) { nil }
      it { should eq "" }
    end

    context "when time is 2016-08-19 09-18-00" do
      let(:time) { Time.new(2016, 8, 19, 9, 18, 0) }
      it { should eq "19 August 2016 -  9:18 am" }
    end
  end

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

    context "when text contains carriage returns" do
      let(:text) { "one\r\ntwo" }
      it { should eq "one<br>two" }
    end
  end
end
