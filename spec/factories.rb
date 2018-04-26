FactoryBot.define do
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

  factory :random_address, class: Address do
    email_address   "#{SecureRandom.hex}@example.org"
    full_name       SecureRandom.hex
    company         SecureRandom.hex
    address_line_1  SecureRandom.hex
    address_line_2  SecureRandom.hex
    address_line_3  SecureRandom.hex
    town_city       SecureRandom.hex
    county          SecureRandom.hex
    postcode        SecureRandom.hex
    association     :country
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
    active_from  Date.today - 1.day
    active_until Date.today + 1.day
  end

  factory :choice do
    sequence(:name) { |n| "Choice #{n}" }
    association :feature
  end

  factory :component do
    name 'Component'
    association :product
  end

  factory :country do
    sequence(:name) { |n| "Country #{n}" }
    sequence(:iso_3166_1_alpha_2) { |n| (n % 1296).to_s(36).rjust(2, '0') }
  end

  factory :discount do
    name 'Discount'
    reward_type 'percentage_off_order'
  end

  factory :enquiry do
    name 'Ernie'
    telephone '01234 567890'
    email 'ernie@example.org'
    enquiry 'Do you sell widgets?'
  end

  factory :extra_attribute do
    class_name "ClassName"
    attribute_name "attribute_name"
  end

  factory :feature do
    name 'Colour'
    association :product
    ui_type Feature::TEXT_FIELD
  end

  factory :image do
    sequence(:name) { |n| "Image #{n}" }
  end

  factory :liquid_template do
    sequence(:name) { |n| "Template #{n}" }
  end

  factory :offline_payment_method do
    sequence(:name) { |n| "Payment Method #{n}" }
  end

  factory :order do
    email_address           'buyer@example.org'
    billing_address_line_1  '123 Street'
    billing_town_city       'Harrogate'
    billing_postcode        'HG1 9ZZ'
    delivery_address_line_1 '123 Street'
    delivery_town_city      'Harrogate'
    delivery_postcode       'HG1 9ZZ'
    association :billing_country,  factory: :country
    association :delivery_country, factory: :country
    status                  Enums::PaymentStatus::WAITING_FOR_PAYMENT
  end

  factory :order_comment do
    association :order
    comment "MyText"
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
  end

  factory :payment do
    amount 0
  end

  factory :product do
    name 'Product'
    sequence(:sku) { |n| "SKU#{n}" }
  end

  factory :product_group do
    sequence(:name) { |n| "Product Group #{n}" }
  end

  factory :product_group_placement do
    association :product_group
    association :product
  end

  factory :product_image do
    association :product
    association :image
  end

  factory :quantity_price do
    quantity 2
    association :product
  end

  factory :shipment do
    association :order
  end

  factory :shipping_class do
    sequence(:name) { |n| "Shipping Class #{1}" }
    association :shipping_zone
  end

  factory :shipping_table_row do
    sequence(:trigger_value)
    association :shipping_class
  end

  factory :shipping_zone do
    sequence(:name) { |n| "Shipping Zone #{n}" }
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
