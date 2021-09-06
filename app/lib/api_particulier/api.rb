class APIParticulier::API
  include APIParticulier::Error

  INTROSPECT_RESOURCE_NAME = "introspect"

  TIMEOUT = 20

  def initialize(token)
    @token = token
  end

  def introspect
    response = get(INTROSPECT_RESOURCE_NAME)
    APIParticulier::Entities::Introspection.new(response)
  end

  private

  def get(resource_name, params = {})
    url = [API_PARTICULIER_URL, resource_name].join("/")

    response = Typhoeus.get(url,
      headers: { accept: "application/json", "X-API-Key": @token },
      params: params,
      timeout: TIMEOUT)

    if response.success?
      JSON.parse(response.body, symbolize_names: true)
    elsif response.timed_out?
      raise TimedOut.new(response)
    elsif response.code == 400
      raise BadFormatRequest.new(response)
    elsif response.code == 401
      raise Unauthorized.new(response)
    elsif response.code == 404
      raise NotFound.new(response)
    elsif response.code == 502
      raise	BadGateway.new(response)
    elsif response.code == 503
      raise ServiceUnavailable.new(response)
    else
      raise RequestFailed.new(response)
    end
  end
end