FactoryGirl.define do
  factory :component do
    name 'Component'
    association :product
  end

  factory :product do
    name 'Product'
    sku 'SKU'
  end

  factory :user do
    name 'User'
    password 'secret'
  end
end
