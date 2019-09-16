# frozen_string_literal: true

IMAGE_RE = /\.(png|jpg)\z/.freeze

namespace :seed do
  namespace :shows do
    desc "Seed all banners"
    task banners: :environment do
      Show.all.each_with_index do |show, i|
        filename = banners[i]
        p "Attaching #{filename} to #{show.title}..."
        show.banner.attach(io: banner_files[i], filename: filename)
        
        p "Waiting 2 seconds"
        sleep 2
      end
    end
  end
end

def banner_files
  @banner_files ||= banners.map { |banner_filename| File.open("./seeds/banners/#{banner_filename}") }
end

def banners
  files_at('seeds', 'banners').select { |file| file =~ IMAGE_RE }
end

def files_at(*args)
  Dir.entries(Rails.root.join(*args))
end

