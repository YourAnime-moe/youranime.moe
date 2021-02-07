# frozen_string_literal: true

Rails.application.routes.draw do
  # Application foundation
  load 'config/routes/foundation.rb'
  # Admin console
  load 'config/routes/admin.rb'
  # API interface
  load 'config/routes/api.rb'
  # OAuth and authentication
  load 'config/routes/auth_oauth.rb'

  # global options responder -> makes sure OPTION request for CORS endpoints work
  match '*path', via: [:options], to: lambda { |_| [204, { 'Content-Type' => 'text/plain' }] }

  constraints(host: /localhost|0.0.0.0/) do
    match '/prod' => redirect('https://youranime.moe'), via: [:get]
  end

  # constraints(host: /\w+\.herokuapp.com/) do
  #  match '/(*path)' => redirect { |params, _| "https://youranime.moe/#{params[:path]}" }, via: :all
  # end
end
