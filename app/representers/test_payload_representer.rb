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
class TestPayloadRepresenter < BaseRepresenter

  representation do |payload,*args|
    options = args.last.kind_of?(Hash) ? args.pop : {}

    #curie 'v1', "#{uri(:doc_api_relation, name: 'v1')}:testPayloads:{rel}", templated: true

    link 'self', api_uri(:test_payload, id: payload.id)

    property :state, payload.state.to_s
    property :bytes, payload.contents_bytesize
    property :receivedAt, payload.received_at.to_ms
    property :processingAt, payload.processing_at.to_ms if payload.processing_at
    property :processedAt, payload.processed_at.to_ms if payload.processed_at
    property :contents, Base64.strict_encode64(payload.contents) if options[:detailed]
  end
end
