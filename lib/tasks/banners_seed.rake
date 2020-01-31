# frozen_string_literal: true

IMAGE_RE = /\.(png|jpg)\z/.freeze

namespace :seed do
  namespace :shows do
    desc 'Seed all banners'
    task banners: :environment do
      seed_banners
    end
  end

  namespace :episodes do
    task thumbnails: :environment do
      seed_thumbnails
    end
  end

  namespace :all do
    desc 'Seed all banners and thumbnails'
    task media: :environment do
      seed_thumbnails
      seed_banners
    end
  end
end

def seed_banners(wait_for = 2)
  Show.all.each_with_index do |show, i|
    filename = banners[i]
    next if filename.nil?

    p "Attaching #{filename} to #{show.title}..."
    show.banner.attach(io: banner_files[i], filename: filename)

    p "Waiting #{wait_for} seconds"
    sleep wait_for
  end
end

def seed_thumbnails(wait_for = 2)
  Show.all.each_with_index do |show, show_index|
    info = banners[show_index]
    next if info.nil?

    key = info.split('.')[0]
    episodes(key).each_with_index do |episode_filename, i|
      p "Attaching #{episode_filename} to #{show.title}..."

      file = thumbnail_files(key)[i]
      show.episodes[i].thumbnail.attach(io: file, filename: episode_filename)

      p "Waiting #{wait_for} seconds"
      sleep wait_for
    end
  end
end

def banner_files
  @banner_files ||= banners.map { |banner_filename| File.open("./seeds/banners/#{banner_filename}") }
end

def thumbnail_files(key)
  episodes(key).map { |filename| File.open("./seeds/thumbnails/#{filename}") }
end

def banners
  files_at('seeds', 'banners').select { |file| file =~ IMAGE_RE }
end

def episodes(key)
  files_at('seeds', 'thumbnails').select do |file|
    file =~ /\.(png|jpg)\z/.freeze
    return false unless file

    file.start_with?(key)
  end
end

def files_at(*args)
  Dir.entries(Rails.root.join(*args))
end

