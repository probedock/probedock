# Copyright (c) 2015 ProbeDock
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
shared_examples_for "a table resource" do |config|

  subject{ parse_response }

  it "should have the correct number of embedded resources" do
    expect(embedded(subject)).to have(records.length).items
  end

  if config[:serialization]

    it "should correctly serialize records" do
      
      res = parse_response sort: [ "#{config[:serialization][:sort]} asc" ]
      
      representer_class = config[:serialization][:representer]
      representation = representer.new total: records.length, page: 1, data: config[:serialization][:records].call(records)

      expect(res).to eq(representation.serializable_hash)
    end
  end

  if config[:pagination]
    let(:pagination_sort){ [ "#{config[:pagination][:sort]} asc" ] }
    let(:pagination_records){ config[:pagination][:sorted].call records }

    it "should get the first page sorted by #{config[:pagination][:sort]}" do
      raise "At least two records are expected to test the first page" unless pagination_records.length >= 2

      res = parse_response sort: pagination_sort, page: 1, pageSize: 2
      expect(res[:total]).to eq(records.length)

      compare_records pagination_records[0, 2], embedded(res)
    end

    it "should get the second page sorted by #{config[:pagination][:sort]}" do
      raise "At least four records are expected to test the second page" unless pagination_records.length >= 4

      res = parse_response sort: pagination_sort, page: 2, pageSize: 2
      expect(res[:total]).to eq(records.length)

      compare_records pagination_records[2, 2], embedded(res)
    end

    it "should get the last page sorted by #{config[:pagination][:sort]}" do
      raise "An odd number of records is expected to test pagination" unless pagination_records.length.odd?

      pages = (pagination_records.length.to_f / 2).ceil
      res = parse_response sort: pagination_sort, page: pages, pageSize: 2
      expect(res[:total]).to eq(records.length)

      compare_records pagination_records[(pages - 1) * 2, 1], embedded(res)
    end
  end

  if config[:sorting]
    config[:sorting].each_pair do |key,results_block|

      it "should sort by #{key} asc" do

        res = parse_response sort: [ "#{key} asc" ]
        expect(res[:total]).to eq(records.length)

        compare_records results_block.call(records), embedded(res)
      end

      it "should sort by #{key} desc" do

        res = parse_response sort: [ "#{key} desc" ]
        expect(res[:total]).to eq(records.length)

        compare_records results_block.call(records).reverse, embedded(res)
      end
    end
  end

  if config[:quick_search]
    config[:quick_search].each do |search|

      it "should find the correct resources by #{search[:name]}" do
        data = search[:block].call records
        expected = data[:results]
        actual = embedded parse_response(sort: [ "#{data[:sort]} asc" ], quickSearch: data[:term])
        compare_records expected, actual
      end
    end
  end

  def embedded res
    res[:_embedded][embedded_rel]
  end

  def compare_records expected, actual
    expect(expected.collect(&record_converter)).to eq(actual.collect(&embedded_converter))
  end
end
