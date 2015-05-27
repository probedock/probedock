# Copyright (c) 2015 ProbeDock
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
FactoryGirl.define do

  factory :test_payload do
    contents{ MultiJson.dump foo: 'bar' }
    received_at{ Time.now }
    user

    factory :processing_test_payload do
      state :processing
      processing_at{ received_at + 1.minute }
    end

    factory :processed_test_payload do
      state :processed
      processing_at{ received_at + 1.minute }
      processed_at{ processing_at + 1.minute }
    end
  end
end
