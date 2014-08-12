# -*- coding: utf-8 -*-
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

# -*- encoding : utf-8 -*-
require 'blacklight/catalog'
require 'blacklight_advanced_search'

# bl_advanced_search 1.2.4 is doing unitialized constant on these because we're calling ParseBasicQ directly
require 'parslet'
require 'parsing_nesting/tree'

class CatalogController < ApplicationController
  include Blacklight::Catalog
  # Extend Blacklight::Catalog with Hydra behaviors (primarily editing).
  include Hydra::Controller::ControllerBehavior
  include BlacklightAdvancedSearch::ParseBasicQ
  include Sufia::Catalog


  # These before_filters apply the hydra access controls
  before_filter :enforce_show_permissions, only: :show
  # This applies appropriate access controls to all solr queries
  CatalogController.solr_search_params_logic += [:add_access_controls_to_solr_params]

  skip_before_filter :default_html_head

  def self.uploaded_field
    Solrizer.solr_name('desc_metadata__date_uploaded', :stored_sortable, type: :date)
  end

  def self.modified_field
    Solrizer.solr_name('desc_metadata__date_modified', :stored_sortable, type: :date)
  end

  # COPIED AND MODIFIED from:
  #	/usr/local/rvm/gems/ree-1.8.7-2011.03@scholarsphere/gems/blacklight-3.3.2/lib/blacklight/catalog.rb
  #
  # when solr (RSolr) throws an error (RSolr::RequestError), this method is executed.
  def rsolr_request_error(exception)
    if ['development', 'test'].include?(Rails.env)
      raise exception # Rails own code will catch and give usual Rails error page with stack trace
    else
      flash_notice = "Sorry, I don't understand your search."
      # Set the notice flag if the flash[:notice] is already set to the error that we are setting.
      # This is intended to stop the redirect loop error
      notice = flash[:notice] if flash[:notice] == flash_notice
      unless notice
        flash[:notice] = flash_notice
        redirect_to root_path, status: 500
      else
        render template: "public/500.html", layout: false, status: 500
      end
    end
  end

  configure_blacklight do |config|
    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params = {
      qt: "search",
      rows: 10
    }

    # specify which field to use in the tag cloud on the homepage
    config.tag_cloud_field_name = Solrizer.solr_name('desc_metadata__tag', :facetable)

    # solr field configuration for search results/index views
    config.index.title_field = solr_name("desc_metadata__title", :stored_searchable)
    config.index.display_type_field = solr_name("has_model", :symbol)
    config.index.thumbnail_method = :sufia_thumbnail_tag

    # solr field configuration for document/show views
    config.show.title_field = Solrizer.solr_name("desc_metadata__title", :displayable)
    config.show.display_type_field = Solrizer.solr_name("has_model", :symbol)

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    config.add_facet_field Solrizer.solr_name("desc_metadata__resource_type", :facetable), label: "Resource Type", limit: 5
    config.add_facet_field Solrizer.solr_name("collection", :facetable), label: "Collection",  helper_method: :collection_helper_method,  limit: 5
    config.add_facet_field Solrizer.solr_name("desc_metadata__creator", :facetable), label: "Creator", limit: 5
    config.add_facet_field Solrizer.solr_name("desc_metadata__tag", :facetable), label: "Keyword", limit: 5
    config.add_facet_field Solrizer.solr_name("desc_metadata__subject", :facetable), label: "Subject", limit: 5
    config.add_facet_field Solrizer.solr_name("desc_metadata__language", :facetable), label: "Language", limit: 5
    config.add_facet_field Solrizer.solr_name("desc_metadata__based_near", :facetable), label: "Location", limit: 5
    config.add_facet_field Solrizer.solr_name("desc_metadata__publisher", :facetable), label: "Publisher", limit: 5
    config.add_facet_field Solrizer.solr_name("file_format", :facetable), label: "File Format", limit: 5
    config.add_facet_field Solrizer.solr_name("active_fedora_model", :stored_sortable), label: "Object Type", helper_method: :titleize

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field Solrizer.solr_name("desc_metadata__title", :stored_searchable, type: :string), label: "Title"
    config.add_index_field Solrizer.solr_name("desc_metadata__description", :stored_searchable, type: :string), label: "Description"
    config.add_index_field Solrizer.solr_name("desc_metadata__tag", :stored_searchable, type: :string), label: "Keyword"
    config.add_index_field Solrizer.solr_name("desc_metadata__subject", :stored_searchable, type: :string), label: "Subject"
    config.add_index_field Solrizer.solr_name("desc_metadata__creator", :stored_searchable, type: :string), label: "Creator"
    config.add_index_field Solrizer.solr_name("desc_metadata__contributor", :stored_searchable, type: :string), label: "Contributor"
    config.add_index_field Solrizer.solr_name("desc_metadata__publisher", :stored_searchable, type: :string), label: "Publisher"
    config.add_index_field Solrizer.solr_name("desc_metadata__based_near", :stored_searchable, type: :string), label: "Location"
    config.add_index_field Solrizer.solr_name("desc_metadata__language", :stored_searchable, type: :string), label: "Language"
    config.add_index_field Solrizer.solr_name("desc_metadata__date_uploaded", :stored_searchable, type: :string), label: "Date Uploaded"
    config.add_index_field Solrizer.solr_name("desc_metadata__date_modified", :stored_searchable, type: :string), label: "Date Modified"
    config.add_index_field Solrizer.solr_name("desc_metadata__date_created", :stored_searchable, type: :string), label: "Date Created"
    config.add_index_field Solrizer.solr_name("desc_metadata__rights", :stored_searchable, type: :string), label: "Rights"
    config.add_index_field Solrizer.solr_name("desc_metadata__resource_type", :stored_searchable, type: :string), label: "Resource Type"
    config.add_index_field Solrizer.solr_name("file_format", :stored_searchable, type: :string), label: "File Format"
    config.add_index_field Solrizer.solr_name("desc_metadata__identifier", :stored_searchable, type: :string), label: "Identifier"

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    config.add_show_field Solrizer.solr_name("desc_metadata__title", :stored_searchable, type: :string), label: "Title"
    config.add_show_field Solrizer.solr_name("desc_metadata__description", :stored_searchable, type: :string), label: "Description"
    config.add_show_field Solrizer.solr_name("desc_metadata__tag", :stored_searchable, type: :string), label: "Keyword"
    config.add_show_field Solrizer.solr_name("desc_metadata__subject", :stored_searchable, type: :string), label: "Subject"
    config.add_show_field Solrizer.solr_name("desc_metadata__creator", :stored_searchable, type: :string), label: "Creator"
    config.add_show_field Solrizer.solr_name("desc_metadata__contributor", :stored_searchable, type: :string), label: "Contributor"
    config.add_show_field Solrizer.solr_name("desc_metadata__publisher", :stored_searchable, type: :string), label: "Publisher"
    config.add_show_field Solrizer.solr_name("desc_metadata__based_near", :stored_searchable, type: :string), label: "Location"
    config.add_show_field Solrizer.solr_name("desc_metadata__language", :stored_searchable, type: :string), label: "Language"
    config.add_show_field Solrizer.solr_name("desc_metadata__date_uploaded", :stored_searchable, type: :string), label: "Date Uploaded"
    config.add_show_field Solrizer.solr_name("desc_metadata__date_modified", :stored_searchable, type: :string), label: "Date Modified"
    config.add_show_field Solrizer.solr_name("desc_metadata__date_created", :stored_searchable, type: :string), label: "Date Created"
    config.add_show_field Solrizer.solr_name("desc_metadata__rights", :stored_searchable, type: :string), label: "Rights"
    config.add_show_field Solrizer.solr_name("desc_metadata__resource_type", :stored_searchable, type: :string), label: "Resource Type"
    config.add_show_field Solrizer.solr_name("file_format", :stored_searchable, type: :string), label: "File Format"
    config.add_show_field Solrizer.solr_name("desc_metadata__identifier", :stored_searchable, type: :string), label: "Identifier"
    config.add_show_field Solrizer.solr_name("depositor", :stored_searchable), label: "Depositor"

    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different.
    #
    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.
    config.add_search_field('all_fields', label: 'All Fields', include_in_advanced_search: false) do |field|
      all_names = config.show_fields.values.map{|val| val.field}.join(" ")
      title_name = Solrizer.solr_name("desc_metadata__title", :stored_searchable, type: :string)
      field.solr_parameters = {
        qf: "#{all_names} id noid_tsi all_text_timv",
        pf: "#{title_name}"
      }
    end

    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields.
    # creator, title, description, publisher, date_created,
    # subject, language, resource_type, format, identifier, based_near,
    config.add_search_field('contributor') do |field|
      # solr_parameters hash are sent to Solr as ordinary url query params.
      field.solr_parameters = { :"spellcheck.dictionary" => "contributor" }

      # :solr_local_parameters will be sent using Solr LocalParams
      # syntax, as eg {! qf=$title_qf }. This is neccesary to use
      # Solr parameter de-referencing like $title_qf.
      # See: http://wiki.apache.org/solr/LocalParams
      solr_name = Solrizer.solr_name("desc_metadata__contributor", :stored_searchable, type: :string)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('creator') do |field|
      field.solr_parameters = { :"spellcheck.dictionary" => "creator" }
      solr_name = Solrizer.solr_name("desc_metadata__creator", :stored_searchable, type: :string)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('title') do |field|
      field.solr_parameters = {
        :"spellcheck.dictionary" => "title"
      }
      solr_name = Solrizer.solr_name("desc_metadata__title", :stored_searchable, type: :string)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('description') do |field|
      field.label = "Abstract or Summary"
      field.solr_parameters = {
        :"spellcheck.dictionary" => "description"
      }
      solr_name = Solrizer.solr_name("desc_metadata__description", :stored_searchable, type: :string)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('publisher') do |field|
      field.solr_parameters = {
        :"spellcheck.dictionary" => "publisher"
      }
      solr_name = Solrizer.solr_name("desc_metadata__publisher", :stored_searchable, type: :string)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('date_created') do |field|
      field.solr_parameters = {
        :"spellcheck.dictionary" => "date_created"
      }
      solr_name = Solrizer.solr_name("desc_metadata__created", :stored_searchable, type: :string)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('subject') do |field|
      field.solr_parameters = {
        :"spellcheck.dictionary" => "subject"
      }
      solr_name = Solrizer.solr_name("desc_metadata__subject", :stored_searchable, type: :string)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('language') do |field|
      field.solr_parameters = {
        :"spellcheck.dictionary" => "language"
      }
      solr_name = Solrizer.solr_name("desc_metadata__language", :stored_searchable, type: :string)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('resource_type') do |field|
      field.solr_parameters = {
        :"spellcheck.dictionary" => "resource_type"
      }
      solr_name = Solrizer.solr_name("desc_metadata__resource_type", :stored_searchable, type: :string)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('format') do |field|
      field.include_in_advanced_search = false
      field.solr_parameters = {
        :"spellcheck.dictionary" => "format"
      }
      solr_name = Solrizer.solr_name("desc_metadata__format", :stored_searchable, type: :string)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('identifier') do |field|
      field.include_in_advanced_search = false
      field.solr_parameters = {
        :"spellcheck.dictionary" => "identifier"
      }
      solr_name = Solrizer.solr_name("desc_metadata__id", :stored_searchable, type: :string)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('based_near') do |field|
      field.label = "Location"
      field.solr_parameters = {
        :"spellcheck.dictionary" => "based_near"
      }
      solr_name = Solrizer.solr_name("desc_metadata__based_near", :stored_searchable, type: :string)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('tag') do |field|
      field.solr_parameters = {
        :"spellcheck.dictionary" => "tag"
      }
      solr_name = Solrizer.solr_name("desc_metadata__tag", :stored_searchable, type: :string)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('depositor') do |field|
      solr_name = Solrizer.solr_name("depositor", :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('rights') do |field|
      solr_name = Solrizer.solr_name("desc_metadata__rights", :stored_searchable, type: :string)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    # label is key, solr field is value
    config.add_sort_field "score desc, #{uploaded_field} desc", label: "relevance \u25BC"
    config.add_sort_field "#{uploaded_field} desc", label: "date uploaded \u25BC"
    config.add_sort_field "#{uploaded_field} asc", label: "date uploaded \u25B2"
    config.add_sort_field "#{modified_field} desc", label: "date modified \u25BC"
    config.add_sort_field "#{modified_field} asc", label: "date modified \u25B2"

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5

    config.http_method = :post
  end

  protected

  def depositor_field
    Solrizer.solr_name('depositor', :stored_searchable)
  end

  def read_group_field
    Solrizer.solr_name('read_access_group', :symbol)
  end

  def sort_field
    "#{Solrizer.solr_name('system_create', :stored_sortable, type: :date)} desc"
  end
end
