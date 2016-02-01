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
# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register_alias "text/html", :iphone
Mime::Type.register "text/x-markdown", :md
Mime::Type.register "text/xml", :text_xml
Mime::Type.register "text/json", :text_json
Mime::Type.register "multipart/form-data", :multipart_form_data

# Custom media types
Mime::Type.register "application/vnd.probedock.payload.v1+json", :probedock_payload_v1
Mime::Type.register "application/vnd.probe-dock.payload.v1+json", :probedock_payload_v1_old_naming
