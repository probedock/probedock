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

# Utility methods for API resources, available to all API classes mounted in `ProbeDock::API`.
module ApiResourceHelper

  # Parses the specified attributes of the request body and converts their names
  # from the camelcase JSON convention to the underscore Ruby convention.
  #
  #     # request body = { firstName: 'John', lastName: 'Doe', foo: 'bar' }
  #     user_data = parse_object :firstName, :lastName
  #     puts user_data   # => { first_name: 'John', last_name: 'Doe' }
  #
  # You can also apply this method to any Hash by passing it as the first argument:
  #
  #     raw_data = { firstName: 'John', lastName: 'Doe', foo: 'bar' }
  #     user_data = parse_object raw_data, :firstName, :last_name
  #     puts user_data   # => { first_name: 'John', last_name: 'Doe' }
  def parse_object *attrs
    h = attrs.first.kind_of?(Hash) ? attrs.shift : params
    HashWithIndifferentAccess.new h.slice(*attrs.collect(&:to_s)).inject({}){ |memo,(k,v)| memo[k.underscore] = v; memo }
  end

  # Returns the first record of the specified relation (or nil if none is found).
  # If the API class has a `#with_serialization_includes`, it is called with
  # the relation first and the result is used as the new relation.
  #
  # This allows you to easily load related records in the same way across an
  # entire API class.
  #
  #     def with_serialization_includes rel
  #       if params[:withOrganization]
  #         rel = rel.includes :organization
  #       end
  #
  #       rel
  #     end
  #
  #     def get
  #       rel = Project.where api_id: params[:id].to_s
  #       project = load_resource rel
  #     end
  def load_resource rel
    rel = with_serialization_includes rel if respond_to? :with_serialization_includes
    rel.first
  end

  # Returns the first record of the specified relation (raises an error if none is found).
  # If the API class has a `#with_serialization_includes`, it is called with
  # the relation first and the result is used as the new relation. See `#load_resource`.
  def load_resource! rel
    rel = with_serialization_includes rel if respond_to? :with_serialization_includes
    rel.first!
  end

  # Returns the records of the specified relation.
  # If the API class implements `#with_serialization_includes`, it is called with
  # the relation first and the result is used as the new relation. See `#load_resource`.
  def load_resources rel
    rel = with_serialization_includes rel if respond_to? :with_serialization_includes
    rel.to_a
  end

  # Serializes the specified record (or array of records) using the corresponding
  # Pundit policy serializer (see `ApiAuthorizationHelper`).
  #
  # If the API class implements `serialization_options`, it is called with the record
  # (or records) and the resulting options will be passed to the serializer(s).
  #
  # ### Options
  #
  # * `current_user` - `User` - if specified, the serialization will be performed as if
  #                             that user is authenticated (even if it's not the case or if
  #                             another user is authenticated)
  def serialize records, options = {}

    custom_user = options.delete :current_user
    options.reverse_merge! respond_to?(:serialization_options) ? serialization_options(records) : {}

    if records.kind_of? Array
      records.to_a.collect{ |r| policy_serializer(r, custom_user).serialize(options) }
    else
      policy_serializer(records, custom_user).serialize(options)
    end
  end

  # Sets the specified attributes (if any) on the specified record and saves it.
  # If valid, calls `#serialize` with the record.
  # If invalid, sets the status to HTTP 422 Unprocessable Entity and calls `#record_errors` with the record.
  #
  # If a block is given, it is called with the record if it was successfully saved and before it is serialized.
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

  # Sets the specified attributes (if any) on the specified record and saves it.
  # If valid, calls `#serialize` with the record.
  # If invalid, sets the status to HTTP 422 Unprocessable Entity and calls `#record_errors` with the record.
  #
  # If a block is given, it is called with the record if it was successfully saved and before it is serialized.
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

  # Serializes Active Record error messages as an Array, which each error being a Hash
  # with a :message and a :path property.
  #
  # The message is a concatenation of the humanized attribute name and the error message.
  # The path is a JSON path corresponding to the attribute (only works for top-level paths).
  def record_errors record

    errors = []
    record.errors.each do |attr,errs|
      Array.wrap(errs).each do |err|
        errors << { message: "#{attr.to_s.gsub(/\./, ' ').humanize} #{err}", path: "/#{attr.to_s.camelize(:lower).gsub(/\./, '/')}" }
      end
    end

    # TODO: raise error
    ProbeDock::API.logger.debug "Validation errors: #{errors}"

    { errors: errors }
  end
end
