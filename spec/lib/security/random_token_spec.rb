require "spec_helper"

module Security
  RSpec.describe RandomToken do
    it "generates a string at least 21 characters long" do
      tok = RandomToken.new
      expect(tok.to_s.length).to be >= 21
    end

    it "generates different strings" do
      tok1 = RandomToken.new
      tok2 = RandomToken.new
      expect(tok1.to_s).not_to eq tok2.to_s
    end
  end
end
