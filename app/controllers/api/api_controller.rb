# Copyright (c) 2012-2013 Lotaris SA
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

  before_filter :authenticate_api_user!

  # TODO: write specs for Accept and Content-Type checks

  # Check accepted media types
  before_filter :check_accept

  # Disable CSRF checks
  skip_before_filter :verify_authenticity_token
  skip_before_filter :load_links

  # Handle unknown and forbidden records the same way
  rescue_from CanCan::AccessDenied, with: :forbidden_or_record_not_found
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ApiError, with: :render_api_error

  def index
    # TODO: spec etag
    render_api ApiRootRepresenter.new, etag: true
  end

  private

  def parse_json_model *attrs
    json = parse_json_request
    json.pick(*attrs).inject({}){ |memo,(k,v)| memo[k.underscore] = v; memo }
  end

  def parse_json_request
    parse_json_request_body ensure_json_encoding(request.raw_post)
  end

  def ensure_json_encoding body
    begin
      body.force_encoding 'UTF-8'
    rescue StandardError => e
      fail :badEncoding, "Could not convert data to UTF-8: #{e.message}"
    end
  end

  def parse_json_request_body body, options = {}
    
    raise ApiError.new "Request body cannot be empty", name: :emptyRequest if body.length <= 0

    json = begin
      Oj.load body, mode: :strict
    rescue ArgumentError, Oj::ParseError => e
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
    render text: "This resource consumes only the following type(s): #{media_type_strings.join ', '}", status: :unsupported_media_type, :content_type => Mime::TEXT
  end

  def check_accept *media_types
    media_types = [ :hal_json ] unless media_types.any?
    media_types.each do |media_type|
      media_type_string = media_type(media_type).to_s
      if request.accept and !request.accept[media_type_string] and !request.accept["application/*"] and !request.accept["*/*"]
        render text: "This resource is only available in the #{media_type_string} type.", status: :not_acceptable, :content_type => Mime::TEXT
        return
      end
    end
  end

  def generate_etag object
    object == true ? ROXCenter::Application::VERSION_HASH : object.to_s
  end

  def forbidden_or_record_not_found exception
    if params[:id]
      record_not_found exception
    else
      render text: exception.message, status: :forbidden, content_type: media_type(:txt)
    end
  end

  def record_not_found exception
    render text: %/Couldn't find record with ID "#{params[:id]}"/, status: :not_found, content_type: media_type(:txt)
  end

  def authenticate_api_user!
    return if user_signed_in?

    key = api_key_from_header || api_key_from_params

    if key.blank?
      response.headers['WWW-Authenticate'] = 'RoxApiKey'
      return head :unauthorized
    end

    ApiKey.where(id: key.id).update_all [ 'usage_count = usage_count + 1, last_used_at = ?', Time.now ]
    @current_api_key = key
  end

  def api_key_from_params
    if params[:api_key_id] and params[:api_key_secret]
      ApiKey.authenticated(params[:api_key_id].to_s, params[:api_key_secret].to_s).first
    else
      nil
    end
  end

  def api_key_from_header
    if m = request.headers["Authorization"].try(:match, /\ARoxApiKey id="?([^"]+)"? secret="?([^"]+)"?\Z/)
      ApiKey.authenticated(m[1], m[2]).first
    else
      nil
    end
  end

  def current_api_user
    current_user || @current_api_key.user
  end

  # CanCan override
  def current_ability
    @current_ability ||= Ability.new(current_api_user)
  end
end
