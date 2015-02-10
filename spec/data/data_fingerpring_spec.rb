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

describe DataFingerprint do

  describe "#to_s" do

    it "should generate a hash of the data", probe_dock: { key: '3c7b0ada75a5' } do
      %w(foo bar baz).each{ |data| expect(fingerprint(data).to_s).to eq(Digest::SHA1.hexdigest(data)) }
    end

    it "should convert the data to a string", probe_dock: { key: 'f8693e606a86' } do
      data = { a: 1, b: 2, c: 3 }
      expect(fingerprint(data).to_s).to eq(Digest::SHA1.hexdigest(data.to_s))
    end
  end

  describe "#==" do

    it "should return true for the same data", probe_dock: { key: '4bcb85a68299' } do
      expect(fingerprint('foo')).to eq(fingerprint('foo'))
    end

    it "should return false for different data", probe_dock: { key: 'da9621ee4b23' } do
      expect(fingerprint('bar')).not_to eq(fingerprint('baz'))
    end
  end

  describe "#data" do

    it "should return the internal data", probe_dock: { key: 'f5039ef879e6' } do
      Array.new(3){ |i| Object.new }.each{ |data| expect(fingerprint(data).data).to be(data) }
    end
  end

  def fingerprint data
    described_class.new data
  end
end
