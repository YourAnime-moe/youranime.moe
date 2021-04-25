# encoding: utf-8
# frozen_string_literal: true
require 'mini_magick'

def seed
  User.transaction { seed_users }
  seed_shows_later
end

def seed_users
  Users::Admin.system

  Users::Admin.create(
    username: 'admin',
    first_name: 'Admin',
    last_name: 'User',
    limited: false,
    password: Rails.env.development? ? 'password' : Rails.application.credentials.admin_password,
    email: 'admin@youranime.moe',
  )
end

def seed_shows_later
  %i(current next).each do |season|
    Sync::ShowsFromKitsuJob.perform_later(season, staff: Users::Admin.system)
  end
end

seed
