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
module SpecApiHelper
  MEDIA_TYPES = {
    payload_v1: 'application/vnd.probedock.payload.v1+json',
    probedock_payload_v1: 'application/vnd.probedock.payload.v1+json',
    markdown: 'text/x-markdown'
  }

  def check_api_errors expected_errors, options = {}

    actual_errors = parse_api_errors

    expected_errors.each do |expected|

      name, msg = expected[:name], Array.wrap(expected[:message])
      actual, matched = if name
        [ actual_errors.find{ |e| e[:name] == name.to_s }, "name #{name}" ]
      else
        [ actual_errors.find{ |e| msg.any?{ |m| m.kind_of?(Regexp) ? e[:message].match(m) : e[:message] == m } }, "message matching #{msg}" ]
      end

      expect(actual).to be_present, "Expected to find an API error with #{matched}"
      actual_errors.delete actual

      expect(actual[:name]).to be_nil, "Expected API error with #{matched} to have no name" unless name

      if expected[:path]
        expect(actual[:path]).to eq(expected[:path]), "Expected API error with #{matched} to have path #{expected[:path]}, got #{actual[:path]}"
      else
        expect(actual.key?(:path)).to be(false), "Expected API error with #{matched} to have no path, got #{actual[:path]}"
      end

      msg.each do |m|
        expect(m.kind_of?(Regexp) ? !!actual[:message].match(m) : actual[:message] == m).to be(true), "Expected an API error with #{matched} to have a message matching #{m}"
      end
    end

    expect(actual_errors).to be_empty, "Did not expect the following API errors: #{actual_errors}"
  end

  def parse_api_errors options = {}

    expect(response.status).to eq(400)
    expect(response.content_type).to eq(media_type(:errors))

    body = MultiJson.load response.body, mode: :strict
    expect(body).to be_a_kind_of(Hash)

    HashWithIndifferentAccess.new(body)[:errors].tap do |errors|
      expect(errors).to be_a_kind_of(Array)
      expect(errors).not_to be_empty
    end
  end

  def api_get path, options = {}

    headers = options[:headers] || {}
    headers['Authorization'] = "Bearer #{options[:user].generate_auth_token}" if options[:user]

    get path, options[:query] || {}, headers

    @response_body = MultiJson.load response.body, mode: :strict unless options[:empty_body]
  end

  def api_post path, body, options = {}

    headers = options[:headers] || {}
    headers['Content-Type'] ||= options[:content_type] || 'application/json'
    headers['Authorization'] = "Bearer #{options[:user].generate_auth_token}" if options[:user]

    post path, body, headers

    @response_body = MultiJson.load response.body, mode: :strict
  end

  def api_put user, path, body, params = {}, options = {}

    headers = { 'CONTENT_TYPE' => options[:content_type] || 'application/json' }
    headers = options[:headers] || {}

    if options[:functional]
      @request.env['RAW_POST_DATA'] = body
      put path, params # without authentication
      expect(response.status).to eq(401)
      @request.env.merge! headers.merge(api_authentication_headers(user))
      put path, params
    else
      put send("#{path}_path", params), body, headers # without authentication
      expect(response.status).to eq(401)
      put send("#{path}_path", params), body, headers.merge(api_authentication_headers(user))
    end

    @response_body = MultiJson.load response.body, mode: :strict
  end

  def api_delete user, path, params = {}, options = {}

    headers = options[:headers] || {}

    if options[:functional]
      delete path, params # without authentication
      expect(response.status).to eq(401)
      @request.env.merge! headers.merge(api_authentication_headers(user))
      delete path, params
    else
      delete send("#{path}_path"), params, headers # without authentication
      expect(response.status).to eq(401)
      delete send("#{path}_path"), params, headers.merge(api_authentication_headers(user))
    end

    @response_body = MultiJson.load response.body, mode: :strict
  end

  def media_type name
    MEDIA_TYPES[name.to_sym]
  end

  def uri name, options = {}
    options[:protocol] = PROBE_DOCK_CONFIG['protocol'] || 'https'
    options[:host] = PROBE_DOCK_CONFIG['host']
    options[:port] = PROBE_DOCK_CONFIG['port'].to_i if PROBE_DOCK_CONFIG['port']
    Rails.application.routes.url_helpers.send "#{name}_url", {}.merge(options)
  end

  def api_uri name = nil, options = {}
    uri [ :api, name ].compact.join('_'), options
  end

  def post_api_payload payload, user, headers = {}
    post api_test_payloads_path, payload, { 'CONTENT_TYPE' => 'application/vnd.probedock.payload.v1+json' }.merge(api_authentication_headers(user)).merge(headers)
  end

  def api_authentication_headers user
    key = user.api_keys.where(active: true).first
    raise "At least one active API key is required for API testing (user: #{user.name})" if key.blank?
    { 'HTTP_AUTHORIZATION' => %/ProbeDockApiKey id="#{key.identifier}" secret="#{key.shared_secret}"/ }
  end
end
