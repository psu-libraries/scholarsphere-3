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

class FullTextDatastream < ActiveFedora::Datastream
  # we do not want multiple version of this stream so set versionable to false
  def initialize digital_object, dsid, options = {}
    super digital_object, dsid, options
    self.versionable = false
    self.content = "#" if self.content.blank? # set content to something until we extract the text
  end

    
end
