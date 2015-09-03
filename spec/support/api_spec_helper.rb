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
module ApiSpecHelper
  def find_api_user name
    if name == 'nobody'
      nil
    else
      user = named_record name
      expect(user).to be_a_kind_of(User)
      user
    end
  end

  def interpolate_api_url url
    url.gsub /\{(@[^\}]+)\}/ do |*args|
      Rack::Utils::escape(interpolate_string($1))
    end
  end

  def interpolate_json json, options = {}
    if json.kind_of? Hash
      json.inject({}) do |memo,(key,value)|
        memo[key] = interpolate_json value, options
        memo
      end
    elsif json.kind_of? Array
      json.collect do |value|
        interpolate_json value, options
      end
    elsif json.kind_of? String
      interpolate_string json, options
    else
      json
    end
  end

  def interpolate_string value, options = {}
    if options[:expectations]

      expectation = if value == '@alphanumeric'
        /\A[a-z0-9]+\Z/
      elsif value == '@uuid'
        /\A[a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[89aAbB][a-f0-9]{3}-[a-f0-9]{12}\Z/
      elsif value == '@string'
        /.+/
      elsif value == '@iso8601'
        /.*/ # TODO: validate ISO 8601 dates
      end

      return expectation if expectation
    end

    if m = value.match(/^@json\((.*)\)$/)
      extract_json @response_body, m[1]
    elsif m = value.match(/^@idOf:\s?(.*)$/)
      named_record(m[1]).api_id
    elsif m = value.match(/^@registrationOtpOf:\s?(.*)$/)

      record = named_record(m[1])
      registration = if record.kind_of? User
        UserRegistration.where(user_id: record.id).first
      elsif record.kind_of? Organization
        UserRegistration.where(organization_id: record.id).first
      else
        raise "Unsupported registration OTP reference: #{record.inspect}"
      end

      raise "No user registration found for #{record.inspect}" unless registration.present?
      raise "Registration for #{record.inspect} has no OTP" unless registration.otp.present?

      registration.otp
    else
      value
    end
  end

  def extract_json json, pointer
    return json if pointer == ''

    location = pointer.match(/^\/([^\/]*)\/?/)[1]
    next_pointer = pointer.sub(/^\/[^\/]*(\/?)/, '\1')

    if json.kind_of?(Array) && location.match(/^\d+$/)
      extract_json json[location.to_i], next_pointer
    elsif json.kind_of?(Hash)
      extract_json json[location], next_pointer
    else
      raise "Invalid JSON pointer #{pointer.inspect} for JSON value #{json.inspect}"
    end
  end

  def http_status_code_description code
    name = Rack::Utils::HTTP_STATUS_CODES[code.to_i]
    name ? "HTTP #{code} #{name}" : "HTTP #{code}"
  end

  def expect_http_status_code code, response = nil

    response ||= @response

    expect(response.status).to eq(code), ->{
      msg = ""
      msg << "\nexpected #{http_status_code_description(code)}"
      msg << "\n     got #{http_status_code_description(response.status)}"
      msg << "\n\n#{JSON.pretty_generate MultiJson.load(response.body)}\n\n"
    }
  end

  def expect_json json, expectations

    errors = []
    expectations = if expectations.kind_of? Hash
      expectations.with_indifferent_access
    elsif expectations.kind_of? Array
      expectations.collect{ |e| e.kind_of?(Hash) ? e.with_indifferent_access : e }
    end

    validate_json json, interpolate_json(expectations, expectations: true), '', errors
    expect(errors).to be_empty, ->{
      %/\n#{errors.join("\n")}\n\n/
    }
  end

  def validate_json json, expectations, path = '', errors = []
    if expectations.kind_of? Hash
      if json.kind_of? Hash
        (json.keys & expectations.keys).each do |key|
          validate_json json[key], expectations[key], "#{path}/#{key}", errors
        end

        missing_keys = expectations.keys - json.keys
        extra_keys = json.keys - expectations.keys

        if missing_keys.present? || extra_keys.present?
          msg = %/expected JSON object at "#{path}" to have the following properties: #{expectations.keys.join(', ')}/
          msg << %/\n  got missing properties: #{missing_keys.join(', ')}/ if missing_keys.present?
          msg << %/\n  got extra properties: #{extra_keys.join(', ')}/ if extra_keys.present?
          msg << %/\n\n#{JSON.pretty_generate(json)}/
          errors << msg
        end
      else
        errors << %/expected JSON value at "#{path}" to be an object, got #{json.inspect} (#{json.class})/
      end
    elsif expectations.kind_of? Array
      if json.kind_of? Array
        errors << %/expected JSON array at "#{path}" to have #{expectations.length} elements, got #{json.length}/ unless expectations.length == json.length
        [ expectations.length, json.length ].min.times do |i|
          validate_json json[i], expectations[i], "#{path}/#{i}", errors
        end
      else
        errors << %/expected JSON value at "#{path}" to be an array, got #{json.inspect} (#{json.class})/
      end
    elsif expectations.kind_of? Regexp
      if json.kind_of? String
        errors << %/expected JSON string at "#{path}" to match #{expectations}, got #{json.inspect}/ unless json.match expectations
      else
        errors << %/expected JSON value at "#{path}" to be a string, got #{json.inspect} (#{json.class})/
      end
    elsif expectations == !!expectations
      if json == !!json
        errors << %/expected JSON boolean at "#{path}" to be #{expectations}, got #{json}/ unless expectations == json
      else
        errors << %/expected JSON value at "#{path}" to be a boolean, got #{json.inspect} (#{json.class})/
      end
    else
      errors << %/expected JSON value at "#{path}" to equal #{expectations}, got #{json}/ unless json == expectations
    end
  end
end
