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
class DocController < ApplicationController
  before_filter :authenticate_user!

  def changelog
    window_title << t('layouts.docs.changelog')
    render_markdown 'CHANGELOG', base: false
  end

  %w(overview clients deploy).each do |name|
    define_method name do
      window_title << t("layouts.docs.#{name}")
      render_markdown name
    end
  end

  def api_overview
    api_doc_title
    render_markdown 'api/index'
  end

  def api_browser
    api_doc_title :browser
    render 'doc/api/browser', layout: false
  end

  %w(listings media_types relations resources).each do |name|
    define_method "api_#{name}" do
      api_doc_title name.to_sym
      render_markdown "api/#{name}"
    end
  end

  def api_resource
    return redirect_to doc_api_overview_path unless m = params[:name].to_s.match(/\A[a-z0-9\-]+\Z/i)
    api_doc_title :resources
    window_title << params[:name].to_s.titleize
    render_markdown "api/res/#{params[:name]}"
  end

  def api_relation
    return redirect_to doc_api_overview_path unless m = params[:name].to_s.match(/\Av\d+\:([a-z0-9]+)\:([a-z0-9\-]+)\Z/i)
    if m[1] == m[2].underscore.camelize(:lower)
      redirect_to action: :api_resource, name: m[2].singularize
    else
      redirect_to action: :api_resource, name: m[2]
    end
  end

  def api_media_type
    return redirect_to doc_api_overview_path unless m = params[:name].to_s.match(/\A[a-z0-9\-]+\Z/i)
    api_doc_title :media_types
    window_title << params[:name].to_s
    render_markdown "api/media/#{params[:name]}"
  end

  private

  def api_doc_title key = nil
    window_title << t('doc.api.title')
    window_title << t("doc.api.titles.#{key}") if key
  end

  # TODO: spec markdown/html docs
  def render_markdown path, options = {}

    path = options[:base] == false ? File.join(Rails.root, path) : File.join(Rails.root, 'doc', path)

    respond_to do |format|

      format.md do
        render body: File.read("#{path}.md"), content_type: media_type(:md)
      end

      format.html{ render path }
    end
  end
end
