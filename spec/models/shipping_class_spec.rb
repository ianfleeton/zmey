require 'rails_helper'

describe ShippingClass do
  describe '#amount_for_basket' do
    let(:shipping_class) { FactoryGirl.create(:shipping_class, table_rate_method: table_rate_method) }
    let(:total) { 0 }
    let(:weight) { 0 }
    let(:basket) { FactoryGirl.create(:basket) }

    subject { shipping_class.amount_for_basket(basket) }

    before do
      ShippingTableRow.create!(shipping_class: shipping_class, trigger_value:  0, amount:  5)
      ShippingTableRow.create!(shipping_class: shipping_class, trigger_value: 10, amount: 15)
      ShippingTableRow.create!(shipping_class: shipping_class, trigger_value: 20, amount: 25)
      ShippingTableRow.create!(shipping_class: shipping_class, trigger_value: 30, amount: 35)
      allow(basket).to receive(:total).with(true).and_return(total)
      allow(basket).to receive(:weight).and_return(weight)
    end

    context 'by basket total' do
      let(:table_rate_method) { 'basket_total' }

      context 'total is 3' do
        let(:total) { 3 }
        it { should eq 5 }
      end

      context 'total is 23' do
        let(:total) { 23 }
        it { should eq 25 }
      end
    end

    context 'by weight' do
      let(:table_rate_method) { 'weight' }

      context 'weight is 13' do
        let(:weight) { 13 }
        it { should eq 15 }
      end

      context 'weight is 33' do
        let(:weight) { 33 }
        it { should eq 35 }
      end
    end
  end

  describe '#to_s' do
    it 'returns its name' do
      expect(ShippingClass.new(name: 'First Class').to_s).to eq 'First Class'
    end
  end
end
