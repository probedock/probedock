# Copyright (c) 2015 42 inside
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
module ProbeDock
  class PayloadsApi < Grape::API
    content_type :payload_v1, 'application/vnd.probe-dock.payload.v1+json'

    namespace do

      before do
        authenticate!
      end

      namespace do

        post :publish do

          received_at = Time.now

          body = env['api.request.input']
          json = MultiJson.load body

          TestPayloadValidations.validate json, validation_context, location_type: :json, raise_error: true

          # FIXME: do not accept payloads in the future
          ended_at = json.key?('endedAt') ? Time.parse(json['endedAt']) : received_at

          # FIXME: foreign key validation
          project = Project.where(api_id: json['projectId']).first
          Pundit.authorize current_user, project, :publish?

          payload = TestPayload.new runner: current_user, received_at: received_at, ended_at: ended_at
          payload.contents = json
          payload.contents_bytesize = body.bytesize

          unless payload.save
            return record_errors payload
          end

          Resque.enqueue ProcessNextTestPayloadJob

          status 202

          {
            receivedAt: received_at.iso8601(3),
            payloads: [
              {
                id: payload.api_id,
                bytes: body.bytesize
              }
            ]
          }
        end
      end

      namespace :payloads do

        get do
          rel = TestPayload.order 'ended_at DESC'
          paginated(rel).to_a.collect{ |p| p.to_builder.attributes! }
        end
      end
    end
  end
end
