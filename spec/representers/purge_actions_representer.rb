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

describe PurgeActionsRepresenter, probe_dock: { tags: :unit } do

  before :each do
    allow(Resque).to receive(:size).and_return(42)
  end

  let :purge_actions do
    [
      create(:completed_purge_action, data_type: 'tags', created_at: Time.now - 3.days),
      create(:completed_purge_action, data_type: 'tickets', created_at: Time.now - 2.days),
      create(:purge_action, data_type: 'tags', created_at: Time.now - 1.hour)
    ]
  end
  let(:data){ { total: purge_actions.length, page: 1 } }
  let(:options){ {} }
  subject{ PurgeActionsRepresenter.new(OpenStruct.new(data.merge(data: purge_actions)), options).serializable_hash }

  it(nil, probe_dock: { key: '974d3e7f1d16' }){ should have_no_curie }
  it(nil, probe_dock: { key: '09d8b0f214f3' }){ should hyperlink_to('self', uri(:api_purges, locale: nil)) }
  it(nil, probe_dock: { key: '731863169800' }){ should have_only_properties(total: 3, page: 1) }
  it(nil, probe_dock: { key: 'a14c557251b5' }){ should have_embedded('item', purge_actions.collect{ |a| PurgeActionRepresenter.new(a).serializable_hash }) }

  describe "with the :info option" do
    let(:data){ super().merge page: nil }
    let(:options){ super().merge info: true }
    it(nil, probe_dock: { key: '354b5552da1b' }){ should have_only_properties(total: 3, jobs: 42) }
  end
end
