namespace :clean_up do
	namespace :active_storage do
		desc "Cleans up only shows"
		task :shows => :environment do
		  puts "Cleaning up shows..."
		  Show.clean_up
		  puts "done."
		end

		desc "Cleans up only episode"
		task :episode => :environment do
		  puts "Cleaning up episode..."
		  Episode.clean_up
		  puts "done."
		end
	end
	
	desc "This task is called to clean up active storage objects"
	task :active_storage => :environment do
	  puts "Cleaning up shows..."
	  Show.clean_up

	  puts "Cleaning up episodes..."
	  Episode.clean_up
	  
	  puts "done."
	end
end
