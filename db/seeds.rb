# encoding: utf-8
require 'mini_magick'

def production_seed
  return unless Rails.env.production?

  seed_show_tags
  seed_shows
  seed_episodes
end

def development_seed
  return unless Rails.env.development?

  seed_users
  seed_show_tags
  seed_shows
  seed_episodes
end

def seed_users
  admin_user = Staff.create(
    username: 'admin',
    name: 'Admin User',
    limited: false,
    password: 'password'
  )

  admin_user.to_user!
end

def seed_show_tags
  Utils.valid_tags.each do |tag|
    Tag.create(value: tag)
  end
end

def seed_shows
  banners.each_with_index do |banner_filename, i|
    show_name = banner_filename.split('.')[0]
    show = seed_show(show_name, at: i)
    next unless show.persisted?
  end

  Rails.logger.info "Note: Don't forget to run `rails seed:shows:banners` to populate the show's banners"
end

def seed_episodes
  Show.all.each do |show|
    show.seasons.each do |season|
      (1..26).each do |number|
        season.episodes.create(
          number: number,
          title: "Episode #{number} - Season #{season.number} - #{show.title}"
        )
      end
    end
  end
end

def seed_show(show_name, at: nil)
  title = Title.new(
    en: "Title for #{show_name}",
    fr: "Titre pour #{show_name}",
    jp: "「#{show_name}」のタイトル",
    roman: show_name
  )
  description = Description.new(
    en: 'My description in English',
    fr: 'Ma description en Français',
    jp: '日本語での概要',
  )
  
  show = Show.create!(
    show_type: 'anime',
    dubbed: (at % 2).zero?,
    subbed: (at % 3).zero?,
    released_on: Time.now.utc,
    published_on: Time.now.utc,
    published: true,
    plot: 'My plot',
    title: title,
    description: description,
  )

  [:comedy, :fantasy, :magic].each do |tag|
    show.tags << Tag.find_by(value: tag)
  end

  (1..3).each do |season_number|
    show.seasons.create(number: season_number)
  end

  show
end

def banners
  files_at('seeds', 'banners').select { |file| file =~ /\.(png|jpg)\z/.freeze }
end

def files_at(*args)
  Dir.entries(Rails.root.join(*args))
end

development_seed
production_seed
