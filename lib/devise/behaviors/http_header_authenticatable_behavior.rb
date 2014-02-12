# Copyright © 2013 The Pennsylvania State University
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

# Default strategy for signing in a user, based on his email and password in the database.
module Behaviors
  module HttpHeaderAuthenticatableBehavior

    # Called if the user doesn't already have a rails session cookie
    def valid_user?(headers)
      !remote_user(headers).blank?
    end

    protected

    def remote_user(headers)
      return headers['REMOTE_USER'] if headers['REMOTE_USER']
      return headers['HTTP_REMOTE_USER'] if headers['HTTP_REMOTE_USER'] && Rails.env.development?
      return nil
    end

  end
end

