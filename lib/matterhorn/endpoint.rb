# ========================================================================= Matterhorn::Endpoint ===

class Matterhorn::Endpoint

  # --------------------------------------------------------------------------------- attributes ---

  attr_reader :response_code, :response_body


  # ----------------------------------------------------------------------------- initialization ---

  def self.create(endpoint, org_domain = '', mh_instance = :default)
    if endpoint.respond_to? 'to_s'
      endpoint = endpoint.to_s.capitalize
    else
      raise(Matterhorn::Error, "Matterhorn::Endpoint::open | " +
                               "#{endpoint.inspect} does not respond to 'to_s'")
    end
    endpoint = Object.const_get('Matterhorn').const_get('Endpoint').
                      const_get(endpoint).new(org_domain, mh_instance)
    if endpoint.nil? || !endpoint.kind_of?(Matterhorn::Endpoint)
      raise(Matterhorn::Error, "Matterhorn::Endpoint::open | " +
                               "#{endpoint ? endpoint.class.name : 'nil'} is not a sub class " +
                               "of 'Matterhorn::Endpoint'!")
    end
    endpoint
  end


  def self.open(endpoint, org_domain = '', mh_instance = :default)
    endpoint = create(endpoint, mh_instance)
    begin
      yield endpoint
    ensure
      endpoint.close
    end
  end  


  def initialize(org_domain = '', mh_instance = :default)
    @http_endpoint_client = Matterhorn::HttpClient.new(
      MatterhornWhymper.configuration.endpoint(mh_instance)[:protocol],
      MatterhornWhymper.configuration.endpoint(mh_instance)[:domain],
      org_domain,
      MatterhornWhymper.configuration.endpoint(mh_instance)[:user],
      MatterhornWhymper.configuration.endpoint(mh_instance)[:password],
      MatterhornWhymper.configuration.endpoint(mh_instance)[:auth_mode],
      MatterhornWhymper.configuration.endpoint(mh_instance)[:http_timeout],
      MatterhornWhymper.configuration.endpoint(mh_instance)[:ssl_dont_verify_cert],
      MatterhornWhymper.configuration.endpoint(mh_instance)[:multi_tenant] 
    )
    @http_api_client = if !MatterhornWhymper.configuration.api(mh_instance).nil?
      Matterhorn::HttpClient.new(
        MatterhornWhymper.configuration.api(mh_instance)[:protocol],
        MatterhornWhymper.configuration.api(mh_instance)[:domain],
        org_domain,
        MatterhornWhymper.configuration.api(mh_instance)[:user],
        MatterhornWhymper.configuration.api(mh_instance)[:password],
        MatterhornWhymper.configuration.api(mh_instance)[:auth_mode],
        MatterhornWhymper.configuration.api(mh_instance)[:http_timeout],
        MatterhornWhymper.configuration.api(mh_instance)[:ssl_dont_verify_cert],
        MatterhornWhymper.configuration.api(mh_instance)[:multi_tenant] 
      )
    else
      nil
    end
    @response_code = 200
    @response_body = nil
    @error_msg = ''
  end


  # ----------------------------------------------------------------------------------- methodes ---

  def error_occurred?
    response_code >= 400
  end


  def error_code
    error_occurred? ? response_code : nil
  end


  def error_msg
    error_occurred? ? @error_msg : ''
  end


  def close
    http_endpoint_client.close
    http_api_client.close
  end


  # ---------------------------------------------------------------------- *** protected section ***
  protected
  
  def http_endpoint_client
    @http_endpoint_client
  end


  def http_api_client
    @http_api_client
  end


  def split_response(response)
    @response_code = response.code.to_i
    @response_body = response.body
  end

  
  def build_query_str(options)
    query_str = ''
    options.each do |key, value|
      query_str << (query_str.empty? ? '?' : '&')
      query_str << "#{key.to_s}=#{value.to_s}"
    end
    URI.encode(query_str)
  end


  def exception_handler(method, exception, code_error_msg_hash)
    res_code = 0
    error_msg = ''
    case exception
    when Matterhorn::HttpClientError
      res_code = exception.code
      error_msg = if (msg = code_error_msg_hash[res_code]).nil?
        "An unspezified error (#{res_code}) has occurred!"
      else
        msg
      end
      log_warn_with_res_code_and_error_msg(method, res_code, error_msg)
    when Matterhorn::HttpServerError
      res_code = exception.code
      log_error_with_res_code(method, res_code)
      raise exception
    else
      log_fatal_with_backtrace(method, exception)
      raise exception
    end
    @response_code = res_code
    @error_msg     = error_msg
  end


  def log_warn_with_res_code_and_error_msg(method, code, error_msg)
    MatterhornWhymper.logger.warn { "#{self.class.name}##{method} | #{code}: #{error_msg}" }
  end 

 
  def log_error_with_res_code(method, code)
    MatterhornWhymper.logger.error { "#{self.class.name}##{method} | #{code}: " +
                                     "An internal server error has occurred on Matterhorn!" }
  end 


  def log_fatal_with_backtrace(method, ex)
    MatterhornWhymper.logger.fatal { Matterhorn::Error.format_message(
        "#{self.class.name}##{method} | A general error has occurred!", ex) }
  end 


end # ----------------------------------------------------------------- end Matterhorn::Endpoint ---
