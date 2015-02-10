# Copyright (c) 2012-2014 Lotaris SA
#
# This file is part of Probe Dock.
#
# Probe Dock is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Probe Dock is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Probe Dock.  If not, see <http://www.gnu.org/licenses/>.
require 'spec_helper'

describe ApiKeysRepresenter, rox: { tags: :unit } do

  let(:user){ create :user }
  let!(:additional_api_keys){ Array.new(2){ create :api_key, user: user } }
  let(:api_keys){ user.api_keys }
  let(:options){ { total: api_keys.length, page: 1 } }
  subject{ ApiKeysRepresenter.new(OpenStruct.new(options.merge(data: api_keys))).serializable_hash }

  it(nil, rox: { key: 'b663d63e7ae9' }){ should have_no_curie }
  it(nil, rox: { key: '8d36660525ae' }){ should hyperlink_to('self', uri(:api_keys, locale: nil)) }
  it(nil, rox: { key: '6eee4137f82f' }){ should have_only_properties(total: 3, page: 1) }
  it(nil, rox: { key: '833b8ec53b7b' }){ should have_embedded('item', api_keys.collect{ |k| ApiKeyRepresenter.new(k).serializable_hash }) }
end
