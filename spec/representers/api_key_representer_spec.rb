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
require 'spec_helper'

describe ApiKeyRepresenter, rox: { tags: :unit } do

  let(:api_key){ create :api_key }
  let(:options){ {} }
  subject{ ApiKeyRepresenter.new(api_key, options).serializable_hash }

  it(nil, rox: { key: '349f17d686d1' }){ should hyperlink_to('self', uri(:api_key, id: api_key.identifier, locale: nil)) }
  it(nil, rox: { key: '168bde141c89' }){ should have_only_properties(id: api_key.identifier, active: api_key.active, usageCount: api_key.usage_count, createdAt: api_key.created_at.to_ms) }

  context "when the key has been used" do
    let(:api_key){ super().tap{ |k| k.usage_count = 42; k.last_used_at = Time.now; k.save! } }
    it(nil, rox: { key: '2f689a9f8e7a' }){ should have_properties(usageCount: 42, lastUsedAt: api_key.last_used_at.to_ms) }
  end

  context "with the detailed option" do
    let(:options){ { detailed: true } }
    it(nil, rox: { key: '124f64feb703' }){ should have_properties(sharedSecret: api_key.shared_secret) }
  end
end
