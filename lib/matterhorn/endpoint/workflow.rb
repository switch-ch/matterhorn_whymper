class Matterhorn::Endpoint::Workflow < Matterhorn::Endpoint

  # --- attributes -------------------------------------------------------------


  # --- end point methodes -----------------------------------------------------

  def instance(wi_id)
    @workflow_inst = http_client.get(
      "workflow/instance/#{wi_id}.xml"
    ).body
    workflow_instance
  end


  def remove(wi_id, options = {})
    begin
      @workflow_inst = http_client.delete(
        "workflow/remove/#{wi_id}"
      ).body
    rescue Matterhorn::HttpClientError => ex
      Rails.logger.warn { "Matterhorn::Workflow::remove | WorkflowInstance[wi_id] could not be stopped!\n" +
                          "#{ex.class.name}: #{ex.to_s} / backtrace:\n#{ex.backtrace.join("\n")}" }
      return nil
    rescue => ex
      raise ex
    end
  end


  def resume(wi_id, options = {})
    options['id'] = wi_id
    @workflow_inst = http_client.post(
      "workflow/resume",
      options
    ).body
    workflow_instance
  end


  def stop(wi_id, options = {})
    begin
      options['id'] = wi_id
      @workflow_inst = http_client.post(
        "workflow/stop",
        options
      ).body
      workflow_instance
    rescue Matterhorn::HttpClientError => ex
      Rails.logger.warn { "Matterhorn::Workflow::stop | WorkflowInstance[wi_id] could not be stopped!\n" +
                          "#{ex.class.name}: #{ex.to_s} / backtrace:\n#{ex.backtrace.join("\n")}" }
      return nil
    rescue => ex
      raise ex
    end
  end


  def workflow_instance
    if !@workflow_inst.nil?
      Matterhorn::WorkflowInstance.new(@workflow_inst)
    else
      nil
    end
  end
  
end