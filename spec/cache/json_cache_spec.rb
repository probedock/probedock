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

describe JsonCache do
  let(:contents){ 'bar' }
  let(:generator){ double fetch: contents }

  it "should serialize contents as json", probe_dock: { key: 'a0ebf9eac6c5' } do
    expect(JsonCache.new(:foo){ 'bar' }.get.to_json).to eq(MultiJson.dump('bar', mode: :strict))
    expect(JsonCache.new(:fooo){ [ 'a', 'b' ] }.get.to_json).to eq(MultiJson.dump([ 'a', 'b' ], mode: :strict))
    expect(JsonCache.new(:foooo){ { 'a' => 'b' } }.get.to_json).to eq(MultiJson.dump({ 'a' => 'b' }, mode: :strict))
  end

  describe "for a string" do

    subject{ JsonCache.new(:foo){ generator.fetch } }

    it "should call the block the first time", probe_dock: { key: 'e8bc7aca3851' } do
      expect(generator).to receive(:fetch)
      subject.get
    end

    it "should cache the value returned by the block", probe_dock: { key: 'acf355a40ac0' } do
      subject.get
      expect(generator).not_to receive(:fetch)
      subject.get
    end

    it "should call the block again after being cleared", probe_dock: { key: '294e6b0f3152' } do
      subject.get
      expect(generator).to receive(:fetch)
      subject.clear
      subject.get
    end

    it "should return the contents as json", probe_dock: { key: 'ca756ee7eeb4' } do
      expect(subject.get.to_json).to eq(MultiJson.dump(contents, mode: :strict))
    end

    it "should return the original contents", probe_dock: { key: '18dcc69073ca' } do
      expect(subject.get.contents).to eq(contents)
    end
  end

  describe "with the expire option" do
    subject{ JsonCache.new(:foo, expire: 30.minutes){ generator.fetch } }

    it "should expire the contents", probe_dock: { key: 'f419086b27ec' } do
      expect($redis).to receive(:expire).with('cache:json:foo', 30.minutes.to_i)
      subject.get
    end
  end

  describe "with the expire option set by the block" do
    subject{ JsonCache.new(:foo){ |options| options[:expire] = 42; generator.fetch } }

    it "should expire the contents", probe_dock: { key: 'bcdf5bab7b42' } do
      expect($redis).to receive(:expire).with('cache:json:foo', 42)
      subject.get
    end
  end
end
