require 'rails_helper'

RSpec.describe Admin::ExportController, type: :controller do
  before do
    logged_in_as_admin
  end

  describe 'GET csv' do
    it 'creates a new CSVExporter with the class name' do
      expect(CSVExporter).to receive(:new).with('Product').and_call_original
      get :csv, params: { class_name: 'Product' }
    end

    it 'generates the CSV' do
      exporter = double(CSVExporter).as_null_object
      allow(CSVExporter).to receive(:new).and_return(exporter)
      expect(exporter).to receive(:generate)
      get :csv, params: { class_name: 'Product' }
    end
  end
end
