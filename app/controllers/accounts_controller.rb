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
class AccountsController < ApplicationController
  before_filter :authenticate_user!
  before_filter{ authorize! :manage, :account }

  # Lists free test keys owned by the current user.
  # Also lists the 5 latest tests authored by the current user.
  def show
    window_title << t('accounts.show.title')

    @key_generator_config = {
      path: api_test_keys_path,
      projects: Project.order(:name).to_a.collect{ |p| ProjectRepresenter.new(p).serializable_hash },
      freeKeys: current_user.free_test_keys.order('created_at ASC').to_a.collect{ |k| TestKeyRepresenter.new(k).serializable_hash },
      lastNumber: current_user.settings.last_test_key_number,
      lastProjectApiId: current_user.settings.last_test_key_project_api_id
    }.reject{ |k,v| v.blank? }

    @tests_table_config = {
      uriTemplateParams: { 'authors[]' => [ current_user.name ] },
      search: TestSearch.config(params, except: [ :authors, :current ])
    }
  end

  # Lists tests authored by the current user.
  def tests_page
    options = TestSearch.options params[:search], except: :authors
    options[:base] = options[:base].where(author_id: current_user)
    options[:base_count] = options[:base_count].where(author_id: current_user)
    render :json => TestInfo.tableling.process(params.merge(options))
  end
end
