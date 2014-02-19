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

# TODO: write specs
module Hal

  class Resource
    attr_reader :links
    attr_reader :curies
    attr_reader :properties

    @@helpers = []

    def self.helper h
      (@@helpers ||= []) << h
    end

    def self.helpers
      @@helpers || []
    end

    def initialize *args, &block

      @links, @curies, @properties, @embedded = {}, {}, {}, {}

      dsl = DSL.new self
      self.class.helpers.each{ |h| dsl.extend h } if self.class.helpers.present?
      dsl.instance_exec *args, &block if block
    end

    def link rel
      @links[rel.to_s]
    end

    def curie name
      @curies[name.to_s]
    end

    def property name
      @properties[name.to_s]
    end

    def embedded rel = nil
      rel ? @embedded[rel] : @embedded
    end

    def serializable_hash options = {}
      Hash.new.tap do |h|

        if @links.any?
          h['_links'] = @links.inject({}){ |memo,(rel,link)| memo[rel] = link.serializable_hash options; memo }
          h['_links']['curies'] = @curies.inject([]){ |memo,(name,curie)| memo << curie } if @curies.any?
        end

        h.merge! @properties

        if @embedded.any?
          h['_embedded'] = @embedded.inject({}) do |memo,(rel,resources)|
            memo[rel] = if resources.kind_of? Array
              resources.collect{ |r| r.serializable_hash options }
            else
              resources.serializable_hash options
            end
            memo
          end
        end
      end
    end

    def to_json options = {}
      serializable_hash(options).to_json
    end

    private

    class DSL
      
      def initialize resource
        @resource = resource
      end

      def link rel, *args, &block
        options = args.last.kind_of?(Hash) ? args.pop : {}
        href = block ? block.call : args.shift || options.delete(:href)
        link = Hal::Link.new rel, href, options
        @resource.links[link.rel] = link
      end

      def curie name, href, options = {}
        @resource.curies[name.to_s] = options.merge(name: name.to_s, href: href).stringify_keys
      end

      def property key, value
        @resource.properties[key.to_s] = value
      end

      def embed rel, res = nil, options = {}, &block
        res = block ? block.call(res) : res
        if options[:multiple]
          @resource.embedded[rel] ||= []
          @resource.embedded[rel] << res
        else
          @resource.embedded[rel] = res
        end
      end

      def embed_collection rel, col, &block
        @resource.embedded[rel] = block ? col.collect(&block) : col
      end
    end
  end
end
