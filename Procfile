web: bundle exec rails server -b 0.0.0.0 -p $PORT
workers: bundle exec sidekiq -q active_storage_analysis -q active_storage_purge -q batch_queue -q sync -q default
