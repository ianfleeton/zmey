require 'rails_helper'

module Discounts
  RSpec.describe Calculator do
    describe '#initialize' do
      it 'takes three parameters' do
        Calculator.new([Discount.new], ['COUPON'], Basket.new)
      end

      it 'sets nil coupons to an empty array' do
        c = Calculator.new([Discount.new], nil, Basket.new)
        expect(c.coupons).to eq []
      end

      it 'sets @basket to basket' do
        c = Calculator.new([], [], basket = Basket.new)
        expect(c.basket).to eq basket
      end

      it 'sets @discounts to discounts' do
        c = Calculator.new([discount = Discount.new], [], Basket.new)
        expect(c.discounts).to eq [discount]
      end
    end

    describe '#authorized?' do
      let(:c) { Calculator.new([Discount.new], coupons, Basket.new) }
      let(:discount) { Discount.new(coupon: coupon)}
      let(:coupons) { [] }
      subject { c.authorized?(discount) }

      context 'when discount coupon blank' do
        let(:coupon) { '' }
        it { should eq true }
      end

      context 'when discount coupon included in coupons' do
        let(:coupon) { 'COUPON' }
        let(:coupons) { ['COUPON'] }
        it { should eq true }
      end

      context 'when discount coupon not included in coupons' do
        let(:coupon) { 'COUPON' }
        let(:coupons) { ['XYZZY'] }
        it { should eq false }
      end
    end

    describe '#calculate' do
      class FakeCalculator
        def calculate; end
      end

      it 'calculates each authorized discount' do
        auth_discount = Discount.new(coupon: 'COUPON')
        unused_discount = Discount.new(coupon: 'UNUSED')
        c = Calculator.new([auth_discount, unused_discount], ['COUPON'], Basket.new)

        fake_calculator = FakeCalculator.new
        expect(c).to receive(:calculator_for).with(auth_discount).and_return(fake_calculator)
        expect(c).not_to receive(:calculator_for).with(unused_discount)
        expect(fake_calculator).to receive(:calculate)

        c.calculate
      end
    end

    describe '#calculator_for' do
      let(:c) { Calculator.new([Discount.new], ['COUPON'], Basket.new) }
      subject { c.calculator_for(Discount.new(reward_type: reward_type)) }
      context 'reward_type percentage_off_order' do
        let(:reward_type) { 'percentage_off_order' }
        it { should be_instance_of Calculators::PercentageOffOrder }
      end
    end

    describe '#discount_lines' do
      let(:c) { Calculator.new([Discount.new], ['COUPON'], Basket.new) }
      subject { c.discount_lines }

      it { should be_kind_of Array }
    end
  end
end