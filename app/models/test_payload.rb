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
class TestPayload < ActiveRecord::Base

  belongs_to :user
  belongs_to :test_run
  scope :waiting_for_processing, -> { where(state: :created).order('received_at ASC') }

  include SimpleStates
  states :created, :processing, :processed
  event :start_processing, from: :created, to: :processing
  event :finish_processing, from: :processing, to: :processed

  validates :user, presence: true
  validates :contents, presence: true
  validates :state, inclusion: { in: state_names.inject([]){ |memo,name| memo << name << name.to_s } }
  validates :received_at, presence: true
end
