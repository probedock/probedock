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
module ROXCenter
  class TestPayloadsApi < Grape::API

    namespace do

      before do
        authenticate!
      end

      namespace do

        parser :json, nil

        post :publish do

          received_at = Time.now

          body = env['api.request.input']
          json = Oj.load body, mode: :strict

          payload = TestPayload.new runner: current_user, received_at: received_at, run_ended_at: received_at
          payload.contents = json
          payload.contents_bytesize = body.bytesize

          payload = create_record payload

          status 202

          {
            payload: payload.to_builder.attributes!
          }
        end
      end

      namespace :payloads do

        get do
          TestPayload.tableling.process(params)
        end
      end
    end
  end
end
