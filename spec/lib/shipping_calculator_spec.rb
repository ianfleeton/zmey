require 'rails_helper'

RSpec.describe ShippingCalculator do
  let(:apply_shipping?) { false }
  let(:basket) { FactoryGirl.create(:basket) }
  let(:default_amount) { 12.34 }
  let(:shipping_class) { nil }
  let(:amount_for_basket) { 23.45 }
  let(:options) {{
    basket: basket,
    default_amount: default_amount,
    shipping_class: shipping_class,
    add_tax: true
  }}

  before do
    allow(basket).to receive(:apply_shipping?).and_return(apply_shipping?)
    if shipping_class
      allow(shipping_class).to receive(:amount_for_basket).with(basket).and_return amount_for_basket
    end
  end

  describe '#amount' do
    subject { ShippingCalculator.new(options).amount }

    context 'when basket does not have shipping applied' do
      let(:apply_shipping?) { false }
      it { should eq 0 }
    end

    context 'when basket does have shipping applied' do
      let(:apply_shipping?) { true }

      context 'with shipping class' do
        let(:shipping_class) { FactoryGirl.create(:shipping_class) }
        it { should eq amount_for_basket }
      end

      context 'without shipping class' do
        it { should eq default_amount }
      end
    end
  end

  describe '#tax_amount' do
    let(:calculator) { ShippingCalculator.new(options) }
    let(:shipping_class) { FactoryGirl.create(:shipping_class, charge_tax: charge_tax) }
    subject { calculator.tax_amount }

    context 'when shipping class charges tax' do
      let(:charge_tax) { true }

      context 'when add_tax true' do
        let(:add_tax) { true }
        it { should eq 0 }
      end

      context 'when add_tax false' do
        let(:add_tax) { false }
        before { allow(calculator).to receive(:amount).and_return(4) }
        it { should eq 0.8 }
      end
    end

    context 'when shipping class does not charge tax' do
      let(:charge_tax) { false }

      context 'when add_tax true' do
        let(:add_tax) { true }
        it { should eq 0 }
      end

      context 'when add_tax false' do
        let(:add_tax) { false }
        before { allow(calculator).to receive(:amount).and_return(4) }
        it { should eq 0 }
      end
    end
  end
end
