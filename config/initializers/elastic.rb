Elasticsearch::Persistence.client = Elasticsearch::Client.new({
  host: Rails.application.config_for(:elastic)['url'],
  logger: Rails.logger,
  reload_on_failure: true
})
