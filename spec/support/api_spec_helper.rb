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

  # Returns an instance of Rack::Test::UploadedFile with the following
  # content and mime type. It can be used to test a multipart/form-data
  # file upload.
  #
  # If no block is given, the file should be manually deleted after use
  # by calling `file.unlink`. If a block is given, the file will only be
  # available within the block and automatically deleted afterwards.
  #
  #     uploaded_file '{"foo":"bar"}', 'application/json' do |file|
  #       post '/api/resource', { file: file }
  #     end
  def uploaded_file content, mime_type

    # write the content to a temporary file
    file = Tempfile.new 'probedock-uploaded-file'
    file.write content
    file.close

    ufile = Rack::Test::UploadedFile.new file.path, mime_type

    if block_given?
      begin
        yield ufile
      ensure
        file.unlink
      end
    end

    ufile
  end

  def find_api_user name
    if name == 'nobody'
      nil
    else
      user = named_record name
      expect(user).to be_a_kind_of(User)
      user
    end
  end

  def interpolate_content content
    content.gsub /\{(@[^\}]+)\}/ do |*args|
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
      elsif value == '@iso8601'
        /.*/ # TODO: validate ISO 8601 dates
      elsif value == '@email'
        /\A[^@]+@[^@]+\Z/
      elsif value == '@md5'
        /\A[a-f0-9]{32}\Z/
      elsif %w(@integer @number @string @boolean).include? value
        TypeExpectation.new value.sub(/^\@/, '').to_sym
      end

      return expectation if expectation
    end

    if m = value.match(/^@json\((.*)\)$/)
      extract_json @response_body, m[1]
    elsif m = value.match(/^@md5OfJson\((.*)\)$/)
      raw_value = extract_json @response_body, m[1]
      raw_value ? Digest::MD5.hexdigest(raw_value.to_s) : nil
    elsif m = value.match(/^@idOf\((.*), (.*)\)$/)
      named_record_by_type(m[1], m[2]).api_id
    elsif m = value.match(/^@idOf:\s?(.*)$/)
      named_record(m[1]).api_id
    elsif m = value.match(/^@valueOf\((.*), (.*), (.*)\)$/)
      named_record_by_type(m[1], m[2]).send(m[3])
    elsif m = value.match(/^@valueOf\((.*), (.*)\)$/)
      named_record(m[1]).send(m[2])
    elsif m = value.match(/^@date\((.*)\)$/)
      if m[1].match(/(today|now)/)
        Time.now.strftime('%Y-%m-%d')
      elsif m = value.match(/(\d+) (second|minute|hour|day|week|month|year)s? ago beginning of (day|week)/)
        m[1].to_i.send(m[2]).ago.send("beginning_of_#{m[3]}").strftime('%Y-%m-%d')
      elsif m = value.match(/(\d+) (second|minute|hour|day|week|month|year)s? ago/)
        m[1].to_i.send(m[2]).ago.strftime('%Y-%m-%d')
      elsif m = value.match(/beginning of (day|week)/)
        Time.now.send("beginning_of_#{m[1]}").strftime('%Y-%m-%d')
      else
        raise 'Unknown date expectation format'
      end
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
      interpolate_content value
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

  def expect_http_status_code code, res = nil

    res ||= @response
    res ||= response if respond_to? :response

    expect(res.status).to eq(code), ->{
      msg = ""
      msg << "\nexpected #{http_status_code_description(code)}"
      msg << "\n     got #{http_status_code_description(res.status)}"
      msg << "\n\n#{JSON.pretty_generate MultiJson.load(res.body)}\n\n"
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
      %/\n#{errors.join("\n")}\n\n#{JSON.pretty_generate(json)}\n\n/
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
    elsif expectations.kind_of? TypeExpectation
      expectations.validate json, %/JSON value at "#{path}"/, errors
    elsif expectations == !!expectations
      if json == !!json
        errors << %/expected JSON boolean at "#{path}" to be #{expectations}, got #{json}/ unless expectations == json
      else
        errors << %/expected JSON value at "#{path}" to be a boolean, got #{json.inspect} (#{json.class})/
      end
    else
      errors << %/expected JSON value at "#{path}" to equal #{expectations}, got #{json.inspect}/ unless json == expectations
    end
  end

  # An expectation that a value is of a given type (e.g. a number).
  #
  # Available types are: boolean, integer, number, string.
  #
  #     expectation = TypeExpectation.new :integer
  #     expectation.error 24, "foo"      #=> nil
  #     expectation.error 5.6, "foo"     #=> 'expected foo to be of type :integer, but got 5.6'
  #     expectation.error "bar", "foo"   #=> 'expected foo to be of type :integer, but got "bar"'
  class TypeExpectation
    attr_reader :type

    def initialize type
      raise "Unknown type #{type.inspect}; known types are #{SPEC_CONTENT_EXPECTATION_TYPES.keys.collect(&:to_s).sort.join(', ')}" unless SPEC_CONTENT_EXPECTATION_TYPES.key? type
      @type = type
    end

    # Validates the specified value, adding an error to the supplied errors array if it is invalid.
    # The description is used to build the error message with the template "expected #{description} to be of type :#{type}, but got #{value}".
    def validate value, description, errors = []
      if Array.wrap(SPEC_CONTENT_EXPECTATION_TYPES[@type]).none?{ |type| value.kind_of? type }
        errors << "expected #{description} to be of type :#{@type}, but got #{value.inspect}"
      end
    end

    private

    SPEC_CONTENT_EXPECTATION_TYPES = {
      integer: Integer,
      number: Numeric,
      string: String,
      boolean: [ TrueClass, FalseClass ]
    }
  end
end
