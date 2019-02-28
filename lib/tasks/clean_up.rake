namespace :clean_up do
	namespace :remove_all do
		desc "Removes all shows media"
		task :shows => :environment do
		  puts "Cleaning up shows..."
		  Show.remove_all_media
		  puts "done."
		end

		desc "Removes all episode media"
		task :episodes => :environment do
		  puts "Cleaning up episode..."
		  Show::Episode.remove_all_media
		  puts "done."
		end
	end

	namespace :active_storage do
		desc "Cleans up only shows"
		task :shows => :environment do
		  puts "Cleaning up shows..."
		  Show.clean_up
		  puts "done."
		end

		desc "Cleans up only episode"
		task :episodes => :environment do
		  puts "Cleaning up episode..."
		  Show::Episode.clean_up
		  puts "done."
		end
	end
	
	desc "This task is called to clean up active storage objects"
	task :active_storage => :environment do
	  puts "Cleaning up shows..."
	  Show.clean_up

	  puts "Cleaning up episodes..."
	  Show::Episode.clean_up
	  
	  puts "done."
	end
end

