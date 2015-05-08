require 'uri'


# ================================================================= Matterhorn::Endpoint::Series ===

class Matterhorn::Endpoint::Series < Matterhorn::Endpoint


  # -------------------------------------------------------------------------- endpoint methodes ---

  # ------------------------------------------------------------------------------------- create ---

  def create(dublin_core, acl = nil)
    created = false
    begin
      split_response http_client.post(
        "series",
        { 'series' => dublin_core.to_xml, 'acl' => acl.to_xml }
      )
      MatterhornWhymper.logger.debug {"#{self.class.name}#create | " +
                                      "Series content: #{response_body}" }
      created = true
    rescue => ex
      exception_handler('create', ex, {
          400 => "The required form params were missing to create the series!\n" +
                 "    dubline_core:\n#{dublin_core.inspect}\n    acl:\n#{acl.inspect}",
          401 => "It is required to authenticate first, before create a series!"
        }
      )
    end
    created
  end


  # --------------------------------------------------------------------------------------- read ---

  def read(series_id)
    dc_model = nil
    begin
      split_response http_client.get(
        "series/#{series_id}.xml"
      )
      dc_model = Matterhorn::DublinCore.new(response_body)
    rescue => ex
      exception_handler('read', ex, {
          401 => "It is required to authenticate first, " +
                 "before get the content of series #{series_id}.",
          403 => "It is forbidden to get the content of series #{series_id}.",
          404 => "The content of series #{series_id} could not be get."
        }
      )
    end
    dc_model
  end

  
  def filter(options)
    dc_models = []
    begin
      split_response http_client.get(
        "series/series.xml#{build_query_str(options)}"
      )
      # TODO: dc_models = res.body.each ...
    rescue => ex
      exception_handler('filter', ex, {
          401 => "It is required to authenticate first, " +
                 "before get the content of series #{series_id}."
        }
      )
    end
    dc_models
  end


  def count
    count = 0
    begin
      split_response http_client.get(
        "series/count"
      )
      count = response_body.to_i
    rescue => ex
      exception_handler('count', ex, {})
    end
    count
  end

  
  def acl(series_id)
    acl_model = nil
    begin
      split_response http_client.get(
        "series/#{series_id}/acl.xml"
      )
      acl_model = Matterhorn::Acl.new(response_body)
    rescue => ex
      exception_handler('acl', ex, {
          404 => "The acl of series #{series_id} could not be found."
        }
      )
    end
    acl_model
  end

  
  # ------------------------------------------------------------------------------------- update ---


  # ------------------------------------------------------------------------------------- delete ---

  def delete(series_id)
    deleted = false
    begin
      split_response http_client.delete(
        "series/#{series_id}"
      )
      deleted = true
    rescue => ex
      exception_handler('delete', ex, {
          401 => "It is required to authenticate first, " +
                 "before get the content of series #{series_id}.",
          404 => "The series #{series_id} could not be found."
        }
      )
    end
    deleted
  end   


  # ---------------------------------------------------------------------------- private section ---
  private

  def build_query_str(options)
    query_str = ''
    options.each do |key, value|
      query_str << query_str.empty? ? '?' : '&'
      query_str << "#{key.to_s}=#{value.to_s}"
    end
    URI.encode(query_str)
  end


end # --------------------------------------------------------- end Matterhorn::Endpoint::Series --
