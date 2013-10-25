# Copyright (c) 2012-2013 Lotaris SA
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

class TestKeysRepresenter < BaseRepresenter

  representation do |res|

    curie 'v1', "#{uri(:doc_api_relation, name: 'v1')}:testKeys:{rel}", templated: true

    link 'self', api_uri(:test_keys)

    property :total, res.total
    property :page, res.page if res.page
    
    embed_collection('v1:test-keys', res.data){ |k| TestKeyRepresenter.new k }
  end
end
