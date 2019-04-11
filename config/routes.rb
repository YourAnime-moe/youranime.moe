Rails.application.routes.draw do
  get 'messages/index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :api, defaults: {format: :json} do
    get '/', to: "v#{Config.api_version}/default_action#home"
    namespace "v#{Config.api_version}" do
      resources :session, only: [:create, :show, :destroy], param: :token
      resources :shows, only: [:index, :show] do
        resources :episodes, only: [:index]
        get :search, on: :collection
        get :latest, on: :collection
      end

      resources :episodes, only: [:show] do
        get :watched, on: :collection
      end

      resources :users, only: [:index]
    end
    match '*all', to: "v#{Config.api_version}/default_action#not_found", via: :all, :constraints => { :all => /.*/ }
  end

  # Issues
  resources :issues, only: [:index, :new] do
    delete :close
    post :open, on: :collection
  end

  # Shows
  resources :shows, only: [:index, :show] do
    get :history, on: :collection
    get :movies, on: :collection
  end

  # Episodes
  namespace :show, path: "show" do
    resources :episodes, only: [:show]
  end

  root 'application#root'
  get '/get/current/locale' => 'application#get_locale'
  put '/set/current/locale' => 'application#set_locale'

  # User authentication
  get '/login' => 'application#root'
  get '/logout' => 'application#logout'
  post '/login' => 'application#login_post'

  # User links
  get '/settings' => 'users#short_settings'
  get '/users/settings' => 'users#settings'
  get '/users/home' => 'users#home'
  get '/news' => 'users#news'
  patch '/users/update/:id' => 'users#update'

  # Movies
  get '/movies' => 'movies#view'

  get '/auth/google_oauth2/callback' => 'application#google_auth'

  # Episodes
  #get '/shows/episodes' => 'episodes#view'
  #get '/shows/episodes/random' => 'episodes#random'
  #get '/shows/episodes/subs' => 'episodes#get_subs'
  #get '/shows/episodes/render' => 'episodes#render_type'

  # Tags
  get '/tags' => 'shows#tags'

  # Recommendations
  get '/recommendations' => 'recommendation#main'
  post '/recommendations/new' => 'recommendation#create'

  # JSON controllers (GET)
  get '/json/search' => 'json#search'
  get '/json/get/users' => 'json#all_users'
  get '/json/shows/latest' => 'users/api#latest_shows'
  get '/json/find_show' => 'json#find_show'
  get '/json/episodes/get_comments' => 'json#episode_get_comments'
  get '/json/get/episode/next' => 'json#get_next_episode_id'
  post '/json/episodes/add_comment' => 'json#episode_add_comment'
  post '/json/setWatched' => 'json#set_watched'

  # Admin console
  get '/admin' => 'admin#home'
  namespace :admin do
    resources :shows
    resources :episodes
  end

  # Oauth
  get '/auth/failure' => 'sso#failure'

  # GET API
  # get '/api/check' => 'api#check'
  # get '/api/get/user' => 'auth_api#user'
  # get '/api/get/shows' => 'auth_api#shows'
  # get '/api/get/shows/latest' => 'auth_api#latest_shows'
  # get '/api/get/news' => 'auth_api#news'
  # get '/api/get/episodes' => 'auth_api#episodes'
  # get '/api/set/episodes/watched' => 'auth_api#add_episode'
  # get '/api/get/episodes/history' => 'auth_api#episodes_history'
  # get '/api/get/episode/path' => 'auth_api#episode_path'
  # get '/api/get/username' => 'auth_api#get_username'

  # get '/api/update/user/settings' => 'auth_api#update_user_settings'

  # POST API
  # post '/api/token' => 'api#token'
  # post '/api/check' => 'api#check'
  # post '/api/token/destroy' => 'auth_api#destroy_token' # todo: make delete
  # post '/api/get/user' => 'auth_api#user'
  # post '/api/get/shows' => 'auth_api#shows'
  # post '/api/get/shows/latest' => 'auth_api#latest_shows'
  # post '/api/get/news' => 'auth_api#news'
  # post '/api/get/episodes' => 'auth_api#episodes'
  # post '/api/set/episodes/watched' => 'auth_api#add_episode'
  # post '/api/get/episode/path' => 'auth_api#episode_path'
  # post '/api/get/username' => 'auth_api#get_username'
  # post '/api/update/episode/progress' => 'auth_api#update_episode_progress'
  # post '/api/update/user' => 'auth_api#update_user'

  # PUT API
  # put '/api/update/episode/progress' => 'auth_api#update_episode_progress'
  # put '/api/update/user/settings' => 'auth_api#update_user_settings'

  # Messages
  get '/messages' => 'messages#index'

  match '/logout', to: 'sso#destroy', via: :all

end
