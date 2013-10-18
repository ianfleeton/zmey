FactoryGirl.define do
  factory :admin, class: User do
    name      'Admin'
    admin     true
    email     'admin@example.org'
    password  'secret'
  end

  factory :carousel_slide do
    caption 'A slide'
    link    '#'
    association :image
  end

  factory :component do
    name 'Component'
    association :product
  end

  factory :image do
    name 'Image'
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
