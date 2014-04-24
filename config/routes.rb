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

    resources :quantity_prices, except: [:show]
    resources :shipping_classes, except: [:show]
    resources :shipping_zones, except: [:show]
    resources :users do
    end

    resources :websites
  end

  namespace :api, defaults: {format: :json} do
    namespace :admin do
      resources :orders, only: [:index]

      resources :pages, only: [:create, :index]

      resources :product_placements, only: [:create]

      resources :products, only: [:create]
      delete 'products', to: 'products#delete_all'
    end
  end

  resources :addresses

  post 'basket/add' => 'basket#add', as: :add_to_basket
  get 'basket/checkout', as: :checkout
  post 'basket/enter_coupon' => 'basket#enter_coupon'
  post 'basket/place_order' => 'basket#place_order'
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

  resources :product_groups

  resources :product_group_placements

  resources :product_placements do
    member do
      post 'move_down'
      post 'move_up'
    end
  end

  resources :products, only: [:show] do
    collection do
      get 'google_data_feed'
    end
  end

  resources :sessions do
    get 'destroy', on: :collection
  end
  get 'sign-in' => 'sessions#new', as: :sign_in

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

  # Catch unroutable paths and send to the routing error handler
  get '*a', to: 'application#routing_error'
end
