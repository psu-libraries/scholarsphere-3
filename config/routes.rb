ScholarSphere::Application.routes.draw do
  root :to => "catalog#index"

  devise_for :users

  # Login/logout route to destroy session
  match 'logout' => 'sessions#destroy', :as => :destroy_user_session
  match 'login' => 'sessions#new', :as => :new_user_session

  # "Recently added files" route for catalog index view (needed before BL routes)
  match "catalog/recent" => "catalog#recent", :as => :catalog_recent

  Blacklight.add_routes(self)
  Hydra::BatchEdit.add_routes(self)

  ## This route is not in sufia, must come before sufia is mounted or sufia's error route catches it.
  resource :dashboard, only: [] do
    collection do
      resources :transfers, only: [:index, :destroy] do
        member do
          put 'accept'
          put 'reject'
        end
      end
    end
  end

  # Administrative URLs
  namespace :admin do
    # Job monitoring
    constraints ResqueAdmin do
      mount Resque::Server, :at => 'queues'
    end
    # Usage stats
    constraints StatsAdmin do
      match 'stats' => 'stats#index', :as => :stats
    end
  end

  # Generic file routes
  resources :generic_files, :path => :files, :except => :index do
    member do
      resources :transfers, :as => :generic_file_transfers, only: [:new, :create]
      get 'citation', :as => :citation
      post 'audit'
      post 'permissions'
    end
  end

  mount Hydra::Collections::Engine => '/'
  mount Sufia::Engine => '/'

  # Downloads controller route
  resources :downloads, :only => "show"

  # Batch edit routes
  match 'batches/:id/edit' => 'batch#edit', :as => :batch_edit
  match 'batches/:id/' => 'batch#update', :as => :batch_generic_files

  # adding user route here to fix routing issue not found page=nil
  match 'users' => 'users#index', :as => :profiles


  # Dashboard routes (based partly on catalog routes)
  match 'dashboard' => 'dashboard#index', :as => :dashboard
  match 'dashboard/activity' => 'dashboard#activity', :as => :dashboard_activity
  match 'dashboard/facet/:id' => 'dashboard#facet', :as => :dashboard_facet

  # Messages
  match 'notifications' => 'mailbox#index', :as => :mailbox
  match 'notifications/delete_all' => 'mailbox#delete_all', :as => :mailbox_delete_all
  match 'notifications/:uid/delete' => 'mailbox#delete', :as => :mailbox_delete

  # Authority vocabulary queries route
  match 'authorities/:model/:term' => 'authorities#query'

  # Advanced search
  match 'search' => 'advanced#index', :as => :advanced

  # LDAP-related routes for group and user lookups
  match 'directory/user/:uid' => 'directory#user'
  match 'directory/user/:uid/:attribute' => 'directory#user_attribute'
  match 'directory/group/:cn' => 'directory#group', :constraints => { :cn => /.*/ }

  # Contact form routes
  match 'contact' => 'contact_form#create', :via => :post, :as => :contact_form_index
  match 'contact' => 'contact_form#new', :via => :get, :as => :contact_form_index

  # Static page routes (workaround)
  match ':action' => 'static#:action', :constraints => { :action => /about|help|terms|zotero|mendeley|agreement|subject_libraries|versions/ }, :as => :static

  # Catch-all (for routing errors)
  unless Rails.env.development? || Rails.env.test?
    match '*error' => 'errors#routing'
  end
end
