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
require 'exceptions'

class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :window_title, :cached_links
  before_filter :set_locale
  before_filter :load_links

  rescue_from ROXCenter::Errors::XHRRequired do |exception|
    render :text => exception.message, :status => 400
  end

  rescue_from DeviseLdapAuthenticatable::LdapException do |exception|
    render :text => exception, :status => 500
  end

  def window_title
    @window_title ||= [ t('common.title') ]
  end

  protected

  # Redirects to login after logout to avoid authentication error.
  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end

  private

  def media_type name
    Mime::Type.lookup_by_extension(name).to_s
  end

  def default_url_options options = {}
    self.class.default_url_options
  end

  def self.default_url_options options = {}
    { locale: I18n.locale }
  end

  def set_locale
    I18n.locale = 'en'
  end

  def load_links
    @links = cached_links.contents if user_signed_in? and !request.xhr?
  end

  def cached_links
    JsonCache.new(:links, etag: false){ Link.order('name ASC').all.collect(&:to_client_hash).deep_stringify_keys! }
  end

  def cache_stale? cache
    cached_object = cache.respond_to?(:get) ? cache.get : cache
    stale? last_modified: cached_object.updated_at.utc, etag: cached_object.etag
  end

  def require_xhr!
    raise ROXCenter::Errors::XHRRequired, 'This method can only be accessed through XHR.' unless request.xhr?
  end

  def create_and_render_record model, *args
    record = model.new params[model.name.underscore]
    if record.save
      render_record record, *args
    else
      render_record_errors record, *args
    end
  end

  def update_and_render_record record, *args
    if record.update_attributes params[record.class.name.underscore]
      render_record record, *args
    else
      render_record_errors record, *args
    end
  end

  def destroy_and_render_record record, *args
    if record.destroy
      render_record record, *args
    else
      render nothing: true, status: 400
    end
  end

  def render_record record, *args
    render args.extract_options!.merge(json: record.to_json)
  end

  def render_record_errors record, *args
    render args.extract_options!.merge(json: record.errors.to_hash, status: 400)
  end
end
