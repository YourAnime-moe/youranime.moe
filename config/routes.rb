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
  get '/news' => 'users#news'
  patch '/users/update/:id' => 'users#update'

  # Shows
  get '/shows' => 'shows#view'
  get '/shows/history' => 'shows#history'
  get '/search' => 'shows#search' # This not really for shows, but will probably be used mostly for shows

  # Episodes
  get '/shows/episodes' => 'episodes#view'
  get '/shows/episodes/random' => 'episodes#random'

  # JSON controllers (GET)
  get '/json/search' => 'json#search'
  get '/json/find_show' => 'json#find_show'
  get '/json/episodes/get_comments' => 'json#episode_get_comments'
  get '/json/get/episode/next' => 'json#get_next_episode_id'
  post '/json/episodes/add_comment' => 'json#episode_add_comment'
  post '/json/setWatched' => 'json#set_watched'

  # Oauth
  get '/auth/:provider/callback' => 'sso#create'
  get '/auth/failure' => 'sso#failure'

  # API
  post '/api/token' => 'api#token'
  post '/api/token/destroy' => 'auth_api#destroy_token'
  get '/api/get/user' => 'auth_api#user'
  get '/api/get/shows' => 'auth_api#shows'
  get '/api/get/shows/lastest' => 'auth_api#lastest_shows'
  get '/api/get/news' => 'auth_api#news'
  get '/api/get/episodes' => 'auth_api#episodes'
  get '/api/get/episode/path' => 'auth_api#episode_path'

  match '/logout', to: 'sso#destroy', via: :all

end
