require 'redis'

Recommendable.configure do |config|
  config.redis = Redis.new(host: 'localhost', port: 6379, db: 0)
  config.redis_namespace = :tanoshimu_recommendations
  config.auto_enqueue = true
  config.nearest_neighbors = nil
end
