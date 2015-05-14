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
module ApiResourceHelper

  def parse_object *attrs
    HashWithIndifferentAccess.new params.pick(*attrs.collect(&:to_s)).inject({}){ |memo,(k,v)| memo[k.underscore] = v; memo }
  end

  def load_resource rel
    rel = with_serialization_includes rel if respond_to? :with_serialization_includes
    rel.first
  end

  def load_resources rel
    rel = with_serialization_includes rel if respond_to? :with_serialization_includes
    rel.to_a
  end

  def serialize records, options = {}

    custom_user = options.delete :current_user
    options.reverse_merge! respond_to?(:serialization_options) ? serialization_options(records) : {}

    if records.kind_of? Array
      records.to_a.collect{ |r| policy_serializer(r).serialize(options) }
    else
      policy_serializer(records, custom_user).serialize(options)
    end
  end

  def create_record record, attributes = nil, options = {}

    record.attributes = attributes if attributes

    if record.errors.empty? && record.save
      yield if block_given?
      serialize record, options
    else
      status 422
      record_errors record
    end
  end

  def update_record record, updates = nil, options = {}
    if record.errors.empty? && (updates ? record.update_attributes(updates) : record.save)
      yield if block_given?
      serialize record, options
    else
      status 422
      record_errors record
    end
  end

  # TODO: use this
  def destroy_record record
    record.destroy
    status 204
    nil
  end

  def validation_context
    @validation_context ||= Errapi.config.new_context
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

  def uuid? value
    value.length == 36 && !!value.match(/\A[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\Z/i)
  end
end
