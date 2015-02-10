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

describe TestKeyRepresenter, rox: { tags: :unit } do

  let(:test_key){ create :test_key }
  subject{ TestKeyRepresenter.new(test_key).serializable_hash }

  it(nil, rox: { key: 'e6a141ffdc18' }) do
    should have_only_properties({
      value: test_key.key,
      projectApiId: test_key.project.api_id,
      free: test_key.free,
      createdAt: test_key.created_at.to_ms
    })
  end
end
