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
  def sign(url, valid_until = nil, valid_source = nil)
    signed_url = nil
    begin
      params = {}
      params['url'] = url.to_s
      if !valid_until.nil? && (valid_until.kind_of?(DateTime) || valid_until.kind_of?(Time))
        params['valid_until'] = valid_until.xmlschema
      elsif !valid_until.nil? && valid_until.respond_to?(:to_s)
        params['valid_until'] = valid_until.to_s
      end
      if !valid_source.nil? && valid_source.respond_to?(:to_s)
        params['valid_source'] = ivalid_source.to_s
      end
      split_response http_endpoint_client.post(
        "api/security/sign",
        params
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
