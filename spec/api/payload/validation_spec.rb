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
# encoding: UTF-8
require 'spec_helper'

describe "API payload validations", rox: { tags: :unit } do

  let(:user){ create :user }
  let(:one_byte_char){ "\u0061" }
  let(:two_byte_char){ "\u0233" }
  let(:three_byte_char){ "\u3086" }
  let(:projects){ Array.new(2){ |i| create :project } }
  let(:test_keys){ Array.new(3){ |i| create :test_key, user: user, project: i < 2 ? projects[0] : projects[1] } }
  let(:sample_payload) do
    {
      u: "f47ac10b-58cc",
      g: "nightly",
      d: 3600000,
      r: [
        {
          j: projects[0].api_id,
          v: "1.0.2",
          t: [
            {
              k: test_keys[0].key,
              n: "Test 1",
              p: true,
              d: 500,
              f: 1,
              m: "It works!",
              c: "soapui",
              g: [ "integration", "performance" ],
              t: [ "#152", "#567" ],
              a: {
                sql_nb_queries: "4",
                custom: "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
              }
            },
            {
              k: test_keys[1].key,
              n: "Test 2",
              p: false,
              d: 5000,
              f: 0,
              m: "Foo",
              c: "selenium",
              g: [ "automated" ],
              t: [ "#567" ],
              a: {
                custom: "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
              }
            }
          ]
        },
        {
          j: projects[1].api_id,
          v: "1.0.2",
          t: [
            {
              k: test_keys[2].key,
              n: "Test 3",
              p: true,
              d: 300,
              m: "It also works!",
              c: "junit",
              g: [ "unit", "captcha" ],
              t: [ "#990" ]
            }
          ]
        }
      ]
    }
  end

  before :each do
    ResqueSpec.reset!
  end

  it "should accept a valid payload", rox: { key: 'b0554b845238' } do
    assert_accepted sample_payload
  end

  context "for existing tests" do

    it "should accept an existing test without a name", rox: { key: '59cf76bea3e1' } do
      create :test, key: test_keys[0], test_run: create(:run, runner: user)
      test_keys[0].update_attribute :free, false
      sample_payload[:r][0][:t][0].delete :n
      assert_accepted sample_payload
    end

    it "should accept a test with a null category", rox: { key: '4463af7bb73a' } do
      sample_payload[:r][0][:t][0][:c] = nil
      assert_accepted sample_payload
    end

    it "should accept a test with empty tags", rox: { key: '2a155ed13d54' } do
      sample_payload[:r][1][:t][0][:g] = []
      assert_accepted sample_payload
    end

    it "should accept a test with empty tickets", rox: { key: '4c17a4e712f6' } do
      sample_payload[:r][1][:t][0][:t] = []
      assert_accepted sample_payload
    end
  end

  it "should fail if the JSON is invalid", rox: { key: '58338a3e18b7' } do
    assert_fail 'fubar', :invalidJson, false
  end

  it "should fail if the payload is not an object", rox: { key: '31ae39bfd026' } do
    assert_fail [].to_json, :invalidValue, ''
  end

  it "should fail if the duration of the test run is missing", rox: { key: 'cc07998847f1' } do
    sample_payload.delete :d
    assert_fail sample_payload, :missingKey, "/d"
  end

  it "should fail if the duration of the test run is invalid", rox: { key: 'ed475fda4914' } do
    sample_payload[:d] = 'fubar'
    assert_fail sample_payload, :invalidValue, "/d", got('fubar')
  end

  it "should fail if the uid of the test run is not a string", rox: { key: '056168b73b33' } do
    sample_payload[:u] = 666
    assert_fail sample_payload, :invalidValue, "/u", got(:number)
  end

  it "should fail if the uid of the test run is too long", rox: { key: 'b28146cfff22' } do
    sample_payload[:u] = 'x' * 256
    assert_fail sample_payload, :valueTooLong, "/u", got('256'.to_sym)
  end

  it "should fail if the uid of the test run is blank", rox: { key: '9f48ae42f306' } do
    sample_payload[:u] = '   '
    assert_fail sample_payload, :blankValue, "/u"
  end

  it "should fail if the test run corresponding to the uid was created by another user", rox: { key: '615c01e73ae5' } do
    other_user = create :other_user
    run = create :run_with_uid, runner: other_user
    sample_payload[:u] = run.uid
    assert_fail sample_payload, :forbiddenTestRunUid, "/u"
  end

  it "should fail if the group of a test run is not a string", rox: { key: '729addd2d604' } do
    sample_payload[:g] = 789
    assert_fail sample_payload, :invalidValue, "/g", got(:number)
  end

  it "should fail if the group of a test run is too long", rox: { key: 'a91c4cf82424' } do
    sample_payload[:g] = 'x' * 256
    assert_fail sample_payload, :valueTooLong, "/g", got('256'.to_sym)
  end

  it "should fail if the group of a test run is blank", rox: { key: '6bfb6b02d77e' } do
    sample_payload[:g] = '  '
    assert_fail sample_payload, :blankValue, "/g"
  end

  it "should fail if the test run has no results", rox: { key: '02702eaaced6' } do
    assert_fail sample_payload.omit(:r), :missingKey, "/r"
  end

  it "should fail if the test run contains zero results", rox: { key: '343c623ec6fd' } do
    assert_fail sample_payload.merge(r: []), :emptyArray, "/r"
  end

  it "should fail if the results of the test run are not an array", rox: { key: '71e0154abd26' } do
    assert_fail sample_payload.merge(r: { a: :b }), :invalidValue, "/r", got(:object)
  end

  it "should fail if the project of results is missing", rox: { key: '5bc7ca8dfd0b' } do
    sample_payload[:r][0].delete :j
    assert_fail sample_payload, :missingKey, "/r/0/j"
  end

  it "should fail if the project of results is not a string", rox: { key: '7039b314051e' } do
    sample_payload[:r][1][:j] = 123
    assert_fail sample_payload, :invalidValue, "/r/1/j", got(:number)
  end

  it "should fail if the project of results is blank", rox: { key: 'a788052400f0' } do
    sample_payload[:r][0][:j] = '   '
    assert_fail sample_payload, :blankValue, "/r/0/j"
  end

  it "should fail if the project of results is too long", rox: { key: '0678b771e15a' } do
    sample_payload[:r][0][:j] = 'x' * 256
    assert_fail sample_payload, :valueTooLong, "/r/0/j", got('256'.to_sym)
  end

  it "should fail if two results objects have the same project", rox: { key: '854bd4c0e187' } do
    sample_payload[:r][1][:j] = sample_payload[:r][0][:j]
    assert_fail sample_payload, :duplicateProject, "/r/1/j", got(sample_payload[:r][1][:j])
  end

  it "should fail if the version of results is missing", rox: { key: 'b255ab10a298' } do
    sample_payload[:r][0].delete :v
    assert_fail sample_payload, :missingKey, "/r/0/v"
  end

  it "should fail if the version of results is not a string", rox: { key: '9ab28d2c4be1' } do
    sample_payload[:r][0][:v] = 456
    assert_fail sample_payload, :invalidValue, "/r/0/v", got(:number)
  end

  it "should fail if the version of results is blank", rox: { key: '3e561aee5624' } do
    sample_payload[:r][1][:v] = '   '
    assert_fail sample_payload, :blankValue, "/r/1/v"
  end

  it "should fail if the version of results is too long", rox: { key: 'c1ea79dd3bb7' } do
    sample_payload[:r][1][:v] = 'x' * 256
    assert_fail sample_payload, :valueTooLong, "/r/1/v", got('256'.to_sym)
  end

  it "should fail if test results are missing", rox: { key: 'faac14a8286a' } do
    sample_payload[:r][0].delete :t
    assert_fail sample_payload, :missingKey, "/r/0/t"
  end

  it "should fail if test results are not an array", rox: { key: '310f38293c79' } do
    sample_payload[:r][0][:t] = { a: :b }
    assert_fail sample_payload, :invalidValue, "/r/0/t", got(:object)
  end

  it "should fail if a test is not an object", rox: { key: 'deb8b5da561a' } do
    sample_payload[:r][0][:t][0] = 'fubar'
    assert_fail sample_payload, :invalidValue, "/r/0/t/0", got(:string)
  end

  it "should fail if a test has no key", rox: { key: '107ad717bbbb' } do
    sample_payload[:r][0][:t][0].delete :k
    assert_fail sample_payload, :missingKey, "/r/0/t/0/k", got(sample_payload[:r][0][:t][0][:n][0, 30])
  end

  it "should fail if the key of a test is invalid", rox: { key: 'd84d7fa1c89f' } do
    sample_payload[:r][1][:t][0][:k] = 'fubar'
    assert_fail sample_payload, :invalidValue, "/r/1/t/0/k", got('fubar')
  end

  it "should fail if two tests have the same key in the same project", rox: { key: '2b74ac95de1f' } do
    sample_payload[:r][0][:t][1][:k] = sample_payload[:r][0][:t][0][:k]
    assert_fail sample_payload, :duplicateTestKey, "/r/0/t/1/k", got(sample_payload[:r][0][:t][0][:k])
  end

  it "should fail if a test has the same key as a previously stored test result in the same run (by UID)", rox: { key: '5667ad1f4c51' } do
    run = create :run_with_uid, runner: user
    create :test, key: test_keys[0], test_run: run
    test_keys[0].update_attribute :free, false
    sample_payload[:u] = run.uid
    assert_fail sample_payload, :duplicateTestKey, "/r/0/t/0/k", got(test_keys[0].key)
  end

  it "should fail if a test has an unknown key", rox: { key: 'fb21e10441ce' } do
    sample_payload[:r][1][:t][0][:k] = 'x' * 12
    assert_fail sample_payload, :unknownTestKey, "/r/1/t/0/k", got('x' * 12)
  end

  it "should fail if a test has a key from the wrong project", rox: { key: '2b6f47717974' } do
    key = sample_payload[:r][0][:t][0][:k]
    sample_payload[:r][0][:t][0][:k] = sample_payload[:r][1][:t][0][:k]
    sample_payload[:r][1][:t][0][:k] = key
    assert_fail sample_payload, :unknownTestKey, "/r/0/t/0/k", got(sample_payload[:r][0][:t][0][:k])
  end

  it "should fail if a test has no name", rox: { key: '4093268a4caa' } do
    sample_payload[:r][0][:t][1].delete :n
    assert_fail sample_payload, :missingKey, "/r/0/t/1/n", got(sample_payload[:r][0][:t][1][:k])
  end

  it "should fail if a test has a non-string name", rox: { key: '1e416abcacf4' } do
    sample_payload[:r][0][:t][0][:n] = 123
    assert_fail sample_payload, :invalidValue, "/r/0/t/0/n", got(:number)
  end

  it "should fail if the test name is blank", rox: { key: '3966cd255dca' } do
    sample_payload[:r][1][:t][0][:n] = '   '
    assert_fail sample_payload, :blankValue, "/r/1/t/0/n"
  end

  it "should fail if the test name is longer than 255 characters", rox: { key: '57230c8a8982' } do
    sample_payload[:r][1][:t][0][:n] = 'x' * 256
    assert_fail sample_payload, :valueTooLong, "/r/1/t/0/n", got('256'.to_sym)
  end

  it "should fail if a test has no passed status", rox: { key: 'e44b2d54e909' } do
    sample_payload[:r][0][:t][1].delete :p
    assert_fail sample_payload, :missingKey, "/r/0/t/1/p", got(sample_payload[:r][0][:t][1][:k])
  end

  it "should fail if a test has a passed status that is neither true nor false", rox: { key: '2175b19df4e7' } do
    sample_payload[:r][1][:t][0][:p] = 'fubar'
    assert_fail sample_payload, :invalidValue, "/r/1/t/0/p", got(:string), got(sample_payload[:r][1][:t][0][:k])
  end

  it "should fail if the category of a test is not a string", rox: { key: '951e29b2ccbc' } do
    sample_payload[:r][0][:t][0][:c] = 123
    assert_fail sample_payload, :invalidValue, "/r/0/t/0/c", got(:number), got(sample_payload[:r][0][:t][0][:k])
  end

  it "should fail if the category of a test is blank", rox: { key: '8c992da0810a' } do
    sample_payload[:r][1][:t][0][:c] = '   '
    assert_fail sample_payload, :blankValue, "/r/1/t/0/c", got(sample_payload[:r][1][:t][0][:k])
  end

  it "should fail if the category of a test is too long", rox: { key: 'da82073feb5d' } do
    sample_payload[:r][0][:t][0][:c] = 'x' * 256
    assert_fail sample_payload, :valueTooLong, "/r/0/t/0/c", got('256'.to_sym), got(sample_payload[:r][0][:t][0][:k])
  end

  it "should fail if test tags are not an array", rox: { key: 'd42f4272fbe7' } do
    sample_payload[:r][0][:t][1][:g] = 'fubar'
    assert_fail sample_payload, :invalidValue, "/r/0/t/1/g", got(:string), got(sample_payload[:r][0][:t][1][:k])
  end

  it "should fail if a test tag is not a string", rox: { key: '0a001ac4d4b3' } do
    sample_payload[:r][0][:t][0][:g] = [ 'unit', 2, 'integration' ]
    assert_fail sample_payload, :invalidValue, "/r/0/t/0/g/1", got(:number), got(sample_payload[:r][0][:t][0][:k])
  end

  it "should fail if a test tag is invalid", rox: { key: 'bbd4ce17088a' } do
    sample_payload[:r][0][:t][0][:g] = [ 'unit', '$& /', 'integration' ]
    assert_fail sample_payload, :invalidValue, "/r/0/t/0/g/1", /"\$\& \/"/, got(sample_payload[:r][0][:t][0][:k])
  end

  it "should fail if a test tag is blank", rox: { key: '0d3a5b2d4084' } do
    sample_payload[:r][0][:t][0][:g] = [ 'unit', 'integration', '   ' ]
    assert_fail sample_payload, :blankValue, "/r/0/t/0/g/2", got(sample_payload[:r][0][:t][0][:k])
  end

  it "should fail if a test tag is too long", rox: { key: '5ebfe8b3e006' } do
    sample_payload[:r][0][:t][0][:g] = [ 'unit', 'integration', 'x' * 51 ]
    assert_fail sample_payload, :valueTooLong, "/r/0/t/0/g/2", got('51'.to_sym), got(sample_payload[:r][0][:t][0][:k])
  end

  it "should not fail if a test has duplicate tags", rox: { key: '50ad48970f5a' } do
    sample_payload[:r][0][:t][1][:g] = [ 'unit', 'integration', 'unit' ]
    assert_accepted sample_payload
  end

  it "should not fail if a test has duplicate case-insensitive tags", rox: { key: 'fe3d5de7cc9b' } do
    sample_payload[:r][0][:t][0][:g] = [ 'unit', 'integration', 'Unit' ]
    assert_accepted sample_payload
  end

  it "should fail if test tickets are not an array", rox: { key: '653e232ebde0' } do
    sample_payload[:r][0][:t][0][:t] = 'fubar'
    assert_fail sample_payload, :invalidValue, "/r/0/t/0/t", got(:string), got(sample_payload[:r][0][:t][0][:k])
  end

  it "should fail if a test ticket is not a string", rox: { key: 'e80fe99629bb' } do
    sample_payload[:r][0][:t][0][:t] = [ 'JIRA-42', 4, 'JIRA-1337' ]
    assert_fail sample_payload, :invalidValue, "/r/0/t/0/t/1", got(:number), got(sample_payload[:r][0][:t][0][:k])
  end

  it "should fail if a test ticket is blank", rox: { key: '3a7860e955e4' } do
    sample_payload[:r][0][:t][0][:t] = [ 'JIRA-42', '   ', 'JIRA-1337' ]
    assert_fail sample_payload, :blankValue, "/r/0/t/0/t/1", got(sample_payload[:r][0][:t][0][:k])
  end

  it "should fail if a test ticket is too long", rox: { key: '1044b0eb1b79' } do
    sample_payload[:r][0][:t][0][:t] = [ 'JIRA-42', 'x' * 256, 'JIRA-1337' ]
    assert_fail sample_payload, :valueTooLong, "/r/0/t/0/t/1", got('256'.to_sym), got(sample_payload[:r][0][:t][0][:k])
  end

  it "should fail if a test has no duration", rox: { key: '112f3032a70f' } do
    sample_payload[:r][0][:t][0].delete :d
    assert_fail sample_payload, :missingKey, "/r/0/t/0/d", got(sample_payload[:r][0][:t][0][:k])
  end

  it "should fail if a test has an invalid duration", rox: { key: '8f5564bcc8c0' } do
    sample_payload[:r][0][:t][0][:d] = 'fubar'
    assert_fail sample_payload, :invalidValue, "/r/0/t/0/d", got('fubar'), got(sample_payload[:r][0][:t][0][:k])
  end

  it "should fail if a test has a negative duration", rox: { key: 'f3b228eb4b1f' } do
    sample_payload[:r][0][:t][1][:d] = -42
    assert_fail sample_payload, :invalidValue, "/r/0/t/1/d", got('-42'), got(sample_payload[:r][0][:t][1][:k])
  end

  it "should fail if a test has a non-string message", rox: { key: 'e15d92a89990' } do
    sample_payload[:r][0][:t][0][:m] = 42
    assert_fail sample_payload, :invalidValue, "/r/0/t/0/m", got(:number), got(sample_payload[:r][0][:t][0][:k])
  end

  it "should fail if a test has an array as message", rox: { key: 'fc3b8f446ed2' } do
    sample_payload[:r][0][:t][1][:m] = [ 'msg1', 'msg2' ]
    assert_fail sample_payload, :invalidValue, "/r/0/t/1/m", got(:array), got(sample_payload[:r][0][:t][1][:k])
  end

  it "should fail if a test message is blank", rox: { key: '4b8de51a2e36' } do
    sample_payload[:r][0][:t][1][:m] = '   '
    assert_fail sample_payload, :blankValue, "/r/0/t/1/m", got(sample_payload[:r][0][:t][1][:k])
  end

  it "should fail if a test has a message with more than 65535 one-byte characters", rox: { key: '64c807c870db' } do
    sample_payload[:r][0][:t][0][:m] = one_byte_char * 65535
    assert_accepted sample_payload
    sample_payload[:r][0][:t][0][:m] << one_byte_char
    assert_fail sample_payload, :valueTooLong, "/r/0/t/0/m", got('65536'.to_sym), got(sample_payload[:r][0][:t][0][:k])
  end

  it "should fail if a test has a message with more than 32767 two-byte characters", rox: { key: 'e28b0060e786' } do
    sample_payload[:r][0][:t][0][:m] = two_byte_char * 32767
    assert_accepted sample_payload
    sample_payload[:r][0][:t][0][:m] << two_byte_char
    assert_fail sample_payload, :valueTooLong, "/r/0/t/0/m", got('65536'.to_sym), got(sample_payload[:r][0][:t][0][:k])
  end

  it "should fail if a test has a message with more than 21845 three-byte characters", rox: { key: 'a7f7dc2aed2f' } do
    sample_payload[:r][0][:t][0][:m] = three_byte_char * 21845
    assert_accepted sample_payload
    sample_payload[:r][0][:t][0][:m] << three_byte_char
    assert_fail sample_payload, :valueTooLong, "/r/0/t/0/m", got('65538'.to_sym), got(sample_payload[:r][0][:t][0][:k])
  end

  it "should fail if a test has non-integer flags", rox: { key: '985bf3d17095' } do
    sample_payload[:r][0][:t][0][:f] = 'abc'
    assert_fail sample_payload, :invalidValue, "/r/0/t/0/f", got('abc'), got(sample_payload[:r][0][:t][0][:k])
  end

  it "should fail if a test has negative flags", rox: { key: 'cbc0865e0bea' } do
    sample_payload[:r][0][:t][1][:f] = -66
    assert_fail sample_payload, :invalidValue, "/r/0/t/1/f", got('-66'), got(sample_payload[:r][0][:t][1][:k])
  end

  it "should fail if a test has non-object data", rox: { key: '6becf500b37b' } do
    sample_payload[:r][0][:t][0][:a] = 'abc'
    assert_fail sample_payload, :invalidValue, "/r/0/t/0/a", got(:string), got(sample_payload[:r][0][:t][0][:k])
  end

  it "should fail if a test data name is blank", rox: { key: 'f3bd3c1e72df' } do
    sample_payload[:r][1][:t][0][:a] = { '   ' => 'foo' }
    assert_fail sample_payload, :blankValue, "/r/1/t/0/a", got(sample_payload[:r][1][:t][0][:k])
  end

  it "should fail if a test data name is too long", rox: { key: 'e2313b600917' } do
    sample_payload[:r][1][:t][0][:a] = { 'x' * 51 => 'foo' }
    assert_fail sample_payload, :keyTooLong, "/r/1/t/0/a", got('51'.to_sym), got(sample_payload[:r][1][:t][0][:k])
  end

  it "should fail if a test data value is not a string", rox: { key: '694fa7ad8603' } do
    sample_payload[:r][1][:t][0][:a] = { 'foo' => 123 }
    assert_fail sample_payload, :invalidValue, "/r/1/t/0/a", got(:number), got(sample_payload[:r][1][:t][0][:k])
  end

  it "should fail if a test data value is too long", rox: { key: '8ce3929ed1cc' } do
    sample_payload[:r][0][:t][0][:a] = { 'foo' => 'x' * 256 }
    assert_fail sample_payload, :valueTooLong, "/r/0/t/0/a", got('256'.to_sym), got(sample_payload[:r][0][:t][0][:k])
  end

  private

  def got text
    text.kind_of?(Symbol) ? Regexp.new(text.to_s) : Regexp.new(%/"#{text}"/)
  end

  def assert_accepted payload
    post_api_payload payload.to_json, user
    assert_response :accepted
  end

  def assert_fail payload, code, path, *matches

    options = matches.last.kind_of?(Hash) ? matches.pop : {}

    request_body = payload.kind_of?(Hash) ? payload.to_json : payload
    post_api_payload request_body, user unless @do_not_send

    check_api_errors [ { name: code, path: path, message: matches } ]
  end
end
