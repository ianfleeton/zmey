shared_examples_for 'an object with extra attributes' do
  describe '.extra_attributes' do
    it 'returns ExtraAttributes for this class' do
      ea1 = ExtraAttribute.create!(attribute_name: 'length', class_name: described_class)
      ea2 = ExtraAttribute.create!(attribute_name: 'length', class_name: ExtraAttribute)
      expect(described_class.extra_attributes).to include(ea1)
      expect(described_class.extra_attributes).not_to include(ea2)
    end
  end

  describe '#extra_attributes' do
    let(:object) { described_class.new(extra: '{"length": "500"}') }
    let(:subject) { object.extra_attributes }

    before do
      ExtraAttribute.create!(attribute_name: 'length', class_name: described_class)
      ExtraAttribute.create!(attribute_name: 'width', class_name: described_class)
    end

    it 'contains values for supplied extra attributes' do
      expect(subject.fetch('length')).to eq '500'
    end

    it 'contains nil values for missing extra attributes' do
      expect(subject.fetch('width')).to be_nil
    end
  end

  describe '#extra_json' do
    it 'handles nil values of extra' do
      expect { described_class.new.extra_json }.not_to raise_error
    end
  end

  describe '#update_extra' do
    let(:object) { described_class.new(extra: '{"subheading": "before", "exists": "already"}') }
    let(:hash) {{
      'subheading' => 'after',
      'bad' => 'ignored',
      'new' => 'inserted'
    }}

    before do
      ExtraAttribute.create!(attribute_name: 'subheading', class_name: described_class)
      ExtraAttribute.create!(attribute_name: 'exists', class_name: described_class)
      ExtraAttribute.create!(attribute_name: 'new', class_name: described_class)
    end

    it 'updates extra' do
      before = object.extra
      object.update_extra(hash)
      expect(object.extra).not_to eq before
    end

    it 'returns true when extra is changed' do
      expect(object.update_extra(hash)).to eq true
    end

    it 'returns false when extra is not changed' do
      expect(described_class.new.update_extra({})).to eq false
    end

    it 'updates existing entries' do
      object.update_extra(hash)
      expect(object.extra_json['subheading']).to eq 'after'
    end

    it 'adds new entries' do
      object.update_extra(hash)
      expect(object.extra_json['new']).to eq 'inserted'
    end

    it 'ignores entries not in ExtraAttribute' do
      object.update_extra(hash)
      expect(object.extra_json['bad']).to be_nil
    end

    it 'preserves values' do
      object.update_extra(hash)
      expect(object.extra_json['exists']).to eq 'already'
    end
  end

  describe '#method_missing' do
    let(:attribute_name) { SecureRandom.hex }
    let(:value) { SecureRandom.hex }
    let(:object) { described_class.new }

    before do
      ExtraAttribute.create!(attribute_name: attribute_name, class_name: described_class)
    end

    it 'provides getters and setters for extra attributes' do
      object.send("#{attribute_name}=".to_sym, value)
      expect(object.send(attribute_name.to_sym)).to eq value
    end

    it 'updates the extra attribute' do
      object.send("#{attribute_name}=".to_sym, value)
      expect(object.extra_json[attribute_name]).to eq value
    end
  end

  context 'import and export' do
    before do
      ExtraAttribute.create!(attribute_name: 'custom_property', class_name: described_class)
    end

    describe '#importable_attributes' do
      it 'includes extra attributes' do
        expect(described_class.importable_attributes).to include 'custom_property'
      end
    end

    describe '#exportable_attributes' do
      it 'includes extra attributes' do
        expect(described_class.importable_attributes).to include 'custom_property'
      end
    end
  end
end
