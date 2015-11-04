require 'json'

# =============================================================== Matterhorn::Endpoint::Security ===

class Matterhorn::Endpoint::Security < Matterhorn::Endpoint


  # -------------------------------------------------------------------------- endpoint methodes ---

  # ------------------------------------------------------------------------------------- create ---

  # Create a signed url.
  # - url: the url which should be signed
  # - valid_until: The date and time until the signed url is valid
  # - valid_source: The IP address from which the request is allowed 
  #
  def sign(url, valid_until, valid_source)
    signed_url = nil
    begin
      split_response http_endpoint_client.post(
        "api/security/sign",
        { 'url' => url.to_s, 'validate-until' => valid_until.to_s, 'valid-source' => valid_source.to_s }
      )
      signed_url = JSON.parse(response_body)['url']
    rescue => ex
      exception_handler('create', ex, {
          401 => "The caller is not authorized to have the link signed!"
        }
      )
    end
    signed_url
  end


  # ---------------------------------------------------------------------------- private section ---
  private


end # ------------------------------------------------------- end Matterhorn::Endpoint::Security ---
