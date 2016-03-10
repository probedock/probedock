# Copyright (c) 2016 ProbeDock
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

describe ScmHelper do
  result_custom_values = { 'file.path': 'path/to/the/file', 'file.line': 12 }

  scm_context = {
    'scm.name': 'git',
    'scm.version': '1.2.3',
    'scm.branch': 'star-destroyer',
    'scm.commit': '9f4b549ce75ebe92ac1bc4b697934ca1c64d7deb',
    'scm.dirty': false,
    'scm.remote.name': 'origin',
    'scm.remote.url.fetch': 'http://localhost.localdomain/galactic-empire',
    'scm.remote.url.push': 'http://localhost.localdomain/galactic-empire',
    'scm.remote.ahead': 0,
    'scm.remote.behind': 0
  }

  describe '#build_source_url' do
    context 'any provider' do
      let(:project) { build(:project) }
      let(:result) { build(:result) }
      let(:payload) { build(:test_payload) }

      it('should not be possible to build the source URL when repo is missing', probedock: { key: 'ryiv' }) do
        expect(build_source_url(result, project, payload)).to be_nil
      end
    end

    context 'unknown provider' do
      let(:result) { build(:result) }
      let(:payload) { build(:test_payload) }
      let(:project) { build(:project, repo_url: 'https://localhost.localdomain') }

      it('should not be possible to build the source URL when repo URL is not recognised', probedock: { key: 'z111' }) do
        expect(build_source_url(result, project, payload)).to be_nil
      end
    end

    context 'github' do
      let(:project) { build(:project, repo_url: 'https://github.com/probedock/galactic-empire') }
      let(:result) { build(:result, custom_values: result_custom_values) }
      let(:payload) do
        create(:test_payload, { contents_bytesize: 1, contents: { context: scm_context } })
        TestPayload.with_scm_data.first
      end

      it('should be possible to build the source URL', probedock: { key: '4os3' }) do
        expect(build_source_url(result, project, payload)).to eq('https://github.com/probedock/galactic-empire/blob/9f4b549ce75ebe92ac1bc4b697934ca1c64d7deb/path/to/the/file#L12')
      end

      it('should not be possible to build the source url when commit or file path is missing', probedock: { key: 'ythc' }) do
        result.custom_values['file.path'] = nil
        expect(build_source_url(result, project, payload)).to be_nil

        result.custom_values['file.path'] = 'path'
        payload.scm_commit = nil
        expect(build_source_url(result, project, payload)).to be_nil
      end

      it('should be possible to build the source URL without the line when missing', probedock: { key: 'xdwl' }) do
        result.custom_values['file.line'] = nil
        expect(build_source_url(result, project, payload)).to eq('https://github.com/probedock/galactic-empire/blob/9f4b549ce75ebe92ac1bc4b697934ca1c64d7deb/path/to/the/file')
      end
    end

    context 'gitlab' do
      let(:project) { build(:project, repo_url: 'https://gitlab.com/probedock/galactic-empire') }
      let(:result) { build(:result, custom_values: result_custom_values ) }
      let(:payload) do
        create(:test_payload, { contents_bytesize: 1, contents: { context: scm_context } })
        TestPayload.with_scm_data.first
      end

      it('should be possible to build the source URL', probedock: { key: 'lupe' }) do
        expect(build_source_url(result, project, payload)).to eq('https://gitlab.com/probedock/galactic-empire/blob/9f4b549ce75ebe92ac1bc4b697934ca1c64d7deb/path/to/the/file#L12')
      end

      it('should not be possible to build the source url when commit or file path is missing', probedock: { key: '6hmz' }) do
        result.custom_values['file.path'] = nil
        expect(build_source_url(result, project, payload)).to be_nil

        result.custom_values['file.path'] = 'path'
        payload.scm_commit = nil
        expect(build_source_url(result, project, payload)).to be_nil
      end

      it('should be possible to build the source URL without the line when missing', probedock: { key: '6wtu' }) do
        result.custom_values['file.line'] = nil
        expect(build_source_url(result, project, payload)).to eq('https://gitlab.com/probedock/galactic-empire/blob/9f4b549ce75ebe92ac1bc4b697934ca1c64d7deb/path/to/the/file')
      end
    end

    context 'bitbucket' do
      let(:project) { build(:project, repo_url: 'https://bitbucket.com/probedock/galactic-empire') }
      let(:result) { build(:result, custom_values: result_custom_values) }
      let(:payload) do
        create(:test_payload, { contents_bytesize: 1, contents: { context: scm_context } })
        TestPayload.with_scm_data.first
      end

      it('should be possible to build the source URL', probedock: { key: '1vv1' }) do
        expect(build_source_url(result, project, payload)).to eq('https://bitbucket.com/probedock/galactic-empire/src/9f4b549ce75ebe92ac1bc4b697934ca1c64d7deb/path/to/the/file#file-12')
      end

      it('should not be possible to build the source url when commit or file path is missing', probedock: { key: 'p8o6' }) do
        result.custom_values['file.path'] = nil
        expect(build_source_url(result, project, payload)).to be_nil

        result.custom_values['file.path'] = 'path'
        payload.scm_commit = nil
        expect(build_source_url(result, project, payload)).to be_nil
      end

      it('should be possible to build the source URL without the line when missing', probedock: { key: '0tbs' }) do
        result.custom_values['file.line'] = nil
        expect(build_source_url(result, project, payload)).to eq('https://bitbucket.com/probedock/galactic-empire/src/9f4b549ce75ebe92ac1bc4b697934ca1c64d7deb/path/to/the/file')
      end
    end
  end

  describe '#build_scm_data' do
    context 'no content' do
      let(:payload) do
        create(:test_payload)
        TestPayload.with_scm_data.first
      end

      it('should build an empty SCM data when no data is present', probedock: { key: 'vvzh' }) do
        expect(build_scm_data(payload)).to eq({})
      end
    end

    context 'partial content' do
      def create_payload(context)
        create(:test_payload, {
          contents_bytesize: 1,
          contents: {
            context: context
          }
        })
        TestPayload.with_scm_data.first
      end

      definitions = [
        { key: 'jtqn', name: 'name', context: { 'scm.name': 'git' }, check: { name: 'git' } },
        { key: 'tpfb', name: 'version', context: { 'scm.version': '1.2.3' }, check: { version: '1.2.3' } },
        { key: '0t12', name: 'branch', context: { 'scm.branch': 'branch' }, check: { branch: 'branch'} },
        { key: 'bii0', name: 'commit', context: { 'scm.commit': 'abcdef' }, check: { commit: 'abcdef'} },
        { key: 'duu7', name: 'dirty', context: { 'scm.dirty': true }, check: { dirty: true } },
        { key: 'ta4g', name: 'remote name', context: { 'scm.remote.name': 'origin' }, check: { remote: { name: 'origin' } } },
        { key: '1esf', name: 'remote url fetch', context: { 'scm.remote.url.fetch': 'http://localhost.localdomain' }, check: { remote: { url: { fetch: 'http://localhost.localdomain' } } } },
        { key: 'ld70', name: 'remote url push', context: { 'scm.remote.url.push': 'http://localhost.localdomain' }, check: { remote: { url: { push: 'http://localhost.localdomain' } } } },
        { key: 'gow6', name: 'remote ahead', context: { 'scm.remote.ahead': 1}, check: { remote: { ahead: 1 } } },
        { key: 'gufm', name: 'remote behind', context: { 'scm.remote.behind': 2}, check: { remote: { behind: 2 } } }
      ]

      definitions.each do |definition|
        it("should only contain #{definition[:name]} when present", probedock: { key: "#{definition[:key]}" }) do
          expect(build_scm_data(create_payload(definition[:context]))).to eq(definition[:check])
        end
      end
    end

    context 'full content' do
      let(:payload) do
        create(:test_payload, { contents_bytesize: 1, contents: { context: scm_context } })
        TestPayload.with_scm_data.first
      end

      it('should contain all the data', probedock: { key: '7q1i' }) do
        expect(build_scm_data(payload)).to eq({
          name: 'git',
          version: '1.2.3',
          branch: 'star-destroyer',
          commit: '9f4b549ce75ebe92ac1bc4b697934ca1c64d7deb',
          dirty: false,
          remote: {
            name: 'origin',
            ahead: 0,
            behind: 0,
            url: {
              fetch: 'http://localhost.localdomain/galactic-empire',
              push: 'http://localhost.localdomain/galactic-empire'
            }
          }
        })
      end
    end
  end
end
