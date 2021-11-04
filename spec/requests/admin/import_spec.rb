# frozen_string_literal: true

require "rails_helper"
require "sidekiq/testing"

RSpec.describe Admin::ImportController, type: :request do
  before do
    administrator = FactoryBot.create(:administrator)
    sign_in administrator
  end

  describe "POST /admin/import/csv" do
    let(:class_name) { "Product" }

    before do
      Sidekiq::Testing.inline!
      post "/admin/import/csv", params: {csv: csv, class_name: class_name}
    end

    after { Sidekiq::Testing.fake! }

    context "with CSV file of new products" do
      let(:csv) { Rack::Test::UploadedFile.new("spec/fixtures/csv/new-products.csv") }

      it "imports the data" do
        expect(Product.find_by(name: "Imported Product")).to be
      end

      it "sets a flash notice" do
        expect(flash[:notice]).to eq I18n.t("controllers.admin.import.csv.import_in_progress")
      end

      context "with a class name not in the allow list" do
        let(:class_name) { "Payment" }

        it "responds 403 Forbidden" do
          expect(response.status).to eq 403
        end
      end
    end

    context "with no CSV file uploaded" do
      let(:csv) { nil }

      it "sets a flash notice" do
        expect(flash[:notice]).to eq I18n.t("controllers.admin.import.csv.nothing_uploaded")
      end
    end
  end
end
