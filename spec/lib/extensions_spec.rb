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
require 'spec_helper'

describe Time do
  subject{ Time.now }

  describe "#to_ms" do

    it "should return the number of milliseconds since the epoch", probe_dock: { key: '896d38d5e773' } do
      expect(subject.to_ms).to eq((subject.to_f * 1000).floor)
    end

    it "should floor the value", probe_dock: { key: 'baca0e9b455e' } do
      expect(described_class.at(10.4567).to_ms).to eq(10456)
    end
  end

  describe "#ms_from" do

    it "should return the difference in milliseconds from another time", probe_dock: { key: 'aa6dc6859ed0' } do
      expect(subject.ms_from subject).to eq(0)
      expect(subject.ms_from subject - 1.hour).to eq(3600000)
      expect(subject.ms_from subject + 2.minutes).to eq(-120000)
    end

    it "should round the value", probe_dock: { key: '4a119e0b108b' } do
      expect(subject.ms_from(subject - 0.5678)).to eq(568)
    end
  end
end
