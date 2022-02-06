config = {
  host: "http://es:9200/",
  transport_options: {
    request: { timeout: 5 }
  }
}


Elasticsearch::Model.client = Elasticsearch::Client.new(config)
