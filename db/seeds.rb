# encoding: utf-8

IMAGE_RE = /\.(png|jpg)\z/.freeze

def seed
  seed_users
  seed_shows
end

def seed_users
  admin_user = Staff.create(
    username: 'admin',
    name: 'Admin User',
    limited: false
  )

  admin_user.to_user!
end

def seed_shows
  banners.each_with_index do |banner_filename, i|
    show_name = banner_filename.split('.')[0]
    show = seed_show(show_name, at: i)
    next unless show.persisted?

    # show.banner.attach(filename: banner_filename, io: File.open("./seeds/banners/#{banner_filename}"))
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
  
  Show.create!(
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
end

def banners
  files_at('seeds', 'banners').select { |file| file =~ IMAGE_RE }
end

def files_at(*args)
  Dir.entries(Rails.root.join(*args))
end

seed
