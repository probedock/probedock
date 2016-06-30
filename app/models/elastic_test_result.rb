require 'elasticsearch/persistence/model'

class ElasticTestResult
  include Elasticsearch::Persistence::Model

  index_name [ Rails.application.config_for(:elastic)['index_prefix'], 'test_results' ].join('_')

  attribute :id, String
  attribute :name, String
  attribute :passed, Boolean
  attribute :active, Boolean
  attribute :duration, Integer
  attribute :message, String
  attribute :custom_values, Hash[String => String]
  attribute :created_at, Time
  attribute :run_at, Time

  attribute :category, String
  attribute :tags, Array[String]
  attribute :tickets, Array[String]

  attribute :key, String
  attribute :key_user_api_id, String
  attribute :key_user_name, String

  attribute :test_api_id, String
  attribute :new_test, Boolean

  attribute :organization_api_id, String
  attribute :organization_name, String

  attribute :payload_api_id, String
  attribute :payload_index, Integer

  attribute :project_api_id, String
  attribute :project_name, String

  attribute :project_version_api_id, String
  attribute :project_version_name, String

  attribute :report_api_id, String
  attribute :report_uid, String

  attribute :runner_api_id, String
  attribute :runner_name, String

  def self.from_test_result result
    new.tap do |r|
      r.id = result.id.to_s

      %i(name passed active duration created_at run_at).each do |attr|
        r.send("#{attr}=", result.send(attr))
      end

      r.message = result.message if result.message
      r.custom_values = serialize_custom_values(result.custom_values) if result.custom_values.kind_of?(Hash)

      r.category = result.category.name
      r.tags = result.tags.collect(&:name)
      r.tickets = result.tickets.collect(&:name)

      if result.key.present?
        r.key = result.key.key
        if result.key.user.present?
          r.key_user_api_id = result.key.user.api_id
          r.key_user_name = result.key.user.name
        end
      end

      r.test_api_id = result.test.api_id
      r.new_test = result.new_test

      project_version = result.project_version
      project = project_version.project
      organization = project.organization

      r.organization_api_id = organization.api_id
      r.organization_name = organization.display_name || organization.name

      r.payload_api_id = result.test_payload.api_id
      r.payload_index = result.payload_index

      r.project_api_id = project.api_id
      r.project_name = project.display_name || project.name

      r.project_version_api_id = project_version.api_id
      r.project_version_name = project_version.name

      if report = result.test_payload.test_reports.first
        r.report_api_id = report.api_id
        r.report_uid = report.uid if report.uid.present?
      end

      r.runner_api_id = result.runner.api_id
      r.runner_name = result.runner.name
    end
  end

  private

  def self.serialize_custom_values custom_values
    custom_values.inject({}) do |memo,(k,v)|
      memo[k.to_s.gsub(/\./, ':')] = v
      memo
    end
  end
end
