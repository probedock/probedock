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
class TestValue < ActiveRecord::Base
  include QuickValidation

  belongs_to :test_description

  strip_attributes except: :contents
  validates :test_description, presence: { unless: :quick_validation }
  validates :name, presence: true, uniqueness: { scope: :test_description_id }, length: { maximum: 50 }
  validates :contents, length: { maximum: 65535, allow_nil: true, tokenizer: lambda{ |s| OpenStruct.new length: s.bytesize } }
end
