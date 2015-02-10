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

describe PurgeActionRepresenter, rox: { tags: :unit } do

  let(:purge_action){ create :purge_action }
  let(:options){ {} }
  subject{ PurgeActionRepresenter.new(purge_action, options).serializable_hash }

  it(nil, rox: { key: '69a8529dd239' }) do
    should have_only_properties({
      dataType: purge_action.data_type,
      numberPurged: 0,
      createdAt: purge_action.created_at.to_ms
    })
  end

  describe "with a completed purge action" do
    let(:purge_action){ create :completed_purge_action }

    it(nil, rox: { key: 'ff25aceadb44' }) do
      should have_only_properties({
        dataType: purge_action.data_type,
        numberPurged: purge_action.number_purged,
        createdAt: purge_action.created_at.to_ms,
        completedAt: purge_action.completed_at.to_ms
      })
    end
  end

  describe "with the :info option" do
    let(:options){ { info: true } }
    before :each do
      allow(purge_action).to receive(:data_lifespan).and_return(30)
      allow(purge_action).to receive(:number_remaining).and_return(42)
    end

    it(nil, rox: { key: '488697498cdd' }) do
      should have_only_properties({
        dataType: purge_action.data_type,
        numberPurged: 0,
        dataLifespan: 30,
        numberRemaining: 42,
        createdAt: purge_action.created_at.to_ms
      })
    end

    describe "with a new purge action" do
      let(:purge_action){ PurgeAction.new data_type: 'tags' }

      it(nil, rox: { key: '5ee619f7aad2' }) do
        should have_only_properties({
          dataType: purge_action.data_type,
          numberPurged: 0,
          dataLifespan: 30,
          numberRemaining: 42
        })
      end
    end

    describe "with a completed purge action" do
      let(:purge_action){ create :completed_purge_action }

      it(nil, rox: { key: '5e5fedf4a847' }) do
        should have_only_properties({
          dataType: purge_action.data_type,
          numberPurged: purge_action.number_purged,
          dataLifespan: 30,
          numberRemaining: 42,
          createdAt: purge_action.created_at.to_ms,
          completedAt: purge_action.completed_at.to_ms
        })
      end
    end
  end
end
