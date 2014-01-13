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
class PygmentsHTML < Redcarpet::Render::HTML

  def block_code code, language
    Pygments.highlight code, :lexer => language
  end
end

MarkdownRails.configure do |config|

  # FIXME: enable pygments (also in pygments.css.erb)
  #markdown = Redcarpet::Markdown.new(PygmentsHTML,
  markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML,
    :tables => true,
    :fenced_code_blocks => true,
    :autolink => true
  )

  config.render do |markdown_source|
    markdown.render markdown_source
  end
end
