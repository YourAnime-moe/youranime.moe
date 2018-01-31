Rails.application.routes.draw do
  get 'messages/index'

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
  get '/shows/img' => 'shows#render_img'
  get '/search' => 'shows#search' # This not really for shows, but will probably be used mostly for shows

  # Movies
  get '/movies' => 'movies#view'

  # Episodes
  get '/shows/episodes' => 'episodes#view'
  get '/shows/episodes/random' => 'episodes#random'
  get '/shows/episodes/subs' => 'episodes#get_subs'
  get '/shows/episodes/render' => 'episodes#render_type'

  # Tags
  get '/tags' => 'shows#tags'

  # Recommendations
  get '/recommendations' => 'recommendation#main'
  post '/recommendations/new' => 'recommendation#create'

  # JSON controllers (GET)
  get '/json/search' => 'json#search'
  get '/json/get/users' => 'json#all_users'
  get '/json/shows/latest' => 'users#latest_shows'
  get '/json/find_show' => 'json#find_show'
  get '/json/episodes/get_comments' => 'json#episode_get_comments'
  get '/json/get/episode/next' => 'json#get_next_episode_id'
  post '/json/episodes/add_comment' => 'json#episode_add_comment'
  post '/json/setWatched' => 'json#set_watched'

  # Oauth
  get '/auth/:provider/callback' => 'sso#create'
  get '/auth/failure' => 'sso#failure'

  # GET API
  get '/api/check' => 'api#check'
  get '/api/get/user' => 'auth_api#user'
  get '/api/get/shows' => 'auth_api#shows'
  get '/api/get/shows/latest' => 'auth_api#latest_shows'
  get '/api/get/news' => 'auth_api#news'
  get '/api/get/episodes' => 'auth_api#episodes'
  get '/api/set/episodes/watched' => 'auth_api#add_episode'
  get '/api/get/episode/path' => 'auth_api#episode_path'

  # POST API
  post '/api/token' => 'api#token'
  post '/api/check' => 'api#check'
  post '/api/token/destroy' => 'auth_api#destroy_token' # todo: make delete
  post '/api/get/user' => 'auth_api#user'
  post '/api/get/shows' => 'auth_api#shows'
  post '/api/get/shows/latest' => 'auth_api#latest_shows'
  post '/api/get/news' => 'auth_api#news'
  post '/api/get/episodes' => 'auth_api#episodes'
  post '/api/set/episodes/watched' => 'auth_api#add_episode'
  post '/api/get/episode/path' => 'auth_api#episode_path'

  # Messages
  get '/messages' => 'messages#index'

  match '/logout', to: 'sso#destroy', via: :all

end
