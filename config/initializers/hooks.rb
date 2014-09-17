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

# TODO: try to auto-discover classes with hooks
RoxHook.hooks << TagsData
RoxHook.hooks << StatusData
RoxHook.hooks << GeneralData
RoxHook.hooks << LatestTestRunsData
RoxHook.hooks << LatestProjectsData
RoxHook.hooks << Settings::App
RoxHook.hooks << CurrentTestMetricsData

RoxHook.hooks << CacheReportJobForUi
RoxHook.hooks << CountDeprecationJob
RoxHook.hooks << CountTestsJob

RoxHook.hooks << PurgeAllJob
RoxHook.hooks << PurgeTagsJob
RoxHook.hooks << PurgeTestPayloadsJob
RoxHook.hooks << PurgeTestRunsJob
RoxHook.hooks << PurgeTicketsJob

RoxHook.setup!
