Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # scope がパスワード代わり
  #scope Rails.application.credentials.admin_url do
  scope ENV.fetch("ADMIN_URL", Rails.application.credentials.admin_url) do
    resources :messages
    resources :twitter_accounts
  end
end
