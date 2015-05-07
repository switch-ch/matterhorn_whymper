# ================================================================= Matterhorn::Endpoint::Series ===

class Matterhorn::Endpoint::Series < Matterhorn::Endpoint


  # -------------------------------------------------------------------------- endpoint methodes ---

  def count
    begin
      count = http_client.get(
        "series/count"
      ).body.to_i
    rescue Matterhorn::HttpClientError, Matterhorn::HttpServerError => ex
      if ex.code == 404
        count = nil
        MatterhornWhymper.logger.warn { "#{self.class.name}::count | " +
                                        "The count of series could not be get." }
      else
        MatterhornWhymper.logger.error { "#{self.class.name}::count | " +
                                         "An internal server error on Matterhorn occurres!" }

        raise ex
      end
    end
    count
  end

  
  def acl(series_id)
    begin
      acl_xml = http_client.get(
        "series/#{series_id}/acl.xml"
      ).body
      acl_model = Matterhorn::Acl.new(acl_xml)
    rescue Matterhorn::HttpClientError, Matterhorn::HttpServerError => ex
      if ex.code == 404
        acl_model = nil
        MatterhornWhymper.logger.warn { "#{self.class.name}::count | " +
                                        "The count of series could not be get." }
      else
        MatterhornWhymper.logger.error { "#{self.class.name}::count | " +
                                         "An internal server error on Matterhorn occurres!" }

        raise ex
      end
    end
    acl_model
  end

  
end # --------------------------------------------------------- end Matterhorn::Endpoint::Series ---