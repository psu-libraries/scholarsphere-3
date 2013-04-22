# -*- coding: utf-8 -*-
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

class GenericFilesController < ApplicationController
  include Sufia::FilesControllerBehavior

  def update_metadata
    if params[:generic_file].blank?
       @generic_file.save
       return
    end
    if params[:generic_file][:proxy_for]
      requesting_user = User.find_by_user_key params[:generic_file][:proxy_for]
      # TODO validate existence of requesting_user
      @generic_file.request_transfer_to(requesting_user)
    end
    super
  end
end
