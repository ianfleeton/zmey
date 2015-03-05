shared_examples_for 'an API paginator' do |opts|
  let(:collection) { opts[:class].to_s.downcase.pluralize }

  context 'with more items than default page size' do
    let(:num_items) { default_page_size + 1 }

    it 'returns limited items' do
      expect(json[collection].length).to eq default_page_size
    end

    it 'states total count of items' do
      expect(json['count']).to eq num_items
    end

    context 'with page_size matching number of items' do
      let(:page_size) { num_items }

      it 'returns all items' do
        expect(json[collection].length).to eq num_items
      end
    end

    context 'with page set to 2 and page_size set to 1' do
      let(:page)      { 2 }
      let(:page_size) { 1 }

      it 'returns the second item only' do
        expect(json[collection].length).to eq 1
        expect(json[collection][0]['id']).to eq opts[:class].second.id
      end
    end
  end
end
