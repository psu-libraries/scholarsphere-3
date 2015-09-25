class MyController < ApplicationController
  include Sufia::MyControllerBehavior
  skip_before_action :find_collections, only: :index
  before_action :find_collections_with_edit_access, only: :index
end
