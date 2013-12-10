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
  describe 'Blacklight' do
    it "should route Blacklight routes"
    # TODO: finish adding route specs for BL
    #           clear_bookmarks        /bookmarks/clear(.:format)                bookmarks#clear
    #                 bookmarks GET    /bookmarks(.:format)                      bookmarks#index
    #                           POST   /bookmarks(.:format)                      bookmarks#create
    #              new_bookmark GET    /bookmarks/new(.:format)                  bookmarks#new
    #             edit_bookmark GET    /bookmarks/:id/edit(.:format)             bookmarks#edit
    #                  bookmark GET    /bookmarks/:id(.:format)                  bookmarks#show
    #                           PUT    /bookmarks/:id(.:format)                  bookmarks#update
    #                           DELETE /bookmarks/:id(.:format)                  bookmarks#destroy
    #              clear_folder        /folder/clear(.:format)                   folder#clear
    #            folder_destroy        /folder/destroy(.:format)                 folder#destroy
    #              folder_index GET    /folder(.:format)                         folder#index
    #                    folder PUT    /folder/:id(.:format)                     folder#update
    #                           DELETE /folder/:id(.:format)                     folder#destroy
    #            search_history        /search_history(.:format)                 search_history#index
    #      clear_search_history        /search_history/clear(.:format)           search_history#clear
    #      clear_saved_searches        /saved_searches/clear(.:format)           saved_searches#clear
    #            saved_searches        /saved_searches(.:format)                 saved_searches#index
    #               save_search        /saved_searches/save/:id(.:format)        saved_searches#save
    #             forget_search        /saved_searches/forget/:id(.:format)      saved_searches#forget
    #        opensearch_catalog        /catalog/opensearch(.:format)             catalog#opensearch
    #          citation_catalog        /catalog/citation(.:format)               catalog#citation
    #             email_catalog        /catalog/email(.:format)                  catalog#email
    #               sms_catalog        /catalog/sms(.:format)                    catalog#sms
    #           endnote_catalog        /catalog/endnote(.:format)                catalog#endnote
    # send_email_record_catalog        /catalog/send_email_record(.:format)      catalog#send_email_record
    #             catalog_facet        /catalog/facet/:id(.:format)              catalog#facet
    #             catalog_index        /catalog(.:format)                        catalog#index
    #    librarian_view_catalog        /catalog/:id/librarian_view(.:format)     catalog#librarian_view
    #             solr_document GET    /catalog/:id(.:format)                    catalog#show
    #                           PUT    /catalog/:id(.:format)                    catalog#update
    #                   catalog GET    /catalog/:id(.:format)                    catalog#show
    #                           PUT    /catalog/:id(.:format)                    catalog#update
    #                  feedback        /feedback(.:format)                       feedback#show
    #         feedback_complete        /feedback/complete(.:format)              feedback#complete
  end

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
