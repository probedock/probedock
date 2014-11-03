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
class TestPayload < ActiveRecord::Base
  include JsonResource
  include IdentifiableResource
  include Tableling::Model

  before_create{ set_identifier :api_id }

  belongs_to :runner, class_name: 'User'
  has_and_belongs_to_many :test_keys

  scope :waiting_for_processing, -> { where(state: :created).order('received_at ASC') }
  scope :for_listing, ->{ select('id, state, received_at, processing_at, processed_at, contents_bytesize').order('received_at ASC') }

  include SimpleStates
  states :created, :processing, :processed
  event :start_processing, from: :created, to: :processing
  event :finish_processing, from: :processing, to: :processed

  validates :runner, presence: true
  #validates :contents, presence: true, length: { maximum: 16777215, tokenizer: lambda{ |s| OpenStruct.new length: s.bytesize } }
  validates :contents_bytesize, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :state, inclusion: { in: state_names.inject([]){ |memo,name| memo << name << name.to_s } }
  validates :received_at, presence: true
  validates :run_ended_at, presence: true

  tableling do

    default_view do

      field :received_at, as: :receivedAt
      field :contents_bytesize, as: :bytes
      field :state
      field :processing_at, as: :processingAt
      field :processed_at, as: :processedAt

      serialize_response do |res|
        res[:data].collect{ |p| p.to_builder.attributes! }
      end
    end
  end

  def finish_processing
    test_keys.clear
  end

  def to_builder options = {}
    Jbuilder.new do |json|
      json.id api_id
      json.bytes contents_bytesize
      json.state state
      json.receivedAt received_at.iso8601(3)
      json.processingAt processing_at.iso8601(3) if processing_at
      json.processedAt processed_at.iso8601(3) if processed_at
    end
  end
end
