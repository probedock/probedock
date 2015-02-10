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

describe TestPayloadRepresenter, rox: { tags: :unit } do

  it "should serialize basic properties", rox: { key: 'dcc6aef9a144' } do
    payload = create :test_payload
    expect(representation(payload)).to hyperlink_to('self', api_uri(:test_payload, id: payload.id))
    expect(representation(payload)).to have_only_properties(common_properties(payload))
    expect(representation(payload, detailed: true)).to have_only_properties(common_properties(payload).merge({
      contents: Base64.strict_encode64(payload.contents)
    }))
  end

  it "should serialize a payload in processing state", rox: { key: 'bcf30dec3ce9' } do
    payload = create :processing_test_payload
    expect(representation(payload)).to hyperlink_to('self', api_uri(:test_payload, id: payload.id))
    expect(representation(payload)).to have_only_properties(common_properties(payload).merge(processingAt: payload.processing_at.to_ms))
    expect(representation(payload, detailed: true)).to have_only_properties(common_properties(payload).merge({
      processingAt: payload.processing_at.to_ms,
      contents: Base64.strict_encode64(payload.contents)
    }))
  end

  it "should serialize a payload in processed state", rox: { key: '5be656752f67' } do
    payload = create :processed_test_payload
    expect(representation(payload)).to hyperlink_to('self', api_uri(:test_payload, id: payload.id))
    expect(representation(payload)).to have_only_properties(common_properties(payload).merge(processingAt: payload.processing_at.to_ms, processedAt: payload.processed_at.to_ms))
    expect(representation(payload, detailed: true)).to have_only_properties(common_properties(payload).merge({
      processingAt: payload.processing_at.to_ms,
      processedAt: payload.processed_at.to_ms,
      contents: Base64.strict_encode64(payload.contents)
    }))
  end

  def representation payload, options = {}
    TestPayloadRepresenter.new(payload, options).serializable_hash
  end

  def common_properties payload
    { state: payload.state.to_s, bytes: payload.contents_bytesize, receivedAt: payload.received_at.to_ms }
  end
end
