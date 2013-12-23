# Copyright (c) 2012-2013 Lotaris SA
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

class Project < ActiveRecord::Base
  include Metric
  include Tableling::Model
  URL_TOKEN_REGEXP = /\A[a-z0-9\_\-]+\Z/i
  # TODO: rename active_tests_count to current_tests_count to avoid confusion with active/inactive

  before_create :set_api_id

  has_many :tests, class_name: 'TestInfo'

  strip_attributes
  validates :name, presence: { name: :blankValue }, length: { maximum: 255, name: :valueTooLong }
  validates :url_token, presence: { name: :blankValue }, length: { maximum: 25, name: :valueTooLong }, format: { with: URL_TOKEN_REGEXP, name: :invalidValue, unless: Proc.new{ |p| p.url_token.blank? } }

  tableling do

    default_view do

      field :name
      field :url_token, as: :urlToken
      field :api_id, as: :apiId
      # FIXME: make sure these attributes are updated
      field :active_tests_count, as: :activeTestsCount
      field :deprecated_tests_count, as: :deprecatedTestsCount
      field :created_at, as: :createdAt

      quick_search do |q,t|
        term = "%#{t.downcase}%"
        q.where 'LOWER(name) LIKE ? OR LOWER(url_token) LIKE ? OR LOWER(api_id) LIKE ?', term, term, term
      end

      serialize_response do |res|
        ProjectsRepresenter.new OpenStruct.new(res)
      end
    end
  end

  # TODO: remove Project#to_client_hash once TestInfo has a representer
  def to_client_hash options = {}
    { name: name, apiId: api_id, urlToken: url_token }
  end

  def to_param options = {}
    url_token
  end

  private

  def self.new_api_id
    next while exists?(api_id: id = generate_api_id)
    id
  end

  def self.generate_api_id
    SecureRandom.hex 6
  end

  def set_api_id
    self.api_id = self.class.new_api_id
  end
end
