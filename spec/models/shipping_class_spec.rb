require 'rails_helper'

RSpec.describe ShippingClass, type: :model do
  it { should have_many(:shipping_zones).with_foreign_key('default_shipping_class_id') }
  it { should have_many(:websites).with_foreign_key('default_shipping_class_id') }

  describe '#amount_for_basket' do
    let(:shipping_class) { FactoryBot.create(:shipping_class, table_rate_method: table_rate_method) }
    let(:total) { 0 }
    let(:weight) { 0 }
    let(:basket) { FactoryBot.create(:basket) }

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

  describe '#valid_for_size?' do
    let(:allow_oversize) { true }
    let(:basket) { Basket.new }
    let(:shipping_class) { ShippingClass.new(allow_oversize: allow_oversize) }
    subject { shipping_class.valid_for_size?(basket) }

    before do
      allow(basket).to receive(:oversize?).and_return(oversize?)
    end

    context 'shipping class allows oversize' do
      let(:allow_oversize) { true }
      context 'basket is oversize' do
        let(:oversize?) { true }
        it { should eq true }
      end
    end

    context 'shipping class disallows oversize' do
      let(:allow_oversize) { false }
      context 'basket is oversize' do
        let(:oversize?) { true }
        it { should eq false }
      end
      context 'basket is normal size' do
        let(:oversize?) { false }
        it { should eq true }
      end
    end
  end

  describe '#to_s' do
    it 'returns its name' do
      expect(ShippingClass.new(name: 'First Class').to_s).to eq 'First Class'
    end
  end
end
