require 'rails_helper'

RSpec.describe Importer do
  class FakeModel; end
  let(:importer) { Importer.new 'FakeModel' }

  describe '#find_object' do
    let(:row) {{
      'sku' => 'CODE'
    }}

    it 'finds an object using the import id' do
      allow(FakeModel).to receive(:import_id).and_return 'sku'
      expect(FakeModel).to receive(:find_by).with('sku' => 'CODE')
      importer.find_object(row)
    end
  end

  describe '#import_id' do
    context 'when class responds to .import_id' do
      before do
        allow(FakeModel).to receive(:import_id).and_return('sku')
      end

      it 'returns this value' do
        expect(importer.import_id).to eq 'sku'
      end
    end

    context 'when the class does not respond to .import_id' do
      it 'returns "id"' do
        expect(importer.import_id).to eq 'id'
      end
    end
  end
end
