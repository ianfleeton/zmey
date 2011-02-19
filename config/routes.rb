YeslWebsite::Application.routes.draw do

  resources :addresses

  match 'basket/add' => 'basket#add', :as => :add_to_basket
  match 'basket(/:action(.:format))', :controller => 'basket'

  resources :choices

  resources :countries

  resources :discounts

  resources :enquiries do
    collection do
      get 'current_time'
      get 'thank_you'
    end
  end

  resources :features

  resources :forums

  resources :images

  resources :orders do
    collection do
      get 'my'
      get 'purge_old_unpaid'
      get 'receipt'
      get 'select_payment_method'
    end
  end

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

  match 'sitemap.xml' => 'pages#sitemap', :as => 'sitemap'

  match 'terms' => 'pages#terms', :as => :terms

  match 'topics/new/:forum_id' => 'topics#new', :as => 'new_topic'
  match 'topics/show/:id' => 'topics#show', :as => 'topic'

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
  end
  match ':slug' => 'pages#show', :as => :slug, :constraints => { :slug => /[a-z]*/ }

  root :controller => 'pages', :action => 'show', :slug => ''
end
