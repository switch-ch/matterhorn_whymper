# =============================================================== Matterhorn::Endpoint::Workflow ===

class Matterhorn::Endpoint::Workflow < Matterhorn::Endpoint


  # -------------------------------------------------------------------------- endpoint methodes ---

  def instance(wi_id)
    begin
      wi = http_client.get(
        "workflow/instance/#{wi_id}.xml"
      ).body
    rescue Matterhorn::HttpClientError, Matterhorn::HttpServerError => ex
      if ex.code == 404
        wi = nil
        MatterhornWhymper.logger.warn { "#{self.class.name}::instance | " +
                   "WorkflowInstance[#{wi_id}]: No workflow instance with that identifier exists." }
      else
        MatterhornWhymper.logger.error { "#{self.class.name}::instance | " +
                                "WorkflowInstance[#{wi_id}]: Internal server error on Matterhorn!" }

        raise ex
      end
    end
    wi ? Matterhorn::WorkflowInstance.new(wi) : nil
  end


  def remove(wi_id)
    begin
      http_client.delete(
        "workflow/remove/#{wi_id}"
      )
      wi_removed = true
    rescue Matterhorn::HttpClientError, Matterhorn::HttpServerError  => ex
      if ex.code == 404
        wi_removed = false
        MatterhornWhymper.logger.warn { "#{self.class.name}::remove | " +
                   "WorkflowInstance[#{wi_id}]: No workflow instance with that identifier exists." }
      else
        MatterhornWhymper.logger.error { "#{self.class.name}::remove | " +
                                "WorkflowInstance[#{wi_id}]: Internal server error on Matterhorn!" }

        raise ex
      end
    end
    wi_removed
  end


  def resume(wi_id)
    begin
      wi = http_client.post(
        "workflow/resume",
        { 'id' => wi_id }
      ).body
    rescue Matterhorn::HttpClientError, Matterhorn::HttpServerError  => ex
      if ex.code == 404
        wi = nil
        MatterhornWhymper.logger.warn { "#{self.class.name}::resume | " +
         "WorkflowInstance[#{wi_id}]: No suspended workflow instance with that identifier exists." }
      else
        MatterhornWhymper.logger.error { "#{self.class.name}::resume | " +
                                "WorkflowInstance[#{wi_id}]: Internal server error on Matterhorn!" }

        raise ex
      end
    end
    wi ? Matterhorn::WorkflowInstance.new(wi) : nil
  end


  def stop(wi_id)
    begin
      wi = http_client.post(
        "workflow/stop",
        { 'id' => wi_id }
      ).body
    rescue Matterhorn::HttpClientError, Matterhorn::HttpServerError  => ex
      if ex.code == 404
        wi = nil
        MatterhornWhymper.logger.warn { "#{self.class.name}::stop | " +
           "WorkflowInstance[#{wi_id}]: No running workflow instance with that identifier exists." }
      else
        MatterhornWhymper.logger.error { "#{self.class.name}::stop | " +
                                "WorkflowInstance[#{wi_id}]: Internal server error on Matterhorn!" }

        raise ex
      end
    end
    wi ? Matterhorn::WorkflowInstance.new(wi) : nil
  end

  
end # ------------------------------------------------------- end Matterhorn::Endpoint::Workflow ---