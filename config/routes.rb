ScholarSphere::Application.routes.draw do
  resource :landing_page, only: [:new, :create]
  get ':managedata' => 'landing_pages#new', as: :request_info, constraints: { managedata: /managedata/i }
  get ':managedata/:thankyou' => 'landing_pages#thanks', as: :request_thanks, constraints: { managedata: /managedata/i, thankyou: /thankyou/i }

  devise_for :users

  # Login/logout route to destroy session
  get 'logout' => 'sessions#destroy', as: :destroy_user_session
  get 'login' => 'sessions#new', as: :new_user_session

  # "Recently added files" route for catalog index view (needed before BL routes)
  get "catalog/recent" => "catalog#recent", as: :catalog_recent

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
      mount Resque::Server, at: 'queues'
    end
    # Usage stats
    constraints StatsAdmin do
      get 'stats' => 'stats#index', as: :stats
    end
  end

  # Generic file routes
  resources :generic_files, path: :files, except: :index do
    member do
      resources :transfers, as: :generic_file_transfers, only: [:new, :create]
      get 'citation', as: :citation
      post 'audit'
      post 'permissions'
    end
  end

  post '/users/:user_id/depositors' =>  'depositors#create', as:'user_depositors'
  delete '/users/:user_id/depositors/:id' =>  'depositors#destroy', as:'user_depositor'

  get '/why-use-scholarsphere', to: redirect('/scholarsphere_student_flyer.pdf')

  mount BrowseEverything::Engine => '/browse'
  mount Hydra::Collections::Engine => '/'
  mount Sufia::Engine => '/'
  mount HydraEditor::Engine => '/'

  root to: "homepage#index"

  # Downloads controller route
  # resources :downloads, only: "show"

  # Batch edit routes
  # get 'batches/:id/edit' => 'batch#edit', as: :batch_edit
  # put 'batches/:id/' => 'batch#update', as: :batch_generic_files

  # adding user route here to fix routing issue not found page=nil
  # get 'users' => 'users#index', as: :profiles

  # # Dashboard routes (based partly on catalog routes)
  # get 'dashboard' => 'dashboard#index', as: :dashboard
  # get 'dashboard/activity' => 'dashboard#activity', as: :dashboard_activity
  # get 'dashboard/facet/:id' => 'dashboard#facet', as: :dashboard_facet

  # Messages
  # get 'notifications' => 'mailbox#index', as: :mailbox
  # match 'notifications/delete_all' => 'mailbox#delete_all', as: :mailbox_delete_all
  # match 'notifications/:uid/delete' => 'mailbox#delete', as: :mailbox_delete

  # Authority vocabulary queries route
  # get 'authorities/:model/:term' => 'authorities#query'

  # Advanced search
  # get 'search' => 'advanced#index', as: :advanced

  # LDAP-related routes for group and user lookups
  # get 'directory/user/:uid' => 'directory#user'
  # get 'directory/user/:uid/:attribute' => 'directory#user_attribute'
  # get 'directory/group/:cn' => 'directory#group', constraints: { cn: /.*/ }

  # Contact form routes
  # post 'contact' => 'contact_form#create', as: :contact_form_index
  # get 'contact' => 'contact_form#new', as: :contact_form_index

  # Static page routes (workaround)
  # get ':action' => 'static#:action', constraints: { action: /about|help|terms|zotero|mendeley|agreement|subject_libraries|versions/ }, as: :static

  # # Catch-all (for routing errors)
  # unless Rails.env.development? || Rails.env.test?
  #   match '*error' => 'errors#routing', via: [:get, :post, :put]
  # end
end
