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
require 'securerandom'

class RecordsController < ApplicationController
  before_filter :authenticate_user!

  def create
    set_record_instance_for_create params
    record_callback :on_create
    record_callback :on_save
    if get_record_instance.errors.empty? and get_record_instance.save
      render_record
    else
      render_record_errors
    end
  end

  def update
    record_callback :on_update
    record_callback :on_save
    if get_record_instance.errors.empty? and get_record_instance.update_attributes(get_params_for_update)
      render_record
    else
      render_record_errors
    end
  end

  def destroy
    record_callback :on_destroy
    json = get_record_instance.to_json
    get_record_instance.destroy
    render :json => json 
  end

  private

  def render_record record = get_record_instance, *args
    super record, *args
  end

  def render_record_errors record = get_record_instance, *args
    super record, *args
  end

  def records_path
    send "#{plural_model_name}_path"
  end

  def record_path r
    send "#{singular_model_name}_path", r.id
  end

  def new_record_path
    send "new_#{singular_model_name}_path"
  end

  def set_record_instance_for_create params
    set_record_instance record_model.new(params[singular_model_name.to_sym])
  end

  def get_params_for_update
    params[record_model.name.underscore]
  end

  def record_callback name
    self.send(name, params) if self.respond_to? name
  end

  def record_model_options search
    record_model.respond_to?(:search_options) ? record_model.search_options(search) : record_model.all
  end

  def get_record_instance
    instance_variable_get "@#{singular_model_name}"
  end

  def set_record_instance i
    instance_variable_set "@#{singular_model_name}", i
  end

  def get_record_collection
    instance_variable_get "@#{plural_model_name}"
  end

  def set_record_collection c
    instance_variable_set "@#{plural_model_name}", c
  end

  def singular_model_name
    @singular_model_name ||= record_model.name.underscore.to_sym
  end

  def plural_model_name
    @plural_model_name ||= singular_model_name.to_s.pluralize.to_sym
  end

  def record_model
    @record_model ||= self.class.name.sub(/^.*::/, '').sub(/Controller$/, '').singularize.constantize
  end

  def load_record
    set_record_instance record_model.find(params[:id].to_i)
  end
end
