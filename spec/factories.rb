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

  factory :enquiry do
    name 'Ernie'
    telephone '01234 567890'
    email 'ernie@example.org'
    enquiry 'Do you sell widgets?'
  end

  factory :image do
    sequence(:name) { |n| "Image #{n}" }
  end

  factory :order do
    email_address 'buyer@example.org'
    address_line_1 '123 Street'
    town_city 'Harrogate'
    postcode 'HG1 9ZZ'
  end

  factory :payment do
  end

  factory :product do
    name 'Product'
    sku 'SKU'
  end

  factory :user do
    sequence(:email) { |n| "shopper#{n}@example.org" }
    name 'User'
    password 'secret'
  end

  factory :website do
    name 'Website'
  end
end
