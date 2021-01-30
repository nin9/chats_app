Searchkick.client = Elasticsearch::Client.new(
  url:  ENV['ES_URL']
)
