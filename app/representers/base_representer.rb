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
class BaseRepresenter < Hal::Resource
  # TODO: write specs
  helper RepresenterHelpers

  def initialize *args
    super *args, &self.class.representation
  end

  def self.representation &block
    @representation = block if block
    @representation
  end

  def self.collection_representation name, representer, options = {}, &block

    camelcase_name = name.to_s.camelize :lower
    hyphenized_name = name.to_s.gsub /\_/, '-'

    representation do |res|

      instance_exec res, &block if block

      curie 'v1', "#{uri(:doc_api_relation, name: 'v1')}:#{camelcase_name}:{rel}", templated: true

      link 'self', options[:uri] ? uri(options[:uri]) : api_uri(name) unless link? 'self'

      property :total, res.total
      property :page, res.page if res.page

      embed_collection("v1:#{hyphenized_name}", res.data){ |o| representer.new o, res }
    end
  end
end
