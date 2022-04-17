require "rails_helper"

RSpec.describe SlugHistory, type: :model do
  describe "validations" do
    it { should validate_length_of(:slug).is_at_most(191) }

    it "validate a page with the slug does not already exist" do
      FactoryBot.create(:page, slug: "new-in/menswear")
      page = FactoryBot.create(:page)
      sh = SlugHistory.new(slug: "new-in/menswear", page: page)
      expect(sh.valid?).to be_falsey
      expect(sh.errors[:slug]).to eq ["is already in use by a page"]
    end
  end

  describe "associations" do
    it { should belong_to(:page) }
  end

  describe "before_validation" do
    it "strips leading slashes on slug" do
      sh = SlugHistory.new(slug: "/new-in/menswear")
      sh.valid?
      expect(sh.slug).to eq "new-in/menswear"

      sh = SlugHistory.new(slug: "//new-in/menswear")
      sh.valid?
      expect(sh.slug).to eq "new-in/menswear"

      sh = SlugHistory.new(slug: "new-in/menswear")
      sh.valid?
      expect(sh.slug).to eq "new-in/menswear"
    end
  end

  describe "before_save" do
    it "deletes other histories with same slug" do
      old_sh = FactoryBot.create(:slug_history, slug: "used-before")
      FactoryBot.create(:slug_history, slug: "used-before")
      expect(SlugHistory.exists?(old_sh.id)).to be_falsey
    end
  end

  describe ".add" do
    it "deletes any existing histories with the new slug in it" do
      old_sh = FactoryBot.create(:slug_history, slug: "existing")
      page = FactoryBot.create(:page)
      SlugHistory.add(double(Page, slug: "existing", slug_previously_was: "", id: page.id))
      expect(SlugHistory.exists?(old_sh.id)).to be_falsey
    end

    it "creates a new history with the old slug" do
      page = FactoryBot.create(:page)
      SlugHistory.add(double(Page, slug: "new", slug_previously_was: "old", id: page.id))
      expect(SlugHistory.exists?(slug: "old", page_id: page.id)).to be_truthy
    end
  end
end
