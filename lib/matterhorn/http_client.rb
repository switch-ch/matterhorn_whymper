require 'net/http/post/multipart'
require 'net/http/digest_auth'

class Matterhorn::HttpClient
  
  # --- attributes -------------------------------------------------------------

  attr_reader :base_uri, :host, :port, :ssl

  # --- initialization ---------------------------------------------------------

  def initialize(base_uri)
    @base_uri = URI.parse(base_uri)
    @host     = @base_uri.host
    @port     = @base_uri.port
    @ssl      = @port == 443 ? true : false
  end  

  def close
    @http_socket.finish    if !@http_socket.nil? && @http_socket.started?
  end

  # --- http methodes ----------------------------------------------------------

  def post(url, params = {}, file = nil, filename = nil, mime_type = nil)
    if params.has_key?('BODY') || !file.nil?
      request = multipart_post(url, params, file, filename, mime_type)
    else
      request = singlepart_post(url, params)
    end
    execute_request(request)
  end


  def get(url)
    request = Net::HTTP::Get.new(base_uri.request_uri + url)
    execute_request(request)
  end


  def delete(url)
    request = Net::HTTP::Delete.new(base_uri.request_uri + url)
    execute_request(request)
  end


  # ========================================================================== #
  # === private section                                                    === #
  # ========================================================================== #
  private

  def http_socket
    return @http_socket   if !@http_socket.nil? && @http_socket.started?
    @http_socket = Net::HTTP.new(host, port)
    @http_socket.use_ssl = ssl
    @http_socket.start
  end


  def singlepart_post(url, params)
    request = Net::HTTP::Post.new(base_uri.request_uri + url)
    request.set_form_data(params)
    Matterhorn::EndpointApi.logger.debug { "Matterhorn::Client::singlepart_post: request = #{request.to_yaml}"}
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
      raise(Matterhorn::Error, "Matterhorn::Client::multipart_post: Neither BODY nor file exists!")
    end
    Matterhorn::EndpointApi.logger.debug { "Matterhorn::Client::multipart_post: file = #{file.inspect}"}
    if filename.nil?
      filename = File.basename(file.path)
    end
    if mime_type.nil?
      mime_type = MIME::Types.type_for(File.basename(file.path)).first
    end
    params['BODY'] = UploadIO.new(file, mime_type, filename)
    Matterhorn::EndpointApi.logger.debug { "Matterhorn::Client::multipart_post: params = #{params.to_yaml}"}
    Net::HTTP::Post::Multipart.new(base_uri.request_uri + url, params)
  end


  def execute_request(request)
    head = Net::HTTP::Head.new(request.path)
    head['X-REQUESTED-AUTH'] = 'Digest'
    head['X-Opencast-Matterhorn-Authorization'] = 'true'
    digest_result = http_socket.request(head)
    digest_auth = Net::HTTP::DigestAuth.new
    auth = digest_auth.auth_header(base_uri, digest_result['www-authenticate'], request.method)
    request.add_field('Authorization', auth)
    response = http_socket.request(request)
    case response.code.to_i
    when 200..299
      handle_2xx_ok(request, response)
    when 400..499
      handle_4xx_error(request, response)
    when 500..599
      handle_5xx_error(request, response)
    else
      handle_unknown_error(request, response)
    end
    response
  end


  def handle_2xx_ok(request, response)
    Matterhorn::EndpointApi.logger.info { "Matterhorn::Client::execute_request:\n" + log_message(request, response) }
  end

  def handle_4xx_error(request, response)
    Matterhorn::EndpointApi.logger.error { "Matterhorn::Client::execute_request: Client Error:\n" + log_message(request, response) }
    raise(Matterhorn::HttpClientError, log_message(request, response))
  end

  def handle_5xx_error(request, response)
    Matterhorn::EndpointApi.logger.error { "Matterhorn::Client::execute_request: Server Error:\n" + log_message(request, response) }
    raise(Matterhorn::HttpServerError, log_message(request, response))
  end

  def handle_unknown_error(request, response)
    Matterhorn::EndpointApi.logger.error { "Matterhorn::Client::execute_request: Server Error:\n" + log_message(request, response) }
    raise(Matterhorn::Error, log_message(request, response))
  end


  def log_message(request, response)
    "  request = #{log_request(request)}\n" +
    "  response = #{log_response(response)}"
  end

  def log_request(request)
    "#{request.method} #{request.path}"
  end

  def log_response(response)
    "#{response.code} #{response.msg}, body:\n#{response.body}\n"
  end

end