require "rails_helper"

module Admin
  RSpec.describe PagesController, type: :controller do
    context "when admin" do
      before { logged_in_as_admin }

      describe "PATCH update" do
        context "when update fails" do
          let!(:existing_page) { FactoryBot.create(:page) }
          let(:page) { FactoryBot.create(:page) }
          before do
            patch :update, params: {id: page.id, page: {slug: existing_page.slug}}
          end

          it "responds 200" do
            expect(response.status).to eq 200
          end
        end
      end

      describe "POST create" do
        it "creates a new page" do
          slug = SecureRandom.hex
          post :create, params: {page: {slug: slug, title: "T", name: "N", description: "D"}}
          expect(Page.find_by(slug: slug)).to be
        end
      end
    end
  end
end
