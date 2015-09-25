ScholarSphere::Application.routes.draw do
  resource :landing_page, only: [:new, :create]
  get ':managedata' => 'landing_pages#new', as: :request_info, constraints: { managedata: /managedata/i }
  get ':managedata/:thankyou' => 'landing_pages#thanks', as: :request_thanks, constraints: { managedata: /managedata/i, thankyou: /thankyou/i }

  devise_for :users

  # Login/logout route to destroy session
  get 'logout' => 'sessions#destroy', as: :destroy_user_session
  get 'login' => 'sessions#new', as: :new_user_session_old
  get 'login_session' => 'sessions#new', as: :new_user_session

  # "Recently added files" route for catalog index view (needed before BL routes)
  get "catalog/recent" => "catalog#recent", as: :catalog_recent

  Blacklight.add_routes(self)
  Hydra::BatchEdit.add_routes(self)

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

  mount BrowseEverything::Engine => '/browse'
  mount Hydra::Collections::Engine => '/'
  mount Sufia::Engine => '/'
  mount HydraEditor::Engine => '/'

  root to: "homepage#index"

  get ':action' => 'static#:action', constraints: { action: /error_help/ }, as: :static
end
