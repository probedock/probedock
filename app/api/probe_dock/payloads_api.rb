# Copyright (c) 2015 ProbeDock
# Copyright (c) 2012-2014 Lotaris SA
#
# This file is part of ProbeDock.
#
# ProbeDock is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ProbeDock is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with ProbeDock.  If not, see <http://www.gnu.org/licenses/>.
module ProbeDock
  class PayloadsApi < Grape::API
    format :json
    default_format :json

    content_type :payload_v1, 'application/vnd.probedock.payload.v1+json'
    content_type :json, 'application/json'
    content_type :xml, 'application/xml'

    parser :payload_v1, nil
    parser :json, nil
    parser :xml, nil

    namespace do

      before do
        authenticate!
      end

      namespace do

        post :publish do

          received_at = Time.now.utc

          raw_payload = nil
          raw_payload_type = :json
          body = env['api.request.input']

          case request.content_type
          when Mime::Type.lookup_by_extension(:json), Mime::Type.lookup_by_extension(:payload_v1)
            raw_payload = MultiJson.load body
            TestPayloadValidations.validate raw_payload, validation_context, location_type: :json, raise_error: true
          when Mime::Type.lookup_by_extension(:xml)
            raw_payload_type = :xml
            raw_payload = TestPayloadXunitParser.new(body, headers['Probe-Dock-Duration']).parse
          else
            status 415
            return nil
          end

          if raw_payload['reports'].blank? && uid = headers['Probe-Dock-Test-Report-Uid']
            raw_payload['reports'] = [ { 'uid' => uid } ]
          end

          # FIXME: do not accept payloads in the future
          ended_at = received_at
          ended_at = Time.parse raw_payload['endedAt'] if raw_payload_type == :json && raw_payload.key?('endedAt')

          # FIXME: foreign key validation
          project_api_id = raw_payload.fetch('projectId', headers['Probe-Dock-Project-Id']).to_s
          project = Project.where(api_id: project_api_id).first
          Pundit.authorize current_user, project, :publish?
          raw_payload['projectId'] ||= project_api_id

          project_version = raw_payload.fetch('version', headers['Probe-Dock-Project-Version']).to_s
          raw_payload['version'] ||= project_version

          payload = TestPayload.new runner: current_user, received_at: received_at, ended_at: ended_at
          payload.contents = raw_payload
          payload.contents_bytesize = body.bytesize
          payload.raw_contents = body if raw_payload_type != :json

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
                projectId: project.api_id,
                projectVersion: project_version,
                duration: raw_payload['duration'],
                runnerId: current_user.api_id,
                endedAt: payload.ended_at.iso8601(3),
                bytes: body.bytesize
              }
            ]
          }
        end
      end

      namespace :payloads do

        before do
          authenticate!
        end

        helpers do
          def current_organization
            @current_organization ||= if params[:organizationId].present?
              Organization.active.where(api_id: params[:organizationId].to_s).first!
            elsif params[:organizationName].present?
              Organization.active.where(normalized_name: params[:organizationName].to_s.downcase).first!
            end
          end
        end

        get do
          authorize! TestPayload, :index

          rel = policy_scope(TestPayload).order 'ended_at DESC'
          rel = paginated rel

          serialize load_resources(rel)
        end
      end
    end
  end
end
