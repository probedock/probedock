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

  if Rails.env == 'development'
    mount Resque::Server.new, at: '/resque'
  end

  get '/templates/:name', to: 'home#template'

  namespace :api, module: :api do
    post :authenticate, to: 'api#authenticate'
    resources :projects, only: [ :index, :create, :update ]
  end

  get '/*path', to: 'home#index'
  root to: 'home#index'

=begin
  get :ping, to: 'home#ping'
  match :maintenance, to: 'home#maintenance', via: [ :post, :delete ]
  resources :api_keys, controller: :account_api_keys, only: [ :index, :create, :show, :update, :destroy ]

  namespace :admin, module: nil, path: :admin do
    get '/', to: 'admin#index'
    get :settings, to: 'admin#settings'
  end

  resource :data, only: [] do
    get :status
    get :general
    get :current_test_metrics
    match :test_counters, via: [ :get, :post ]
  end

  namespace :go, module: nil, controller: :go, as: nil do
    get :project, as: :project_permalink
    get :run, as: :test_run_permalink
    get :test, as: :test_permalink
  end

  devise_for :users, path_names: { sign_in: 'login', sign_out: 'logout', sign_up: 'register' }
  get :status, to: 'home#status'

  # pages
  resource :account, only: [ :show ]
  resources :metrics, only: [ :index ]
  resources :projects, only: [ :index, :show ]
  resources :purges, only: [ :index ]
  resources :tags, only: [ :index ]
  resources :test_infos, path: :tests, only: [ :index, :show ]
  resources :test_payloads, path: :payloads, only: [ :show ]
  resources :test_runs, path: :runs, only: [ :index, :show ] do
    member do
      get :previous
      get :next
    end
  end
  resources :users, only: [ :index, :new ]
  resources :users, path: :user, only: [ :show, :edit, :update, :destroy ] do
    collection do
      post '/', action: :create, as: :create
    end
  end

  namespace 'api', module: :api, as: :api do

    match '/' => "api#index", via: :get

    resources :projects, only: [ :index, :create, :show, :update ]

    resources :project_versions, only: [ :index ]

    resources :purges, only: [ :create, :index ]

    resources :tests, only: [ :index, :show ] do
      get :deprecation, on: :member
      put :deprecation, action: :deprecate, on: :member
      delete :deprecation, action: :undeprecate, on: :member
      get :results, on: :member
      get :project_versions, on: :member
    end

    post :test_deprecations, to: 'tests#bulk_deprecations'

    resources :test_keys, only: [ :index, :create ] do
      
      collection do
        delete '/', action: :auto_release
      end
    end

    resources :test_payloads, only: [ :create, :show ]

    resources :test_results, only: [ :show ]

    resources :test_runs, only: [ :index, :show ] do
      get :payloads, on: :member
    end

    resources :users, only: [ :index, :show, :update, :destroy ]

    namespace :legacy, module: nil do
      get :projects, to: 'legacy#projects'
      get :test_keys, to: 'legacy#test_keys'
    end
  end

  # api
  namespace 'api/v1', module: nil, as: :legacy_api do

    resources :links, only: [ :create, :update, :destroy ]
    resources :link_templates, only: [ :create, :update, :destroy ]

    resources :metrics, only: [] do
      collection do
        post :compute
      end
    end

    scope constraints: { format: 'json' }, defaults: { format: 'json' } do

      resource :account, only: [] do
        get :tests, action: :tests_page
      end

      resources :metrics, only: [] do
        collection do
          get 'measures/chart', action: :measures_chart
          get 'breakdown/authors', as: :author_breakdown, action: :author_breakdown
          get 'breakdown/categories', as: :category_breakdown, action: :category_breakdown
          get 'breakdown/projects', as: :project_breakdown, action: :project_breakdown
        end
      end

      resources :projects, only: [] do

        member do
          get :tests_page
        end
      end

      resource :settings, only: [ :show, :update ]

      resources :tags, only: [] do
        collection do
          get :cloud
        end
      end

      resources :test_infos, path: :tests, only: [] do
        member do
          get :results, action: :results_page
          get 'results/chart', action: :results_chart
        end
      end

      resources :test_results, path: :results, only: [ :show ]

      resources :test_runs, path: :runs, only: [ :show ]

      resources :users, only: [] do

        collection do
          get '/', action: :page
        end

        member do
          get :tests, action: :tests_page
          get 'measures/chart', action: :measures_chart
        end
      end
    end
  end
=end
end
