require 'rails_helper'

RSpec.describe Admin::ImportController, type: :controller do
  before do
    FactoryGirl.create(:website)
    logged_in_as_admin
  end

  describe 'POST csv' do
    before do
      post :csv, csv: csv, class_name: 'Product'
    end

    context 'with CSV file of new products' do
      let(:csv) { fixture_file_upload('csv/new-products.csv') }

      it 'imports the data' do
        expect(Product.find_by(name: 'Imported Product')).to be
      end

      it 'sets a flash notice' do
        expect(flash[:notice]).to eq I18n.t('controllers.admin.import.csv.import_in_progress')
      end
    end

    context 'with no CSV file uploaded' do
      let(:csv) { nil }

      it 'sets a flash notice' do
        expect(flash[:notice]).to eq I18n.t('controllers.admin.import.csv.nothing_uploaded')
      end
    end
  end
end
