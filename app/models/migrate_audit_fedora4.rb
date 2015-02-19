class MigrateAuditFedora4

  def initialize(fedora_url, fedora_user, fedora_password)
    @fedora_url = fedora_url
    @fedora_user = fedora_user
    @fedora_password = fedora_password
  end

  def audit(f3_objects)
    results = []
    f3_objects.each do |f3_obj|
      result = audit_one(f3_obj)
      results.push result
    end
    results
  end

  private

  def audit_one(f3_obj)
    f4_url = @fedora_url + "/" + pid_to_uri(f3_obj.f3_pid)
    f4_obj = fedora_get_metadata f4_url
    f4_model = model_from_resource f4_obj
    f3_model = normalized_f3_model(f3_obj.f3_model)
    result = {f3_pid: f3_obj.f3_pid, f4_id: f4_url, status: "OK"}
    if f4_obj == nil
      result[:status] = "Not found" 
    elsif f3_model != f4_model 
      result[:status] = "Models mismatch. Expected: #{f3_model} but found: #{f4_model}" 
    end
    result
  end

  def normalized_f3_model(f3_model)
    # f3 models are stored like this: "info:fedora/afmodel:Batch"
    # and we only care about the last part ("Batch" in this case)
    f3_model.split(':').last
  end

  def pid_to_uri(pid)
    id = pid.split(':').last
    raise "Cannot detect ID from PID #{pid}" unless id.length >= 9
    id[0..1] + "/" + id[2..3] + "/" + id[4..5] + "/" + id[6..7] + "/" + id
  end

  def model_from_resource(triples)
    return nil if triples.nil?
    object = parse_triples triples 
    object[:model]
  end

  # Response is an RDF graph in n-triple format and we expect it to have the 
  # model of the object (e.g. GenericFile, Batch) as well a list of its children.
  # 
  # The model comes in the form:
  #     <URI> <info:fedora/fedora-system:def/model#hasModel> "GenericFile"^^<http://www.w3.org/2001/XMLSchema#string> .
  #
  # Children come in the form:
  #     <URI> <http://www.w3.org/ns/ldp#contains> <CHILD-URI-1> .
  #     <URI> <http://www.w3.org/ns/ldp#contains> <CHILD-URI-2> .
  #
  def parse_triples response
    model = nil
    children = []
    start = Time.now    
    response.split("\n").each do |line|
      tokens = line.split(" ")
      predicate = tokens[1]
      object = tokens[2]
      if predicate == "<info:fedora/fedora-system:def/model#hasModel>"
        # get the model of the object
        has_model = tokens[2]
        caret = object.index("^^")
        if caret
          model = has_model[0,caret].gsub('"', '')
        end
      elsif predicate == "<http://www.w3.org/ns/ldp#contains>"
        # get the list of children of the object
        child_url = tokens[2].gsub("<", "").gsub(">", "")
        children.push child_url
      end
    end
    {model: model, children: children}
  end

  def fedora_get_metadata(url)
    headers = { "Accept" => "application/n-triples" }
    uri = URI.parse(url  + "/fcr:metadata")
    response = Net::HTTP.start(uri.hostname, uri.port) { |http|
      request = Net::HTTP::Get.new(uri.path, headers)
      request.basic_auth(@fedora_user, @fedora_password)
      http.request(request)
    }
    return nil if response.code == "404"
    response.body
  end
end
