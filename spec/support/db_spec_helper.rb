module DbSpecHelper
  MODELS ||= [ Category, Email, Membership, Organization, Project, ProjectTest, ProjectVersion, Tag, TestDescription, TestKey, TestPayload, TestReport, TestResult, Ticket, User ]

  def expect_model_count_changes changes = {}
    unless @model_counts
      raise %/Use DbSpecHelper#store_model_counts at the beginning of all "When" step definitions to keep track of changes to the database/
    end

    current_counts = count_models
    errors = []

    MODELS.each do |model|
      symbol = model.name.to_sym

      previous_count = @model_counts[symbol]
      current_count = current_counts[symbol]

      expected_change = changes[symbol] || 0
      actual_change = current_count - previous_count

      unless actual_change == expected_change
        errors << "expected count of #{symbol} to change by #{expected_change}, but it changed by #{actual_change}"
      end
    end

    expect(errors).to be_empty, ->{ "\n#{errors.join("\n")}\n\n" }
  end

  def store_model_counts *models
    return @model_counts if @model_counts
    @model_counts = count_models *models
  end

  def count_models *models
    if models.blank?
      models = MODELS
    end

    models.inject({}) do |memo,model|
      memo[model.name.to_sym] = model.count
      memo
    end
  end
end
