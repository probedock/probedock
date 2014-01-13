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

class ApiRootRepresenter < BaseRepresenter

  representation do

    curie 'v1', "#{uri(:doc_api_relation, name: 'v1')}:root:{rel}", templated: true

    link 'self', api_uri, title: t('.root.title')
    link 'help', uri(:doc_api_overview), title: t('.root.help'), type: media_type(:md)
    link 'version-history', uri(:doc_changelog), title: t('.root.changelog'), type: media_type(:md)
    link 'v1:projects', api_uri(:projects), title: t('.root.projects')
    link 'v1:test-keys', api_uri(:test_keys), title: t('.root.test_keys')
    link 'v1:test-payloads', api_uri(:payloads), title: t('.root.payloads'), type: media_type(:rox_payload_v1)

    property :appVersion, ROXCenter::Application::VERSION
  end
end
