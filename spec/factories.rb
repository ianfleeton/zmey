FactoryGirl.define do
  factory :admin, class: User do
    sequence(:email) { |n| "admin#{n}@example.org" }
    name      'Admin'
    admin     true
    password  'secret'
  end

  factory :address do
    address_line_1 '123 My Street'
    email_address  'shopper@example.org'
    full_name      'A Shopper'
    postcode       'L0N D0N'
    town_city      'London'
    association    :country
  end

  factory :api_key do
    sequence(:name) { |n| "key-#{n}" }
    association :user
  end

  factory :basket do
  end

  factory :basket_item do
    quantity 1
    association :basket
    association :product
  end

  factory :carousel_slide do
    caption      'A slide'
    link         '#'
    association  :image
    association  :website
    active_from  Date.today - 1.day
    active_until Date.today + 1.day
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

  factory :forum do
    sequence(:name) { |n| "Forum #{n}" }
  end

  factory :image do
    sequence(:name) { |n| "Image #{n}" }
  end

  factory :liquid_template do
    sequence(:name) { |n| "Template #{n}" }
  end

  factory :nominal_code do
    association :website
    sequence(:code) { |n| n.to_s.rjust(4, '0') }
    description 'Nominal Code'
  end

  factory :order do
    email_address           'buyer@example.org'
    delivery_address_line_1 '123 Street'
    delivery_town_city      'Harrogate'
    delivery_postcode       'HG1 9ZZ'
    association :delivery_country, factory: :country
    association :website
    status                  Order::WAITING_FOR_PAYMENT
  end

  factory :order_line do
    quantity    1
    association :order
  end

  factory :page do
    name 'Page Name'
    sequence(:title) { |n| "Page Title #{n}" }
    sequence(:slug)  { |n| "page-#{n}" }
    description 'Meta description...'
    association :website
  end

  factory :payment do
  end

  factory :product do
    name 'Product'
    sequence(:sku) { |n| "SKU#{n}" }
    association :website
  end

  factory :product_group do
    name 'Product Group'
  end

  factory :quantity_price do
    quantity 2
    association :product
  end

  factory :shipping_class do
    sequence(:name) { |n| "Shipping Class #{1}" }
    association :shipping_zone
  end

  factory :shipping_zone do
    sequence(:name) { |n| "Shipping Zone #{n}" }
    association :website
  end

  factory :user do
    sequence(:email) { |n| "shopper#{n}@example.org" }
    name 'User'
    password 'secret'
  end

  factory :webhook do
    association :website
    event 'image_created'
    url 'http://example.org'
  end

  factory :website do
    email 'merchant@example.org'
    name  'Website'
    sequence(:subdomain) { |n| "host#{n}" }
    association :country
  end
end
