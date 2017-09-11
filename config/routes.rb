# frozen_string_literal: true

require 'resque/server'

ScholarSphere::Application.routes.draw do
  get '/landing_page/new', to: redirect('/contact')
  get '/managedata', to: redirect('/contact')

  # "Recently added files" route for catalog index view (needed before BL routes)
  get 'catalog/recent' => 'catalog#recent', as: :catalog_recent

  mount BrowseEverything::Engine => '/browse'
  mount Blacklight::Engine => '/'
  mount HydraEditor::Engine => '/'
  mount CurationConcerns::Engine, at: '/'
  mount Qa::Engine => '/authorities'

  curation_concerns_collections
  curation_concerns_basic_routes
  curation_concerns_embargo_management
  concern :exportable, Blacklight::Routes::Exportable.new
  concern :searchable, Blacklight::Routes::Searchable.new

  Hydra::BatchEdit.add_routes(self)

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
  end

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  devise_for :users

  # Login/logout route to destroy session
  get 'logout' => 'sessions#destroy', as: :destroy_user_session
  get 'login' => 'sessions#new', as: :new_user_session_old
  get 'login_session' => 'sessions#new', as: :new_user_session

  # LDAP-related routes for group and user lookups
  # TODO: Remove? See #316
  get 'directory/user/:uid' => 'directory#user'
  get 'directory/user/:uid/:attribute' => 'directory#user_attribute'
  get 'directory/group/:cn' => 'directory#group', constraints: { cn: /.*/ }

  # Administrative URLs
  namespace :admin do
    # Job monitoring
    constraints ResqueAdmin do
      mount Resque::Server, at: 'queues'
    end
  end

  get '/why-use-scholarsphere', to: redirect('/scholarsphere_student_flyer.pdf')

  if defined?(Sufia::StatsAdmin)
    namespace :admin do
      constraints Sufia::StatsAdmin do
        get 'stats/export' => 'stats#export', as: :stats_export
      end
    end
  end

  root 'sufia/homepage#index'

  get ':action' => 'static#:action', constraints: { action: /error_help/ }, as: :static

  get 'licenses', controller: 'static', action: 'licenses', as: 'licenses'

  get 'about' => 'static#about', id: 'about_page'

  # Routes for looking up Person records
  get '/creators/name_query', to: 'persons#name_query'

  # This must be the very last route in the file because it has a catch-all route for 404 errors.
  # This behavior seems to show up only in production mode.
  mount Sufia::Engine => '/'
end
