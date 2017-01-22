Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'application#root'

  # User authentication
  get '/login' => 'application#root'
  get '/logout' => 'application#logout'
  post '/login' => 'application#login_post'

  # User links
  get '/settings' => 'users#short_settings'
  get '/users/settings' => 'users#settings'
  get '/users/:username' => 'users#home'

  # Shows
  get '/shows' => 'shows#view'

  # JSON controllers (GET)
  get '/search' => 'json#search'
  get '/find_show' => 'json#find_show'


  # Oauth
  get '/auth/:provider/callback' => 'sso#create'
  get '/auth/failure' => 'sso#failure'

  match '/logout', to: 'sso#destroy', via: :all

end
