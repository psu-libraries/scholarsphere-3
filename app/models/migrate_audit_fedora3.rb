# frozen_string_literal: true
class MigrateAuditFedora3
  Fedora3Object = Struct.new("Fedora3Object", :pid, :has_model, :title)

  # The code in this class makes direct HTTP calls to Fedora 3 to
  # fetch data and does not depend on Rubydora or ActiveFedora.
  def initialize(fedora_url, fedora_user, fedora_password, namespace)
    @fedora_url = fedora_url
    @fedora_user = fedora_user
    @fedora_password = fedora_password
    @namespace = namespace
  end

  def audit
    raise "Must receive a block parameter" unless block_given?
    pids.each do |pid|
      f3_obj = get_info pid
      yield f3_obj
    end
  end

  # Gets the list of all PIDs in the Fedora 3 repository.
  # Fedora returns the list of PIDS in an XML that looks more or
  # less like this:
  #
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
  def pids
    batch_size = 50
    all_pids = []
    session_token = nil
    loop do
      session = session_token.nil? ? "" : "sessionToken=#{session_token}"
      query_string = "query=&resultFormat=xml&maxResults=#{batch_size}&pid=true&#{session}"
      fedora_response = fedora_get("/objects", query_string)
      xml = Nokogiri::XML(fedora_response)
      extract_pids(xml) do |pid|
        all_pids.push pid
      end
      session_token = extract_session_token(xml)
      break if session_token.nil?
    end
    all_pids
  end

  # Gets basic information (model and title) about a Fedora 3 object.
  # Fedora returns an XML that looks more ot less like this with the
  # information about a given object:
  #
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
  def get_info(pid)
    fedora_response = fedora_get("/objects/#{pid}/objectXML")
    xml = Nokogiri::XML(fedora_response)
    title = extract_title(xml)
    has_model = extract_model(xml)
    Fedora3Object.new(pid, has_model, title)
  end

  private

    def fedora_get(url_path, url_querystring = "")
      uri = URI.parse(@fedora_url + url_path + "?" + url_querystring)
      response = Net::HTTP.start(uri.hostname, uri.port) do |http|
        request = Net::HTTP::Get.new(uri.path + "?" + url_querystring)
        request.basic_auth(@fedora_user, @fedora_password)
        http.request(request)
      end
      response.body
    end

    def extract_pids(xml)
      docs = xml.xpath("//doc:pid", doc: "http://www.fedora.info/definitions/1/0/types/").children
      docs.each do |doc|
        yield doc.text if doc.to_s.start_with?(@namespace + ":")
      end
    end

    # Get the session token. This is what allows us to fetch the next batch
    # of PIDs in the next execution of the query.
    def extract_session_token(xml)
      header = xml.xpath("//header:token", header: "http://www.fedora.info/definitions/1/0/types/").children
      return header[0].text if header.length == 1
    end

    # Extract the title from the DC data stream
    def extract_title(xml)
      titles = xml.xpath("//dc:title", dc: "http://purl.org/dc/elements/1.1/").first
      return titles.children[0].text if titles && titles.children.count > 0
    end

    # Extract the "has_model" (GenericFile, Batch, Collection) from the RELS-EXT data stream
    def extract_model(xml)
      models = xml.xpath("//ns1:hasModel", ns1: "info:fedora/fedora-system:def/model#").first
      return models.attributes["resource"].value if models && models.attributes.key?("resource")
    end
end
