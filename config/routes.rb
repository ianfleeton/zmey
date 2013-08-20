YeslWebsite::Application.routes.draw do

  resources :addresses

  post 'basket/add' => 'basket#add', as: :add_to_basket
  post 'basket/enter_coupon' => 'basket#enter_coupon'
  post 'basket/place_order' => 'basket#place_order'
  post 'basket/update' => 'basket#update'
  get 'basket(/:action(.:format))', controller: 'basket'

  resources :carousel_slides

  resources :choices

  resources :components

  resources :countries

  resources :discounts

  resources :enquiries do
    collection do
      get 'current_time'
      get 'thank_you'
    end
  end

  resources :features

  resources :additional_products

  resources :forums

  resources :images

  resources :liquid_templates

  resources :orders do
    collection do
      get 'my'
      get 'purge_old_unpaid'
      get 'receipt'
      get 'select_payment_method'
    end
    member do
      get 'invoice'
    end
  end

  resources :order_lines

  resources :payments do
    collection do
      post 'cardsave_callback'
      get 'paypal_auto_return'
      get 'paypal_confirmation'
      post 'rbs_worldpay_callback'
    end
  end

  resources :permutations

  resources :product_groups

  resources :product_group_placements

  resources :product_placements do
    collection do
      post 'move_down'
      post 'move_up'
    end
  end

  resources :products do
    collection do
      get 'google_data_feed'
      get 'upload_google_data_feed'
    end
  end

  resources :quantity_prices

  resources :sessions do
    get 'destroy', :on => :collection
  end

  resources :shipping_classes

  resources :shipping_table_rows

  resources :shipping_zones

  get 'sitemap.xml' => 'pages#sitemap', :as => 'sitemap', :format => 'xml'

  get 'terms' => 'pages#terms', :as => :terms

  get 'topics/new/:forum_id' => 'topics#new', :as => 'new_topic'
  get 'topics/show/:id' => 'topics#show', :as => 'topic'

  resources :topics

  resources :users do
    collection do
      get 'forgot_password'
      get 'forgot_password_new'
      post 'forgot_password_send'
    end

    resources :orders
  end

  resources :websites

  resources :pages do
    member do
      get 'move_up'
      get 'move_down'
    end
    post 'destroy', :on => :member
  end
  get ':slug' => 'pages#show', as: :slug, :constraints => { :slug => /[-a-z0-9]*/ }

  root :controller => 'pages', :action => 'show', :slug => ''

  # Catch unroutable paths and send to the routing error handler
  get '*a', to: 'application#routing_error'
end
