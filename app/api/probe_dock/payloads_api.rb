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

    namespace do

      before do
        authenticate!
      end

      namespace do

        parser :json, nil

        post :publish do

          received_at = Time.now

          body = env['api.request.input']
          json = MultiJson.load body
          # TODO: validate test payload (format, byte size)

          # TODO: handle uuid conflict
          payload = TestPayload.new api_id: SecureRandom.uuid, runner: current_user, received_at: received_at, run_ended_at: received_at
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
          # TODO: do not fetch payload contents from database
          TestPayload.tableling.process(params)
        end
      end
    end
  end
end
