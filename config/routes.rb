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
    resources :favoriting_tweets
    resources :twitter_accounts
  end

  # ログイン機能
  devise_for :admin_users,
             path: 'admin',
             only: [:sign_in, :sign_out, :session],
             controllers: {
               sessions: 'admin_users/sessions'
             }
end
