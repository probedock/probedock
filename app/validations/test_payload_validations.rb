class TestPayloadValidations < Errapi::SingleValidator
  configure do
    validates type: :object

    # project API ID
    validates 'projectId', presence: true, type: :string, trim: true

    # project version
    validates 'version', presence: true, type: :string, trim: true, length: 100

    # test run duration
    validates 'duration', presence: true, type: :number, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

    # the time the test run ended at
    validates 'endedAt', type: :string # TODO: validate iso8601

    # results
    validates 'results', presence: true, type: :array
    validates_each 'results' do
      validates type: :object

      # test key
      validates 'k', type: :string, trim: true, length: 50

      # test name
      validates 'n', presence: true, type: :string, trim: true, length: 255

      # whether the test passed (defaults to true)
      validates 'p', type: :boolean

      # whether the test is active (defaults to true)
      validates 'v', type: :boolean

      # execution duration
      validates 'd', presence: true, type: :number, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

      # result message (usually in case of failure)
      validates 'm', type: :string, length: 50000

      # test category
      validates 'c', type: :string, trim: true, length: 50

      # test tags
      validates 'g', type: :array
      validates_each 'g' do
        validates type: :string, trim: true, length: 50
      end

      # issue tracker tickets
      validates 't', type: :array
      validates_each 't' do
        validates type: :string, trim: true, length: 50
      end

      # custom data
      validates 'a', type: :object
    end

    # report definitions
    validates 'reports', type: :array
    validates_each 'reports' do
      validates type: :object

      # unique report identifier within the organization
      validates 'uid', type: :string, length: 100
    end
  end
end
