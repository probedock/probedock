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
# encoding: utf-8
require 'spec_helper'

describe "API root", rox: { tags: :unit } do

  let(:user){ create :user }
  subject{ api_get user, api_path }

  it "should have the correct representation", rox: { key: '2deae8e48068' } do
    expect(subject).to eq(ApiRootRepresenter.new(Ability.new(user)).serializable_hash)
  end
end
