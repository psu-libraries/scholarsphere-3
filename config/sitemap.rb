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

Sitemap::Generator.instance.load(host: 'scholarsphere.psu.edu') do
  path :root, priority: 1, change_frequency: 'daily'
  path :catalog_index, priority: 1, change_frequency: 'daily'
  User.all.each do |user|
    literal Sufia::Engine.routes.url_helpers.profile_path(user.login), priority: 0.8, change_frequency: 'daily'
  end
  read_group = Solrizer.solr_name('read_access_group', :symbol)
  GenericFile.where(read_group => 'public').each do |f|
    path :generic_file, params: { id: f.noid }, priority: 1, change_frequency: 'weekly'
  end
  Collection.where(read_group => 'public').each do |c|
    literal Hydra::Collections::Engine.routes.url_helpers.collection_path(c.noid), priority: 1, change_frequency: 'weekly'
  end
end
