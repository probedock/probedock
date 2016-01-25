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
require_dependency 'errapi_utils'

module ProbeDock
  class PayloadsApi < Grape::API
    format :json
    default_format :json

    # accept Probe Dock JSON payloads
    content_type :payload_v1, 'application/vnd.probedock.payload.v1+json'
    content_type :json, 'application/json'

    # accept xUnit XML payloads
    content_type :xml, 'application/xml'

    # accept the above as uploaded files
    content_type :multipart, 'multipart/form-data'

    # disable automatic parsing by Grape for this resource
    parser :payload_v1, nil
    parser :json, nil
    parser :xml, nil
    parser :multipart, nil

    namespace do

      before do
        authenticate!
      end

      namespace do

        params do
          optional :payload, type: File
        end

        helpers do
          def content_type_without_parameters content_type
            content_type.sub /;.*/, ''
          end

          def content_type? content_type, *types
            ct = content_type_without_parameters content_type
            types.any?{ |type| Mime::Type.lookup_by_extension(type) === ct }
          end

          def request_content_type? *types
            content_type? request.content_type, *types
          end
        end

        post :publish do

          # check that the required "payload" file is present for multipart/form-data requests
          if request_content_type?(:multipart_form_data) && params.payload.blank?
            validation_context.add_error reason: :missing do |error|
              ErrapiUtils.add_location error, :payload, :multipartFormData
            end

            raise Errapi::ValidationFailed.new(validation_context)
          end

          received_at = Time.now.utc

          payload_type = nil
          raw_payload = nil
          raw_payload_content_type = nil

          # get the test payload data from the request body or the multipart file upload
          if request_content_type? :multipart_form_data
            raw_payload = File.read params.payload.tempfile
            raw_payload_content_type = params.payload.type
          else
            raw_payload = env['api.request.input']
            raw_payload_content_type = request.content_type
          end

          # determine the payload type
          if content_type? raw_payload_content_type, :json, :text_json, :probedock_payload_v1
            payload_type = :json
          elsif content_type? raw_payload_content_type, :xml, :text_xml
            payload_type = :xml
          end

          # parse and validate the test payload with the
          # correct parser depending on the content type
          case payload_type
          when :json # parse Probe Dock JSON payload
            payload_contents = MultiJson.load raw_payload
            TestPayloadValidations.validate payload_contents, validation_context, location_type: :json, raise_error: true
          when :xml # parse xUnit XML payload
            payload_contents = TestPayloadXunitParser.new(raw_payload, headers).parse
          else
            status 415
            return nil
          end

          # FIXME: do not accept payloads in the future
          ended_at = received_at
          ended_at = Time.parse payload_contents['endedAt'] if payload_contents.key?('endedAt')

          # FIXME: foreign key validation
          project_api_id = payload_contents['projectId']
          project = Project.where(api_id: project_api_id.to_s).first
          Pundit.authorize current_user, project, :publish?

          project_version = payload_contents['version']

          # save the payload to the database
          payload = TestPayload.new runner: current_user, received_at: received_at, ended_at: ended_at
          payload.contents = payload_contents
          payload.contents_bytesize = raw_payload.bytesize

          # save the original payload if not JSON (e.g. xUnit payload)
          payload.raw_contents = raw_payload if payload_type != :json

          unless payload.save
            return record_errors payload
          end

          # add the payload to the asynchronous processing queue
          Resque.enqueue ProcessNextTestPayloadJob

          status 202

          {
            receivedAt: received_at.iso8601(3),
            payloads: [
              {
                id: payload.api_id,
                projectId: project.api_id,
                projectVersion: project_version,
                duration: payload_contents['duration'],
                runnerId: current_user.api_id,
                endedAt: payload.ended_at.iso8601(3),
                bytes: payload.contents_bytesize
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
