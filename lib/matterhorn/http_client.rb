require 'net/http/post/multipart'
require 'net/http/digest_auth'
require 'mime/types'


# =================================================================================== Matterhorn ===

module Matterhorn
  

  # ===================================================================== Matterhorn::HttpClient ===

  class HttpClient
    
    # --------------------------------------------------------------------------- initialization ---
  
    def initialize(protocol, domain, org_domain, user, password, auth_mode,
                   http_timeout = nil, ssl_dont_verify_cert = false, multi_tenand = true)
      @sub_domain   = org_domain.split('.').first
      @uri          = URI.parse("#{protocol}://#{domain}")
      @uri.user     = user
      @uri.password = password 
      @auth_mode    = auth_mode
      @ssl          = @uri.port == 443 ? true : false
      @timeout      = http_timeout
      @ssl_dont_verify_cert = ssl_dont_verify_cert
      @multi_tenand = multi_tenand
    end  
  

    # ---------------------------------------------------------------------------- http methodes ---
  
    def get(url)
      request = Net::HTTP::Get.new(assemble_url(url))
      execute_request(request)
    end
  
  
    def post(url, params = {}, file = nil, filename = nil, mime_type = nil)
      if params.has_key?('BODY') || !file.nil?
        request = multipart_post(url, params, file, filename, mime_type)
      else
        request = singlepart_post(url, params)
      end
      execute_request(request)
    end
  

    def put(url, params = {})
      request = Net::HTTP::Put.new(assemble_url(url))
      request.set_form_data(params)
      execute_request(request)
    end
  

    def delete(url)
      request = Net::HTTP::Delete.new(assemble_url(url))
      execute_request(request)
    end
  
  
    def close
      @http_socket.finish    if !@http_socket.nil? && @http_socket.started?
    end
  

    # -------------------------------------------------------------------------- private section ---
    private
  
    def http_socket
      return @http_socket   if !@http_socket.nil? && @http_socket.started?
      @http_socket = Net::HTTP.new(@uri.host, @uri.port)
      @http_socket.use_ssl = @ssl
      @http_socket.verify_mode = OpenSSL::SSL::VERIFY_NONE    if @ssl && @ssl_dont_verify_cert
      if !@timeout.nil?
        @http_socket.open_timeout = @timeout
        @http_socket.read_timeout = @timeout
      end
      @http_socket.start
    end
  
   
    def assemble_url(url)
      if @multi_tenand && !@sub_domain.blank?
        @uri.request_uri + "#{@sub_domain}/" + url
      else
        @uri.request_uri + url
      end
    end
  

    def singlepart_post(url, params)
      request = Net::HTTP::Post.new(assemble_url(url))
      request.set_form_data(params)
      request
    end
  
  
    def multipart_post(url, params, file, filename, mime_type)
      if file.kind_of?(String)
        file = File.new(file)
      elsif file.kind_of?(File)
        # noting to do
      elsif params['BODY'].kind_of?(String)
        file = File.new(params['BODY'])
        params['BODY'] = nil
      elsif params['BODY'].kind_of?(File)
        file = params['BODY']
        params['BODY'] = nil
      else
        raise(Matterhorn::Error, "Matterhorn::HttpClient::multipart_post | " +
                                 "Neither a BODY nor a file is present!")
      end
      if filename.nil?
        filename = File.basename(file.path)
      end
      if mime_type.nil?
        mime_type = MIME::Types.type_for(File.basename(file.path)).first
      end
      params['BODY'] = UploadIO.new(file, mime_type, filename)
      Net::HTTP::Post::Multipart.new(assemble_url(url), params)
    end
  
  
    def execute_request(request)
      case @auth_mode
      when 'basic'
        request.basic_auth(@uri.user, @uri.password)
      when 'digest'
        head = Net::HTTP::Head.new(@uri.request_uri + request.path)
        head['X-REQUESTED-AUTH'] = 'Digest'
        head['X-Opencast-Matterhorn-Authorization'] = 'true'
        digest_result = http_socket.request(head)
        digest_auth = Net::HTTP::DigestAuth.new
        auth = digest_auth.auth_header(@uri, digest_result['www-authenticate'], request.method)
        request.add_field('Authorization', auth)
      end
      response = http_socket.request(request)
      case response.code.to_i
      when 200..299
        handle_2xx_ok(request, response)
      when 400..499
        handle_4xx_error(request, response)
      when 500..599
        handle_5xx_error(request, response)
      else
        handle_general_error(request, response)
      end
      response
    end
  
  
    def handle_2xx_ok(request, response)
      msg = log_message('handle_2xx_ok', request, response)
      MatterhornWhymper.logger.debug { msg }
    end
  
    def handle_4xx_error(request, response)
      msg = log_message('handle_4xx_error', request, response)
      MatterhornWhymper.logger.debug { msg }
      raise(Matterhorn::HttpClientError.new(request, response), msg)
    end
  
    def handle_5xx_error(request, response)
      msg = log_message('handle_5xx_error', request, response)
      MatterhornWhymper.logger.debug { msg }
      raise(Matterhorn::HttpServerError.new(request, response), msg)
    end
  
    def handle_general_error(request, response)
      msg = log_message('handle_general_error', request, response)
      MatterhornWhymper.logger.debug { msg }
      raise(Matterhorn::HttpGeneralError.new(request, response), msg)
    end
  
  
    def log_message(method, request, response)
      "#{self.class.name}::#{method} | code = #{response.code}\n" +
      "  request  = #{request.method} #{request.path}\n" +
      "  response = #{response.code} #{response.msg}, body:\n#{response.body}\n"
    end
  
  
  end # ------------------------------------------------------------- end Matterhorn::HttpClient ---


end # --------------------------------------------------------------------------- end Matterhorn ---
