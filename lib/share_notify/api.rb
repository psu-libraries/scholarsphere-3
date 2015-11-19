# Interact with the SHARE Notify API
# @attr_reader [Hash] headers includes the authorization token needed to post data
# @attr_reader [HTTParty::Response] response from the service
class ShareNotify::API
  include HTTParty

  # Uncomment this line if you want the api calls to be written to STDOUT
  # debug_output $stdout

  attr_reader :headers, :response

  base_uri ShareNotify.config.fetch("host", "https://staging.osf.io")

  # @param [String] token is optional but some actions will not be successful without it
  def initialize(token=nil)
    @headers = { 
      "Authorization" => "Token #{ShareNotify.config.fetch("token", nil)}",
      "Content-Type"  => "application/json"
    }
  end

  # @return [HTTParty::Response]
  def get
    @response = self.class.get(api_data_point)
  end

  # @return [HTTParty::Response]
  def post(body)
    @response = self.class.post(api_data_point, body: body, headers: headers)
  end

  # @return [HTTParty::Response]
  def search(query)
    @response = self.class.get(api_search_point, query: { q: query })
  end

  private

    def api_data_point
      "/api/v1/share/data"
    end

    def api_search_point
      "/api/v1/share/search/"
    end

end
