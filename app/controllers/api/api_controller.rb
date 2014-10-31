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
require 'json/jwt'

class Api::ApiController < ApplicationController

  class ApiError < StandardError
    attr_reader :options, :status

    def initialize message, options = {}
      super message
      @status = options.delete(:status) || :bad_request
      @options = options.pick :name, :path
    end

    def serializable_hash options = {}
      @options.merge message: message
    end
  end

  before_filter :authenticate_api_user!, except: :authenticate

  # TODO: write specs for Accept and Content-Type checks

  # Check accepted media types
  before_filter :check_accept

  # Disable CSRF checks
  skip_before_filter :verify_authenticity_token
  skip_before_filter :load_links

  # Handle unknown and forbidden records the same way
  rescue_from JSON::JWS::VerificationFailed, with: :unauthorized
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ApiError, with: :render_api_error

  def index
    # TODO: spec etag
    # TODO: make etag dependent on user role
    render_api ApiRootRepresenter.new(current_ability), etag: Rails.env.production?
  end

  def authenticate

    model = parse_json_model :username, :password

    user = User.where(email: model[:username]).first

    # TODO: protect against timing attacks
    return unauthorized unless user
    return unauthorized unless user.authenticate model[:password]

    jwt = JSON::JWT.new({
      iss: user.email,
      exp: 1.year.from_now,
      nbf: Time.now
    }).sign(Rails.application.secrets.secret_key_base, 'HS512')

    render json: { token: jwt.to_s }
  end

  private

  def parse_json_model *attrs
    json = parse_json_request
    HashWithIndifferentAccess.new json.pick(*attrs.collect(&:to_s)).inject({}){ |memo,(k,v)| memo[k.underscore] = v; memo }
  end

  def parse_json_request
    parse_json_request_body ensure_json_encoding(request.raw_post)
  end

  def ensure_json_encoding body
    begin
      body.force_encoding 'UTF-8'
    rescue StandardError => e
      raise ApiError, "Could not convert data to UTF-8: #{e.message}", name: :badEncoding
    end
  end

  def parse_json_request_body body, options = {}
    
    raise ApiError.new "Request body cannot be empty", name: :emptyRequest if body.length <= 0

    json = begin
      MultiJson.load body
    rescue ArgumentError, Oj::ParseError, MultiJson::LoadError => e
      raise ApiError.new "Could not parse JSON: #{e.message}", name: :invalidJson
    end

    raise ApiError.new "Request body must be a JSON object", name: :invalidValue, path: '' unless json.kind_of? Hash

    json
  end

  def render_api_error error
    render json: { errors: [ error.serializable_hash ] }, status: error.status, content_type: media_type(:rox_errors)
  end

  def render_api_model_errors model, options = {}

    errors = []
    model.errors.each do |attr,errs|
      Array.wrap(errs).each do |err|

        error = { message: "#{attr.to_s.humanize} #{err}", path: "/#{attr.to_s.camelize(:lower)}" }

        if err.kind_of? ActiveModel::RoxErrorMessage
          [ :name, :path ].each{ |k| error[k] = err.send(k) if err.send(k) }
        end

        errors << error
      end
    end

    render json: { errors: errors }.to_json, status: options[:status] || :bad_request, content_type: media_type(:rox_errors)
  end

  def render_api object, options = {}
    render_api_hal_json object, options if !options[:etag] or stale? etag: generate_etag(options[:etag])
  end

  def render_api_hal_json object, options = {}
    response.etag = generate_etag options[:etag] if options[:etag]
    render({ json: object, content_type: media_type(:hal_json) }.merge(options))
  end

  def check_content_type *media_types
    media_type_strings = media_types.collect{ |mt| media_type(mt).to_s }
    media_type_strings.each do |media_type_string|
      return if !request.content_type or request.content_type[media_type_string] or request.content_type["application/*"] or request.content_type["*/*"]
    end
    render plain: "This resource consumes only the following type(s): #{media_type_strings.join ', '}", status: :unsupported_media_type
  end

  def check_accept *media_types
    media_types = [ :json ] unless media_types.any?
    media_types.each do |media_type|
      media_type_string = media_type(media_type).to_s
      if request.accept and !request.accept[media_type_string] and !request.accept["application/*"] and !request.accept["*/*"]
        render plain: "This resource is only available in the #{media_type_string} type.", status: :not_acceptable
        return
      end
    end
  end

  def generate_etag object
    object == true ? ROXCenter::Application::VERSION_HASH : object.to_s
  end

  def record_not_found exception
    render plain: %/Couldn't find record with ID "#{params[:id]}"/, status: :not_found
  end

  def unauthorized
    head :unauthorized
  end

  def authenticate_api_user!

    @auth_token = auth_token_from_header || auth_token_from_params

    return unauthorized if @auth_token.blank?

    # TODO: use another secret for signing auth tokens
    @auth_claims = JSON::JWT.decode(jwt_string, Rails.application.secrets.secret_key_base)
  end

  def auth_token_from_params
    params[:authToken]
  end

  def auth_token_from_header
    if m = request.headers["Authorization"].try(:match, /\ABearer (.+)\Z/)
      m[1]
    else
      nil
    end
  end

  def current_user
    User.where(email: @auth_claims['iss']).first!
  end
end
