Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'messages#index'

  # scope がパスワード代わり
  #scope Rails.application.credentials.admin_url do
  scope ENV.fetch("ADMIN_URL", Rails.application.credentials.admin_url) do
    resources :messages do
      collection do
        get 'upload/new', to: 'messages#upload_new'
        post 'upload'
      end
    end
    resources :schedules
    resources :favoriting_tweets do
      collection do
        get 'keyword'
        patch 'keyword', to: 'favoriting_tweets#keyword_update'
      end
    end
    resources :twitter_accounts
    resources :tweet_histories, only: [:index] do
      member do
        get 'delete'
      end
    end
    get 'periodical/minute', to: 'periodical#minute'
    patch 'periodical/minute', to: 'periodical#minute_update'

    resources :configs
  end

  # ログイン機能
  devise_for :admin_users,
             path: 'admin',
             only: [:sign_in, :sign_out, :session],
             controllers: {
               sessions: 'admin_users/sessions'
             }
end
