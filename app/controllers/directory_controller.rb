# frozen_string_literal: true
# TODO: Is this controller even used anymore? See #316
class DirectoryController < ApplicationController
  # returns true if the user exists and false otherwise
  def user
    render json: User.directory_attributes(params[:uid])
  end

  def user_attribute
    res = if params[:attribute] == "groups"
            User.groups(params[:uid])
          else
            User.directory_attributes(params[:uid], params[:attribute])
          end
    render json: res
  end

  def user_groups
    render json: User.groups(params[:uid])
  end

  def group
    Group.exists?(params[:cn])
  end
end
