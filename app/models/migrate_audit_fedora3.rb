class MigrateAuditFedora3

  def initialize(fedora_url, fedora_user, fedora_password, namespace)
    @fedora_url = fedora_url
    @fedora_user = fedora_user
    @fedora_password = fedora_password
    @namespace = namespace
  end

  def get_pids()
    batch_size = 50
    all_pids = []
    session_token = nil
    while true
      session = (session_token == nil) ? "" : "sessionToken=#{session_token}"
      query_string = "query=&resultFormat=xml&maxResults=#{batch_size}&pid=true&#{session}"
      # fedora_response will look more or less like this
      # <result>
      #   <listSession>
      #     <token>xxx</token>
      #     ...
      #   </listSession>
      #   <resultList>
      #     <objectFields>
      #       <pid>scholarsphere:123xyz</pid>
      #     <objectFields>
      #     more objectFields
      #   </resultList>
      # <result>
      fedora_response = fedora_get("/objects", query_string)
      xml = Nokogiri::XML(fedora_response)
      extract_pids(xml) do |pid| 
        all_pids.push pid 
      end
      session_token = extract_session_token(xml)
      break if session_token == nil
    end
    all_pids  
  end

  def get_info(pid)
    # fedora_response will look more or less like this
    # <foxml:digitalObject>
    #   ...
    #   <foxml:datastream ID="DC" ...>
    #     <foxml:datastreamVersion ...>
    #       <foxml:xmlContent>
    #         <oai_dc:dc xmlns:dc="http://purl.org/dc/elements/1.1/" ...>
    #           <dc:title>the_title_of_the_generic_file</dc:title>
    #         </oai_dc:dc>
    #       </foxml:xmlContent>
    #     </foxml:datastreamVersion>
    #   </foxml:datastream>
    #   ...
    #   <foxml:datastream ID="RELS-EXT" ...>
    #     <foxml:datastreamVersion ...>
    #       <foxml:xmlContent>
    #         <rdf:RDF xmlns:ns1="info:fedora/fedora-system:def/model#" ...>
    #           <rdf:Description rdf:about="info:fedora/scholarsphere:hh63sv96j">
    #             <ns1:hasModel rdf:resource="info:fedora/afmodel:GenericFile"/>
    #           </rdf:Description>
    #         </rdf:RDF>
    #       </foxml:xmlContent>
    #     </foxml:datastreamVersion>
    #   </foxml:datastream>
    #   ...
    fedora_response = fedora_get("/objects/#{pid}/objectXML")
    xml = Nokogiri::XML(fedora_response)
    title = extract_title(xml)
    has_model = extract_model(xml)
    {pid: pid, has_model: has_model, title: title}
  end  


  private

  def fedora_get(url_path, url_querystring = "")
    uri = URI.parse(@fedora_url + url_path + "?" + url_querystring)
    response = Net::HTTP.start(uri.hostname, uri.port) { |http|
      request = Net::HTTP::Get.new(uri.path + "?" + url_querystring)
      request.basic_auth(@fedora_user, @fedora_password)
      http.request(request)
    }    
    response.body
  end

  def extract_pids(xml)
    docs = xml.xpath("//doc:pid", "doc" => "http://www.fedora.info/definitions/1/0/types/").children
    docs.each do |doc|
      if doc.to_s.start_with?(@namespace + ":")
        yield doc.text
      end
    end
  end

  def extract_session_token(xml)
    # Get the session token. This is what allows us to fetch the next batch 
    # of PIDs in the next execution of the query.
    header = xml.xpath("//header:token", "header" => "http://www.fedora.info/definitions/1/0/types/").children
    if header.length == 1
      return header[0].text
    end
  end

  def extract_title(xml)
    # Extract the title from the DC data stream
    xml_set = xml.xpath("//dc:title", "dc" => "http://purl.org/dc/elements/1.1/")
    unless xml_set.empty?
      if xml_set.first.children.count > 0
        return xml_set.first.children[0].text
      end
    end    
  end

  def extract_model(xml)
    # Extract the "has_model" (GenericFile, Batch, Collection) from the RELS-EXT data stream
    xml_set = xml.xpath("//ns1:hasModel", "ns1" => "info:fedora/fedora-system:def/model#" )
    unless xml_set.empty?
      xml_node = xml_set.first
      if xml_node.attributes.key?("resource")
        return xml_node.attributes["resource"].value
      end
    end
  end

end
