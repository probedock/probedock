# Copyright (c) 2012-2014 Lotaris SA
#
# This file is part of ROX Center.
#
# ROX Center is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ROX Center is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with ROX Center.  If not, see <http://www.gnu.org/licenses/>.
require 'resque/server'

ROXCenter::Application.routes.draw do

  # resque frontend
  resque_constraint = lambda do |req|
    user = req.env['warden'].authenticate!
    user and user.has_role?(:admin) # restrict to admins
  end
  constraints resque_constraint do
    mount Resque::Server.new, :at => "/resque"
  end

  root :to => 'home#index'

  match '/ping' => 'home#ping', via: :get, as: :ping
  match :maintenance, to: 'home#maintenance', via: [ :post, :delete ]
  resources :api_keys, controller: :account_api_keys, only: [ :index, :create, :show, :update, :destroy ]

  resource :data, only: [] do
    get :status
    get :general
    get :current_test_metrics
    get :latest_test_runs
    match :test_counters, via: [ :get, :post ]
  end

  namespace :go, module: nil, controller: :go do
    get :project
    get :run
    get :test
  end

  devise_for :users, path_names: { sign_in: 'login', sign_out: 'logout', sign_up: 'register' }
  match 'status' => 'home#status', :via => :get

  # pages
  resource :account, :only => [ :show ]
  resources :metrics, :only => [ :index ]
  resources :projects, :only => [ :index, :show ]
  resource :settings, :only => [ :show ]
  resources :tags, :only => [ :index ]
  resources :test_infos, :path => :tests, :only => [ :index, :show ]
  resources :test_runs, :path => :runs, :only => [ :index, :show ] do
    member do
      get :previous
      get :next
    end
  end
  resources :users, :only => [ :index, :new ]
  resources :users, path: :user, only: [ :show, :edit, :update, :destroy ] do
    collection do
      post '/', action: :create, as: :create
    end
  end

  # documentation
  namespace 'doc', :module => nil do

    %w(overview clients changelog deploy).each do |e|
      match e => "doc##{e}", via: :get
    end

    namespace 'api', module: nil do

      get '/', to: 'doc#api_overview', as: :overview
      get '/browser', to: 'doc#api_browser', as: :browser
      get '/res', to: 'doc#api_resources', as: :resources
      get '/res/:name', to: 'doc#api_resource', as: :resource
      get '/rels', to: 'doc#api_relations', as: :relations
      get '/rels/:name', to: 'doc#api_relation', as: :relation
      get '/media', to: 'doc#api_media_types', as: :media_types
      get '/media/:name', to: 'doc#api_media_type', as: :media_type
      get '/listings', to: 'doc#api_listings', as: :listings
    end
  end

  namespace 'api', :module => :api, :as => :api do

    match '/' => "api#index", via: :get

    resources :payloads, only: [ :create ]

    resources :projects, only: [ :index, :create, :update ]

    resources :test_keys, only: [ :index, :create ] do
      
      collection do
        delete '/', action: :auto_release
      end
    end
  end

  # api
  namespace 'api/v1', :module => nil, :as => :legacy_api do

    resources :links, :only => [ :create, :update, :destroy ]

    resources :metrics, :only => [] do
      collection do
        post :compute
      end
    end

    resources :test_infos, :path => :tests, :only => [] do
      member do
        post :deprecate
        post :undeprecate
      end
    end

    scope constraints: { format: 'json' }, defaults: { format: 'json' } do

      resource :account, :only => [] do
        get :tests, :action => :tests_page
      end

      resources :metrics, :only => [] do
        collection do
          get 'measures/chart', action: :measures_chart
          get 'breakdown/authors', as: :author_breakdown, action: :author_breakdown
          get 'breakdown/categories', as: :category_breakdown, action: :category_breakdown
          get 'breakdown/projects', as: :project_breakdown, action: :project_breakdown
        end
      end

      resources :projects, :only => [] do

        member do
          get :tests_page
        end
      end

      resource :settings, only: [ :show, :update ]

      resources :tags, :only => [] do
        collection do
          get :cloud
        end
      end

      resources :test_infos, :path => :tests, :only => [] do
        collection do
          get '/', :action => :page
        end
        member do
          get :results, :action => :results_page
          get 'results/chart', :action => :results_chart
        end
      end

      resources :test_results, :path => :results, :only => [ :show ]

      resources :test_runs, :path => :runs, :only => [ :show ] do

        collection do
          get '/', :action => :page
        end
      end

      resources :users, :only => [] do

        collection do
          get '/', :action => :page
        end

        member do
          get :tests, :action => :tests_page
          get 'measures/chart', :action => :measures_chart
        end
      end
    end
  end

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products
  
  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
