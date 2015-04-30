# Copyright (c) 2015 42 inside
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

describe TestPayload, probe_dock: { tags: :unit } do

  context "associations" do
    it(nil, probe_dock: { key: 'ce9d6c2604ef' }){ should belong_to(:runner) }
    it(nil, probe_dock: { key: 'dd735c4e26be' }){ should have_and_belong_to_many(:test_keys) }
  end

  context "database table" do
    it(nil, probe_dock: { key: '38b8aaf117c3' }){ should have_db_column(:id).of_type(:integer).with_options(null: false) }
    it(nil, probe_dock: { key: '01022e014d7f' }){ should have_db_column(:contents).of_type(:json).with_options(null: false) }
    it(nil, probe_dock: { key: '83cbe7a2b2fe' }){ should have_db_column(:contents_bytesize).of_type(:integer).with_options(null: false) }
    it(nil, probe_dock: { key: '816a4253b966' }){ should have_db_column(:state).of_type(:string).with_options(null: false, limit: 20) }
    it(nil, probe_dock: { key: '793c1d58bc15' }){ should have_db_column(:runner_id).of_type(:integer).with_options(null: false) }
    it(nil, probe_dock: { key: '38c375f9570a' }){ should have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it(nil, probe_dock: { key: 'b10bba5cf4c0' }){ should have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
    it(nil, probe_dock: { key: '635cbda15dcd' }){ should have_db_column(:received_at).of_type(:datetime).with_options(null: false) }
    it(nil, probe_dock: { key: 'afd82eff3e03' }){ should have_db_column(:processing_at).of_type(:datetime).with_options(null: true) }
    it(nil, probe_dock: { key: 'ce373915d05f' }){ should have_db_column(:processed_at).of_type(:datetime).with_options(null: true) }
    it(nil, probe_dock: { key: '0b792708d003' }){ should have_db_index(:state) }
  end
end
