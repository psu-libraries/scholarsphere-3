# Copyright © 2012 The Pennsylvania State University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'spec_helper'

describe 'Routes' do
  describe 'Catalog' do
    it 'should route the root url to the catalog controller' do
      { get: '/' }.should route_to(controller: 'catalog', action: 'index')
    end

    it 'should route to recently added files' do
      { get: '/catalog/recent' }.should route_to(controller: 'catalog', action: 'recent')
    end
  end

  describe 'GenericFile' do
    it 'should route to permissions' do
      { post: '/files/2/permissions' }.should route_to(controller: 'generic_files', action: 'permissions', id: '2')
    end
  end

  describe 'Sessions' do
    it "should route to logout" do
      { get: '/logout' }.should route_to(controller: 'sessions', action: 'destroy')
    end

    it "should route to login" do
      { get: '/login' }.should route_to(controller: 'sessions', action: 'new')
    end
  end

  describe 'Dashboard' do
    it "should route to transfers" do # NOT a sufia route
      { get: '/dashboard/transfers' }.should route_to(controller: 'transfers', action: 'index')
    end

    it "should route to create a transfer" do # NOT a sufia route
      { post: '/files/7/transfers' }.should route_to(controller: 'transfers', action: 'create', id: '7')
    end

    it "should route to new transfers" do # NOT a sufia route
      { get: '/files/7/transfers/new'}.should route_to(id: '7', controller: 'transfers', action: 'new')
    end

    it "should route to cancel transfers" do # NOT a sufia route
      { delete: '/dashboard/transfers/7' }.should route_to(controller: 'transfers', action: 'destroy', id: '7')
    end

    it "should route to accept transfers" do # NOT a sufia route
      { put: '/dashboard/transfers/7/accept' }.should route_to(controller: 'transfers', action: 'accept', id: '7')
    end

    it "should route to reject transfers" do # NOT a sufia route
      { put: '/dashboard/transfers/7/reject' }.should route_to(controller: 'transfers', action: 'reject', id: '7')
    end
  end
end
