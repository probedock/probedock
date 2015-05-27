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
class TestPayloadPolicy < ApplicationPolicy

  def index?
    user.is?(:admin) || user.member_of?(organization)
  end

  class Scope < Scope
    def resolve
      if user.is? :admin
        scope
      else
        scope.joins(project_version: :project).where('projects.organization_id = ?', organization.id)
      end
    end
  end

  class Serializer < Serializer
    def to_builder options = {}
      Jbuilder.new do |json|
        json.id record.api_id
        json.bytes record.contents_bytesize
        json.state record.state
        json.endedAt record.ended_at.iso8601(3)
        json.receivedAt record.received_at.iso8601(3)
        json.processingAt record.processing_at.iso8601(3) if record.processing_at
        json.processedAt record.processed_at.iso8601(3) if record.processed_at
      end
    end
  end
end
