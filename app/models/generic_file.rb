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
  include Hydra::Collections::Collectible

  has_file_datastream :name => "full_text", :type => FullTextDatastream

  def characterize
    metadata = self.content.extract_metadata
    self.characterization.ng_xml = metadata unless metadata.blank?
    self.append_metadata
    self.filename = self.label
    extract_content
    save unless self.new_object?
  end

  def per_version(&block)
    self.datastreams.each do |dsid, ds|
      next if ds == full_text
      ds.versions.each do |ver|
        block.call(ver)
      end
    end
  end

  def create_pdf_thumbnail
     retryCnt = 0
     stat = false;
     for retryCnt in 1..3
       begin
         pdf = Magick::ImageList.new
         pdf.from_blob(content.content)
         first = pdf.to_a[0]
         first.format = "PNG"
         scale = 338.0/first.page.width
         scale = 0.40 if scale < 0.40
         thumb = first.scale scale
         thumb.crop!(0, 0, 338, 493)
         self.thumbnail.content = thumb.to_blob { self.format = "PNG" }
         #logger.debug "Has the content changed before saving? #{self.content.changed?}"
         stat = self.save
         break
       rescue => e
         logger.warn "Rescued an error #{e.inspect} retry count = #{retryCnt}"
         sleep 1
       end
     end
     return stat
   end


  def extract_content
    begin
      url = Blacklight.solr_config[:url] ? Blacklight.solr_config[:url] : Blacklight.solr_config["url"] ? Blacklight.solr_config["url"] : Blacklight.solr_config[:fulltext] ? Blacklight.solr_config[:fulltext]["url"] : Blacklight.solr_config[:default]["url"]
      uri = URI(url+'/update/extract?extractOnly=true&wt=ruby&extractFormat=text')
      req = Net::HTTP.new(uri.host, uri.port)
      resp = req.post(uri.to_s, self.content.content, {'Content-type'=>self.mime_type+';charset=utf-8', "Content-Length"=>"#{self.content.content.size}" })
      full_text.content = eval(resp.body)[""]
    rescue Exception => e
      logger.warn ("Resued exception while extracting content for #{self.pid}: #{e.inspect} ")
    end
  end

  # Unstemmed, searchable, stored
  def self.noid_indexer
    @noid_indexer ||= Solrizer::Descriptor.new(:text, :indexed, :stored)
  end

  def to_solr(solr_doc={}, opts={})
    super(solr_doc, opts)
    solr_doc[Solrizer.solr_name('label')] = self.label
    solr_doc[Solrizer.solr_name('noid', Sufia::GenericFile.noid_indexer)] = noid
    solr_doc[Solrizer.solr_name('file_format')] = file_format
    solr_doc[Solrizer.solr_name('file_format', :facetable)] = file_format
    solr_doc["all_text_timv"] = full_text.content
    index_collection_pids(solr_doc)
    return solr_doc
  end

  def file_format
    return nil if self.mime_type.blank? and self.format_label.blank?
    return self.mime_type.split('/')[1]+ " ("+self.format_label.join(", ")+")" unless self.mime_type.blank? or self.format_label.blank?
    return self.mime_type.split('/')[1] unless self.mime_type.blank?
    return self.format_label
  end

  def export_as_endnote
    end_note_format = {
      '%T' => [:title, lambda { |x| x.first }],
      '%Q' => [:title, lambda { |x| x.to_ary.slice(1, -1) }],
      '%A' => [:creator],
      '%C' => [:publication_place],
      '%D' => [:date_created],
      '%8' => [:date_uploaded],
      '%E' => [:contributor],
      '%I' => [:publisher],
      '%J' => [:series_title],
      '%@' => [:isbn],
      '%U' => [:related_url],
      '%7' => [:edition_statement],
      '%R' => [:persistent_url],
      '%X' => [:description],
      '%G' => [:language],
      '%[' => [:date_modified],
      '%9' => [:resource_type],
      '%~' => ScholarSphere::Application::config.application_name,
      '%W' => 'Penn State University'
    }
    text = []
    text << "%0 GenericFile"
    end_note_format.each do |endnote_key, mapping|
      if mapping.is_a? String
        values = [mapping]
      else
        values = self.send(mapping[0]) if self.respond_to? mapping[0]
        values = mapping[1].call(values) if mapping.length == 2
        values = [values] unless values.is_a? Array
      end
      next if values.empty? or values.first.nil?
      spaced_values = values.join("; ")
      text << "#{endnote_key} #{spaced_values}"
    end
    return text.join("\n")
  end
end
