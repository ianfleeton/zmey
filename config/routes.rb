Rails.application.routes.draw do

  namespace :admin do
    get '' => 'admin#index'

    resources :additional_products, except: [:show]
    resources :api_keys, except: [:show] do
      collection do
        get 'retrieve/:name' => 'api_keys#retrieve', format: :json
      end
    end
    resources :carousel_slides, except: [:show] do
      member do
        get 'move_up'
        get 'move_down'
      end
    end
    resources :choices, except: [:show]
    resources :components, except: [:show]
    resources :countries, except: [:show]
    resources :discounts, except: [:show]
    resources :enquiries
    resources :features, except: [:show]
    resources :images
    resources :liquid_templates, except: [:show]

    resources :orders do
      collection do
        get 'purge_old_unpaid'
      end
    end

    resources :order_lines

    resources :pages, except: [:show] do
      collection do
        get 'search_products'
      end

      member do
        get 'move_up'
        get 'move_down'
      end
    end

    resources :products, except: [:show] do
      collection do
        get 'upload_google_data_feed'
      end
    end

    resources :product_groups, except: [:show]

    resources :product_placements do
      member do
        post 'move_down'
        post 'move_up'
      end
    end

    resources :quantity_prices, except: [:show]
    resources :shipping_classes, except: [:show]
    resources :shipping_zones, except: [:show]

    resources :users do
      resources :addresses, shallow: true
    end

    resources :webhooks

    resources :websites
  end

  namespace :api, defaults: {format: :json} do
    namespace :admin do
      delete 'carousel_slides', to: 'carousel_slides#delete_all'

      resources :images, only: [:create, :index, :show]
      delete 'images', to: 'images#delete_all'

      resources :liquid_templates, only: [:create, :show]
      delete 'liquid_templates', to: 'liquid_templates#delete_all'

      resources :order_lines, only: [:show]

      resources :orders, only: [:index, :show]

      resources :pages, only: [:create, :index]
      delete 'pages', to: 'pages#delete_all'

      resources :payments, only: [:index, :show]

      resources :product_placements, only: [:create]
      delete 'product_placements', to: 'product_placements#delete_all'

      resources :products, only: [:create, :index, :show]
      delete 'products', to: 'products#delete_all'

      resources :users, only: [:show, :index]
    end
  end

  resources :addresses do
    collection do
      get 'choose_delivery_address'
    end
    member do
      post 'select_for_delivery'
    end
  end

  get 'basket' => 'basket#index', as: :basket
  post 'basket/add' => 'basket#add', as: :add_to_basket
  post 'basket/add_update_multiple' => 'basket#add_update_multiple', as: :add_update_multiple_basket
  get 'basket/checkout', as: :checkout
  post 'basket/enter_coupon' => 'basket#enter_coupon'
  get 'basket/load/:token' => 'basket#load', as: :load_basket
  post 'basket/place_order' => 'basket#place_order'
  post 'basket/save_and_email' => 'basket#save_and_email', as: :save_and_email_basket
  post 'basket/update' => 'basket#update'
  get 'basket(/:action(.:format))', controller: 'basket'

  resources :enquiries, only: [:create, :new] do
    collection do
      get 'current_time'
      get 'thank_you'
    end
  end

  resources :forums

  resources :orders, only: [:index, :show] do
    collection do
      get 'receipt'
      get 'select_payment_method'
    end
    member do
      get 'invoice'
    end
  end

  resources :payments do
    collection do
      post 'cardsave_callback'
      get 'paypal_auto_return'
      get 'paypal_confirmation'
      get 'sage_pay_failure'
      get 'sage_pay_success'
      post 'rbs_worldpay_callback'
    end
  end

  resources :permutations

  resources :product_group_placements

  resources :products, only: [:show] do
    collection do
      get 'google_data_feed'
    end
  end

  resources :sessions do
    post 'destroy', on: :collection
  end
  get  'sign-in'              => 'sessions#new',         as: :sign_in
  post 'switch_user/:user_id' => 'sessions#switch_user', as: :switch_user

  resources :shipping_table_rows

  get 'sitemap.xml' => 'pages#sitemap', as: 'sitemap', format: 'xml'

  get 'terms' => 'pages#terms', as: :terms

  get 'topics/new/:forum_id' => 'topics#new', as: 'new_topic'
  get 'topics/show/:id' => 'topics#show', as: 'topic'

  resources :topics do
    collection do
      post 'create_reply'
      get 'current_time'
      post 'destroy_post'
      get 'edit_post'
    end
  end

  resources :users, except: [:index, :destroy] do
    collection do
      get 'forgot_password'
      post 'forgot_password_change'
      get 'forgot_password_new'
      post 'forgot_password_send'
    end

    resources :orders
  end

  resources :pages, only: [:show]

  get ':slug' => 'pages#show', as: :slug, constraints: { slug: /[-a-z0-9_\/\.]*/ }

  root controller: 'pages', action: 'show', slug: ''
end
