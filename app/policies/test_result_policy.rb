# Copyright (c) 2015 42 inside
# Copyright (c) 2012-2014 Lotaris SA
#
# This file is part of Probe Dock.
#
# Probe Dock is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Probe Dock is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Probe Dock.  If not, see <http://www.gnu.org/licenses/>.
class TestResultPolicy < ApplicationPolicy
  class Serializer < Serializer
    def to_builder options = {}
      Jbuilder.new do |json|
        json.id record.id
        json.name record.name
        json.passed record.passed
        json.active record.active
        json.message record.message
        json.duration record.duration
        json.key record.key.key if record.key.present? && record.payload_properties_set?(:key)
        json.category record.category.name if record.category.present?
        json.tags record.tags.collect(&:name)
        json.tickets record.tickets.collect(&:name)
        json.customData record.custom_values
        json.runner serialize(record.runner, link: true)
        json.project serialize(record.project_version.project, link: true)
        json.projectVersion record.project_version.name
        json.runAt record.run_at.iso8601(3)
      end
    end
  end
end
