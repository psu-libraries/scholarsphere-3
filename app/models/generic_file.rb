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
require 'datastreams/file_content_datastream'

class GenericFile < ActiveFedora::Base
  include Sufia::GenericFile

  has_file_datastream :name => "full_text", :type => FullTextDatastream

  def characterize
    self.characterization.ng_xml = self.content.extract_metadata
    self.append_metadata
    self.filename = self.label
    extract_content
    save unless self.new_object?
  end

  def per_version(&block)
    self.datastreams.each do |dsid, ds|
      return if ds == full_text
      ds.versions.each do |ver|
        block.call(ver)
      end
    end
  end


  def extract_content
    begin
      url = Blacklight.solr_config[:url] ? Blacklight.solr_config[:url] : Blacklight.solr_config["url"] ? Blacklight.solr_config["url"] : Blacklight.solr_config[:fulltext] ? Blacklight.solr_config[:fulltext]["url"] : Blacklight.solr_config[:default]["url"] 
      uri = URI(url+'/update/extract?&extractOnly=true&wt=ruby&extractFormat=text')
      req = Net::HTTP.new(uri.host, uri.port)
      resp = req.post(uri.to_s, self.content.content, {'Content-type'=>self.mime_type+';charset=utf-8', "Content-Length"=>"#{self.content.content.size}" })
      full_text.content = eval(resp.body)[""]
    rescue Exception => e
      logger.warn ("Resued exception while extracting content for #{self.pid}: #{e.inspect} ")
    end
  end

  def to_solr(solr_doc={}, opts={})
    super(solr_doc, opts)
    solr_doc["label_t"] = self.label
    solr_doc["noid_s"] = noid
    solr_doc["file_format_t"] = file_format
    solr_doc["file_format_facet"] = solr_doc["file_format_t"]
    solr_doc["text"] = full_text.content 
    logger.warn "Text =  #{solr_doc['text']}"
    return solr_doc
  end

end
