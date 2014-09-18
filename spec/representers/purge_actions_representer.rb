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

describe PurgeActionsRepresenter, rox: { tags: :unit } do

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
  let(:options){ { total: purge_actions.length, page: 1 } }
  subject{ PurgeActionsRepresenter.new(OpenStruct.new(options.merge(data: purge_actions))).serializable_hash }

  it(nil, rox: { key: '974d3e7f1d16' }){ should have_no_curie }
  it(nil, rox: { key: '09d8b0f214f3' }){ should hyperlink_to('self', uri(:api_purges, locale: nil)) }
  it(nil, rox: { key: '731863169800' }){ should have_only_properties(total: 3, page: 1, jobs: 42) }
  it(nil, rox: { key: 'a14c557251b5' }){ should have_embedded('item', purge_actions.collect{ |a| PurgeActionRepresenter.new(a).serializable_hash }) }
end
