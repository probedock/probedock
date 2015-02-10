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

module CanCanHelpers

  def fake_ability type = nil, target = nil
    Object.new.tap do |ability|
      ability.extend CanCan::Ability
      ability.can type, target if type and target
    end
  end

  module ClassMethods
    include CanCanHelpers

    def fake_controller_current_ability type, target
      before :each do
        allow(controller).to receive(:current_ability){ fake_ability type, target }
      end
    end
  end
end
