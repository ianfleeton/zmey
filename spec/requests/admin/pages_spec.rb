# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Pages admin", type: :request do
  before do
    administrator = FactoryBot.create(:administrator)
    sign_in administrator
  end

  describe "GET /admin/pages" do
    it "renders a link to export pages to CSV" do
      get "/admin/pages"
      assert_select(
        "a[href='#{csv_admin_export_index_path(class_name: "Page")}']"
      )
    end
  end

  describe "GET /admin/pages/:id/edit" do
    let(:page) { FactoryBot.create(:page) }

    context "with slug histories" do
      let!(:sh) { SlugHistory.create!(page: page, slug: "old/slug") }

      it "lists slug histories with a delete button" do
        get edit_admin_page_path(page)
        assert_select ".slug-histories" do
          assert_select ".slug", text: "old/slug"
          assert_select(
            "a[href='#{admin_slug_history_path(sh)}'][data-method='delete']"
          )
        end
      end
    end
  end

  describe "GET /admin/pages/new?parent_id=:parent_id" do
    it "preselects the parent" do
      parent = FactoryBot.create(:page)
      get "/admin/pages/new?parent_id=#{parent.id}"
      assert_select "option[selected]", text: parent.name
    end
  end

  describe "GET /admin/pages/new_shortcut?parent_id=:parent_id" do
    let(:parent) { FactoryBot.create(:page) }

    it "renders a form" do
      get "/admin/pages/new_shortcut?parent_id=#{parent.id}"
      assert_select "input#parent_id[value='#{parent.id}']"
      assert_select "input#name"
      assert_select 'select[name="target_id"]'
    end
  end

  describe "POST /admin/pages/create_shortcut" do
    let(:parent) { FactoryBot.create(:page) }
    let(:target) { FactoryBot.create(:page) }

    def perform
      post "/admin/pages/create_shortcut",
        params: {name: "Name", parent_id: parent.id, target_id: target.id}
    end

    it "creates a new shortcut page" do
      perform
      shortcut = Page.last
      expect(shortcut.name).to eq "Name"
      expect(shortcut.parent).to eq parent
      expect(shortcut.canonical_page).to eq target
    end

    it "redirects to the page index for the parent" do
      perform
      expect(response).to redirect_to admin_pages_path(parent_id: parent)
    end

    it "sets a flash notice" do
      perform
      expect(flash[:notice]).to eq "Shortcut created."
    end

    context "with a duplicate name" do
      before { FactoryBot.create(:page, name: "Name", parent: parent) }

      it "redirects to #new_shortcut" do
        perform
        expect(response)
          .to redirect_to new_shortcut_admin_pages_path(parent_id: parent.id)
      end

      it "sets a flash alert" do
        perform
        expect(flash[:alert]).to eq I18n.t(
          "controllers.admin.pages.create_shortcut.duplicate_name"
        )
      end
    end
  end

  describe "GET /admin/pages/search" do
    it "returns JSON for pages matching the query" do
      page = FactoryBot.build(:page)
      expect(Page).to receive(:admin_search).with("query").and_return([page])
      get "/admin/pages/search", params: {query: "query"}
      parsed = JSON.parse(response.body)
      expect(parsed.length).to eq 1
      expect(parsed[0]["title"]).to eq page.title
    end
  end
end
