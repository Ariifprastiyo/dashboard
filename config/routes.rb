Rails.application.routes.draw do
  authenticate :user, -> (user) { user.has_role?(:super_admin) } do
    mount Blazer::Engine, at: "blazer"
    mount Flipper::UI.app(Flipper) => "flipper"
    mount RailsLocalAnalytics::Engine, at: "local_analytics"
  end

  namespace :google_chrome_ext do
    resources :popup, only: [:index] do
      collection do
        post :import_social_media_account
        get :new_post_campaign
        post :create_post_campaign
      end
    end
  end
  resources :competitor_reviews do
    member do
      get 'campaigns/:campaign_id', to: 'competitor_reviews#show_campaign', as: 'show_campaign'
    end
  end
  resources :organization_settings
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  namespace :campaigns do
    get 'payment_requests/index'
    get 'payment_requests/new'
  end

  resources :managements do
    resources :managements_accounts, only: %i[new create destroy]
    resource :bulk_social_media_accounts, only: %i[new create] do
      get :download_template
    end
  end
  resources :campaigns do
    scope module: :campaigns do
      resources :import_social_media_publications, except: %i[edit update] do
        # download_template doesn't needs import_social_media_publication_id
        get :download_template, on: :collection
        get :download_uploaded_file, on: :member
        put :cancel, on: :member
      end
    end
    member do
      get :timeline
      post :sync_social_media_publications
      post :recalculate_the_last_publication_history_metrics
      resources :media_comments, only: %i[index update], param: :media_comment_id
      scope module: :campaigns, as: :campaigns do
        resource :social_media_publications, only: %i[show]

        resources :payment_requests, param: :payment_request_id do
          # add process, reject, and approve actions
          put :processs, on: :member
          put :pay, on: :member
        end
      end
      post :analyze_comment_with_ai
      post :analyze_comment_word_cloud
      get :export_word_cloud
    end
    resource :reach_plan_performance_report, only: %i[edit update]
    resource :activity_report, only: %i[show]
    resource :performance_report, only: %i[show]
  end
  resources :brands
  resources :influencers do
    resources :social_media_accounts
    collection do
      resources :bulk_influencers, except: %i[edit update] do
        get :download_uploaded_file, on: :member
        put :cancel, on: :member
      end

      get 'bulk_influencer/download_template', to: 'bulk_influencers#download'
    end
  end
  resources :social_media_accounts, only: [:index, :destroy]
  resources :media_plans do
    resources :scope_of_works
    member do
      get :export
    end
    resources :bulk_markup_sell_prices
  end

  resources :scope_of_works, only: [] do
    resources :scope_of_work_items, only: [:index, :show, :edit, :update]
  end

  resources :scope_of_work_items, only: [] do
    resources :social_media_publications, only: [:destroy, :create, :edit, :update]
  end

  resources :publication_histories, only: [:new, :create, :edit, :update, :destroy]
  devise_for :users, only: [:sessions, :registrations, :passwords]
  get 'home/index'

  resources :users do
    put :deactivate, on: :member
    put :activate, on: :member
    put :update_password, on: :member
  end

  resources :organizations

  resource :account, only: [:edit, :update]

  resources :sow_invitations, only: [:show, :update] do
    put :reject, on: :member
    get :expired, on: :member
    get :already_rejected, on: :member
  end

  resources :employment_agreement_letters, only: [:show, :update] do
    get :download, on: :member
  end

  # Defines the root path route ("/")
  root "home#index"

  # company routes
  get 'company/toc', to: 'company#toc'

  authenticate :user, ->(user) { user.has_role? :admin } do
    mount GoodJob::Engine => 'good_job'
  end
  mount ActionCable.server => '/cable'

  get '/version', to: 'application#version'
end
