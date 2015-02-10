# Copyright (c) 2015 42 inside
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
require 'spec_helper'

describe "Creating a project and submitting new results", type: :feature, probe_dock: { category: 'Selenium' } do

  let(:user){ create :admin, encrypted_password: test_password }

  it "should work" do

    visit_test_server

    # log in
    expect(page).to have_content('Probe Dock')

    within 'form' do
      fill_in 'user_name', with: user.name
      fill_in 'user_password', with: 'test'
      click_link_or_button 'Submit'
    end

    # click on projects menu link on home page
    click_link 'Projects'

    # create a project
    click_button 'Add a project'

    expect do
      within '.projectEditor form' do
        fill_in 'projectName', with: 'A project'
        click_link_or_button 'Save'
      end

      expect(page).to have_content('Edit this project')
    end.to change(Project, :count).by(1)

    project = Project.first
    expect(project.name).to eq('A project')
    expect(project.url_token).to eq('a_project')

    # modify the project
    click_button 'Edit this project'

    within '.projectEditor form' do
      fill_in 'projectName', with: 'A project with a better name'
      click_link_or_button 'Save'
    end

    project.reload
    expect(project.name).to eq('A project with a better name')
    expect(project.url_token).to eq('a_projectwitha_better_nam')

    expect(page).to have_content('A project with a better name')

    # request 3 test keys
    click_link 'You'

    expect do
      within '.keyGenerator form' do
        fill_in 'n', with: '3'
        select project.name, from: 'project'
        click_link_or_button 'Generate'
      end

      expect(page).to have_selector('.keyGenerator .well span.label', count: 3)
    end.to change(TestKey, :count).by(3)

    payload = HashWithIndifferentAccess.new({
      d: 4321,
      r: [
        {
          j: project.api_id,
          v: '1.0.0',
          t: TestKey.all.to_a.collect.with_index{ |k,i| { k: k.key, n: "Test #{i + 1}", p: i % 2 == 0, d: rand(26) } }
        }
      ]
    })

    response = test_server_post(user, test_server_url(:api, :payloads), MultiJson.dump(payload), headers: { 'Content-Type' => media_type(:payload_v1) })
    expect(response.code).to eq(202)

    click_link 'Runs'
    #expect(page).to have_content('4321')

    expect(page).not_to have_content('dude, wait for the test to finish')
  end
end
