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
require 'spec_helper'

describe TestPayloadProcessing::ProcessResult, probedock: { tags: :unit } do
  let(:runner){ create :user }
  let(:project_version){ create :project_version }
  let(:organization){ project_version.project.organization }
  let!(:test_payload){ create :test_payload, runner: runner, project_version: project_version, ended_at: 3.minutes.ago }
  let(:category){ create :category, organization: organization }
  let(:tags){ Array.new(3){ |i| create :tag } }
  let(:tickets){ Array.new(2){ |i| create :ticket } }
  let(:test_results){ Array.new(3){ |i| double } }
  let(:test_key){ create :test_key, user: runner, project: project_version.project }

  let!(:cache_double) do
    double({
      test_results: test_results,
      register_result: nil,
      test_key: test_key,
      category: category
    }).tap do |d|
      allow(d).to receive(:tag){ |name| tags.find{ |tag| tag.name == name } }
      allow(d).to receive(:ticket){ |name| tickets.find{ |ticket| ticket.name == name } }
    end
  end

  it "should process a minimal result", probedock: { key: 'wbkt' } do

    data = {
      'n' => 'It should work',
      'd' => 134
    }

    expect_cache_calls data

    processing_result = process_result data

    expect_changes test_result: 1
    result = expect_result last_result, data, test_payload
    expect(processing_result.test_result).to eq(result)
    expect(result.payload_properties_set).to match_array(%i(name))
    expect(cache_double).to have_received(:register_result).with(result)
  end

  it "should process a full result", probedock: { key: 'k08h' } do

    data = {
      'n' => 'It should also work',
      'k' => test_key.key,
      'p' => false,
      'v' => false,
      'd' => 532,
      'm' => 'Oops...',
      'c' => category.name,
      'g' => tags.collect(&:name),
      't' => tickets.collect(&:name),
      'a' => { 'foo' => 'bar', 'baz' => 'qux' }
    }

    expect_cache_calls data

    processing_result = process_result data

    expect_changes test_result: 1
    result = expect_result last_result, data, test_payload
    expect(processing_result.test_result).to eq(result)
    expect(result.payload_properties_set).to match_array(%i(key name category tags tickets custom_values))
    expect(cache_double).to have_received(:register_result).with(result)
  end

  it "should process a result with explicit default values", probedock: { key: 'bjzc' } do

    data = {
      'n' => 'It should also work',
      'k' => nil,
      'p' => true,
      'v' => true,
      'd' => 6823,
      'm' => nil,
      'c' => nil,
      'g' => [],
      't' => [],
      'a' => {}
    }

    expect_cache_calls data

    processing_result = process_result data

    expect_changes test_result: 1
    result = expect_result last_result, data, test_payload
    expect(processing_result.test_result).to eq(result)
    expect(result.payload_properties_set).to match_array(%i(key name category tags tickets custom_values))
    expect(cache_double).to have_received(:register_result).with(result)
  end

  it "should raise an error if the specified test key is not found in the cache", probedock: { key: 'y59e' } do

    data = {
      'n' => 'It should work',
      'k' => 'foo',
      'd' => 134
    }

    expect_cache_calls data

    allow(cache_double).to receive(:test_key).and_return(nil)
    expect{ process_result data }.to raise_error("Expected to find test key 'foo' in cache")

    expect_no_change
    expect(cache_double).not_to have_received(:register_result)
  end

  it "should raise an error if the specified category is not found in the cache", probedock: { key: 'ta52' } do

    data = {
      'n' => 'It should work',
      'd' => 134,
      'c' => 'foo'
    }

    expect_cache_calls data

    allow(cache_double).to receive(:category).and_return(nil)
    expect{ process_result data }.to raise_error("Expected to find category 'foo' in cache")

    expect_no_change
    expect(cache_double).not_to have_received(:register_result)
  end

  it "should raise an error if one of the specified tags is not found in the cache", probedock: { key: 'l7ib' } do

    data = {
      'n' => 'It should work',
      'd' => 134,
      'g' => [ tags[0].name, 'foo', tags[1].name ]
    }

    expect_cache_calls data, tags: data['g'][0, 2]

    expect{ process_result data }.to raise_error("Expected to find tag 'foo' in cache")

    expect_no_change
    expect(cache_double).not_to have_received(:register_result)
  end

  it "should raise an error if one of the specified tickets is not found in the cache", probedock: { key: 'cl44' } do

    data = {
      'n' => 'It should work',
      'd' => 134,
      't' => [ tickets[0].name, 'foo' ]
    }

    expect_cache_calls data

    expect{ process_result data }.to raise_error("Expected to find ticket 'foo' in cache")

    expect_no_change
    expect(cache_double).not_to have_received(:register_result)
  end

  it 'should correct java class metatada when the value is wrong', probedock: { key: 'sn8o' } do
    data = {
      'n' => 'It should also work',
      'k' => test_key.key,
      'p' => false,
      'v' => false,
      'd' => 532,
      'm' => 'Oops...',
      'c' => category.name,
      'g' => tags.collect(&:name),
      't' => tickets.collect(&:name),
      'a' => { 'java.class' => 'io.probedock.QualifiedClassName' }
    }

    process_result(data)
    expect(last_result.custom_values['java.class']).to eq('QualifiedClassName')
  end

  it 'should keep java class metatada unchanged when the value is correct', probedock: { key: '683c' } do
    data = {
      'n' => 'It should also work',
      'k' => test_key.key,
      'p' => false,
      'v' => false,
      'd' => 532,
      'm' => 'Oops...',
      'c' => category.name,
      'g' => tags.collect(&:name),
      't' => tickets.collect(&:name),
      'a' => { 'java.class' => 'CorrectClassName' }
    }

    process_result(data)
    expect(last_result.custom_values['java.class']).to eq('CorrectClassName')
  end

  private

  def process_result data
    store_preaction_state
    described_class.new data, test_payload, cache_double
  end

  def expect_cache_calls data = {}, options = {}
    expect(cache_double).to receive(:test_results)
    expect_cache_call :test_key, options.fetch(:key, data['k'])
    expect_cache_call :category, options.fetch(:category, data['c'])
    expect_cache_call :tag, options.fetch(:tags, data['g']), true
    expect_cache_call :ticket, options.fetch(:tickets, data['t']), true
  end

  def expect_cache_call method, value, multiple = false
    if multiple && value.present?
      value.each do |v|
        expect(cache_double).to receive(method).ordered.with(v)
      end
    elsif !multiple && value
      expect(cache_double).to receive(method).with(value)
    else
      expect(cache_double).not_to receive(method)
    end
  end

  def expect_result result, data, test_payload, options = {}
    expect(result.name).to eq(data['n'])
    expect(result.passed).to be(data.fetch('p', true))
    expect(result.duration).to eq(data['d'])
    expect(result.active).to be(data.fetch('p', true))
    expect(result.new_test).to be(false)
    expect(result.message).to eq(data['m'])
    expect(result.custom_values).to eq(data.fetch('a', {}))
    expect(result.key.try(:key)).to eq(data['k'])
    expect(result.test).to be_nil
    expect(result.runner).to eq(test_payload.runner)
    expect(result.project_version).to eq(test_payload.project_version)
    expect(result.test_payload).to eq(test_payload)
    expect(result.category.try(:name)).to eq(data['c'])
    expect(result.tags.collect(&:name)).to eq(data.fetch('g', []))
    expect(result.tickets.collect(&:name)).to eq(data.fetch('t', []))
    expect(result.run_at).to be_within(0.001).of(test_payload.ended_at)
    expect(result.payload_index).to eq(test_results.length)
    result
  end

  def last_result
    TestResult.order('created_at DESC').first
  end
end
