# frozen_string_literal: true

require "rails_helper"

RSpec.describe WebKitHTMLToPDF do
  describe ".binary" do
    subject { WebKitHTMLToPDF.binary }
    it { should be_instance_of String }
  end
end
