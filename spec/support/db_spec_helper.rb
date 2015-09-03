# Copyright (c) 2015 ProbeDock
# Copyright (c) 2012-2014 Lotaris SA
#
# This file is part of ProbeDock.
#
# ProbeDock is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ProbeDock is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with ProbeDock.  If not, see <http://www.gnu.org/licenses/>.
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
