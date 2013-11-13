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

  factory :choice do
    name 'Green'
    association :feature
  end

  factory :component do
    name 'Component'
    association :product
  end

  factory :country do
    name 'Country'
    sequence(:iso_3166_1_alpha_2) { |n| n.to_s(36).rjust(2, '0') }
  end

  factory :discount do
    name 'Discount'
  end

  factory :enquiry do
    name 'Ernie'
    telephone '01234 567890'
    email 'ernie@example.org'
    enquiry 'Do you sell widgets?'
  end

  factory :feature do
    name 'Colour'
    association :product
  end

  factory :image do
    sequence(:name) { |n| "Image #{n}" }
  end

  factory :liquid_template do
    sequence(:name) { |n| "Template #{n}" }
  end

  factory :order do
    email_address 'buyer@example.org'
    address_line_1 '123 Street'
    town_city 'Harrogate'
    postcode 'HG1 9ZZ'
    association :country
  end

  factory :payment do
  end

  factory :product do
    name 'Product'
    sku 'SKU'
  end

  factory :quantity_price do
    quantity 2
    association :product
  end

  factory :user do
    sequence(:email) { |n| "shopper#{n}@example.org" }
    name 'User'
    password 'secret'
  end

  factory :website do
    name 'Website'
    association :country
  end
end
