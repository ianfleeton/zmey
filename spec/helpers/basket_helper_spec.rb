require "rails_helper"

RSpec.describe BasketHelper, type: :helper do
  describe "#discount_lines_price_total" do
    subject { helper.discount_lines_price_total }
    context "with undefined @discount_lines" do
      it { should eq 0 }
    end
  end

  describe "#discount_lines_tax_total" do
    subject { helper.discount_lines_tax_total }
    context "with undefined @discount_lines" do
      it { should eq 0 }
    end
  end
end
