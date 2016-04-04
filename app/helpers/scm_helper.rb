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
module ScmHelper
  def build_source_url(result, project, payload)
    if project.repo_url && result.custom_values['file.path']
      matched_type = /.*(github|gitlab|bitbucket)\.com\/.*/.match(project.repo_url)

      if !project.repo_url_pattern.blank?
        build_patterned_url(project.repo_url, project.repo_url_pattern, result, payload)
      elsif matched_type
        send('build_' +  matched_type[1] + '_url', project.repo_url, result, payload)
      end
    end
  end

  def build_scm_data(payload)
    scm = {}
    scm[:name] = payload.scm_name if payload.scm_name.present?
    scm[:version] = payload.scm_version if payload.scm_version.present?
    scm[:branch] = payload.scm_branch if payload.scm_branch.present?
    scm[:commit] = payload.scm_commit if payload.scm_commit.present?
    scm[:dirty] = payload.scm_dirty unless payload.scm_dirty.nil?

    # Create the remote node only if there is at least one attribute present
    if %w(name fetch_url push_url ahead behind).any?{ |attr| payload.send 'scm_remote_' + attr }
      scm[:remote] = {}
      scm[:remote][:name] = payload.scm_remote_name if payload.scm_remote_name.present?
      scm[:remote][:ahead] = payload.scm_remote_ahead if payload.scm_remote_ahead.present?
      scm[:remote][:behind] = payload.scm_remote_behind if payload.scm_remote_behind.present?

      # Create the url node only if there is at least one attribute present
      if %w(fetch_url push_url).any?{ |attr| payload.send 'scm_remote_' + attr }
        scm[:remote][:url] = {}
        scm[:remote][:url][:fetch] = payload.scm_remote_fetch_url if payload.scm_remote_fetch_url.present?
        scm[:remote][:url][:push] = payload.scm_remote_push_url if payload.scm_remote_push_url.present?
      end
    end

    scm
  end

  private

  def build_patterned_url(repo_url, repo_url_pattern, result, payload)
    # Make sure the URL is complete
    url = if repo_url_pattern.match(/\{\{\s*repoUrl\s*\}\}/)
      repo_url_pattern.gsub(/\{\{\s*repoUrl\s*\}\}/, repo_url)
    else
      repo_url + repo_url_pattern
    end

    # Replace the branch
    url = url.gsub(/\{\{\s*branch\s*\}\}/, payload.scm_branch) if payload.scm_branch.present?

    # Replace the commit
    url = url.gsub(/\{\{\s*commit\s*\}\}/, payload.scm_commit) if payload.scm_commit.present?

    # Replace the file
    url = url.gsub(/\{\{\s*filePath\s*\}\}/, result.custom_values['file.path']) if result.custom_values['file.path']

    # Replace the line
    url = url.gsub(/\{\{\s*fileLine\s*\}\}/, result.custom_values['file.line'].to_s) if result.custom_values['file.line']

    url
  end

  def build_github_url(repo_url, result, payload)
    # <repo_url>/blob/<commit>/<file_path>(#L<file_line>)
    path = join(repo_url, 'blob', payload.scm_commit, result.custom_values['file.path']) if payload.scm_commit.present? && result.custom_values['file.path'].present?
    path = "#{path}#L#{result.custom_values['file.line']}" if path && result.custom_values['file.line']
    path
  end

  def build_gitlab_url(repo_url, result, payload)
    # Same URL as GitHub
    # <repo_url>/blob/<commit>/<file_path>(#L<file_line>)
    build_github_url(repo_url, result, payload)
  end

  def build_bitbucket_url(repo_url, result, payload)
    # <repo_url>/src/<commit>/<file_path>(#file_name)-<file_line>
    path = join(repo_url, 'src', payload.scm_commit, result.custom_values['file.path']) if payload.scm_commit && result.custom_values['file.path']
    path = "#{path}##{result.custom_values['file.path'].gsub(/.*\//, '')}-#{result.custom_values['file.line']}" if path && result.custom_values['file.line']
    path
  end

  def join(*paths, separator: '/')
    paths = paths.compact.reject(&:empty?)
    last = paths.length - 1
    paths.each_with_index.map { |path, index| expand(path, index, last, separator) }.join
  end

  def expand(path, current, last, separator)
    if path.starts_with?(separator) && current != 0
      path = path[1..-1]
    end

    unless path.ends_with?(separator) || current == last
      path = [path, separator]
    end

    path
  end
end
