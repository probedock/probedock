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
require 'spec_helper'

describe ApiRootRepresenter, rox: { tags: :unit } do

  subject{ ApiRootRepresenter.new.serializable_hash }

  it(nil, rox: { key: '9407aafe238d' }){ should hyperlink_to('self', api_uri, title: t('api.root.title')) }
  it(nil, rox: { key: '76b0f021ae87' }){ should hyperlink_to('help', uri(:doc_api_overview), type: media_type(:markdown), title: t('api.root.help')) }
  it(nil, rox: { key: '9482fb379866' }){ should hyperlink_to('version-history', uri(:doc_changelog), type: media_type(:markdown), title: t('api.root.changelog')) }
  it(nil, rox: { key: 'a5afe4dd2af1' }){ should hyperlink_to('v1:projects', api_uri(:projects), title: t('api.root.projects')) }
  it(nil, rox: { key: 'dc7c4d4eaf94' }){ should hyperlink_to('v1:test-keys', api_uri(:test_keys), title: t('api.root.test_keys')) }
  it(nil, rox: { key: '691e9cae0eca' }){ should hyperlink_to('v1:test-payloads', api_uri(:payloads), type: media_type(:payload_v1), title: t('api.root.payloads')) }
  it(nil, rox: { key: '75c900a99394' }){ should have_only_properties(appVersion: ROXCenter::Application::VERSION) }
  it(nil, rox: { key: 'd94e0a55674a' }){ should have_curie(name: 'v1', templated: true, href: "#{uri(:doc_api_relation, name: 'v1')}:root:{rel}") }
end
