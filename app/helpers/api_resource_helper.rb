# Copyright (c) 2012-2014 Lotaris SA
#
# This file is part of ROX Center.
#
# ROX Center is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ROX Center is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with ROX Center.  If not, see <http://www.gnu.org/licenses/>.
module ApiResourceHelper

  def parse_object *attrs
    HashWithIndifferentAccess.new params.pick(*attrs.collect(&:to_s)).inject({}){ |memo,(k,v)| memo[k.underscore] = v; memo }
  end

  def create_record record
    if record.errors.empty? && record.save
      record
    else
      status 422
      record_errors record
    end
  end

  def update_record record, updates, &block
    if record.errors.empty? && (block ? block.call(record, updates) && record.valid? : record.update_attributes(updates))
      record
    else
      status 422
      record_errors record
    end
  end

  def validation_state
    validation_context.state
  end

  def validation_context
    @validation_context ||= Errapi::ValidationContext.new
  end

  def record_errors record

    errors = []
    record.errors.each do |attr,errs|
      Array.wrap(errs).each do |err|
        errors << { message: "#{attr.to_s.humanize} #{err}", path: "/#{attr.to_s.camelize(:lower)}" }
      end
    end

    errors
  end
end
