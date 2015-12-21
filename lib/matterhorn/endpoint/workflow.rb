# =============================================================== Matterhorn::Endpoint::Workflow ===

class Matterhorn::Endpoint::Workflow < Matterhorn::Endpoint


  # -------------------------------------------------------------------------- endpoint methodes ---

  # ------------------------------------------------------------------------------------- create ---

  def start(workflow_definition, mediapackage_xml, parent = nil, properties = nil)
    wi = nil
    begin
      params = {}
      params['definition']   = workflow_definition
      params['mediapackage'] = mediapackage_xml
      params['parent']       = parent               if !parent.nil?
      params['properties']   = properties           if !properties.nil?
      split_response http_endpoint_client.post(
        "workflow/start", params
      )
      wi = response_body
    rescue => ex
      exception_handler('stop', ex, {
          404 => "Parent WorkflowInstance[#{parent}] does not exist."
        }
      )
    end
    wi ? Matterhorn::WorkflowInstance.new(wi) : nil
  end


  # --------------------------------------------------------------------------------------- read ---

  def instance(wi_id)
    wi = nil
    begin
      split_response http_endpoint_client.get(
        "workflow/instance/#{wi_id}.xml"
      )
      wi = response_body
    rescue => ex
      exception_handler('instance', ex, {
          404 => "WorkflowInstance[#{wi_id}]: No workflow instance with that identifier exists."
        }
      )
    end
    wi ? Matterhorn::WorkflowInstance.new(wi) : nil
  end


  def statistics
    stati = nil
    begin
      split_response http_endpoint_client.get(
        "workflow/statistics.json"
      )
      stati = JSON.parse(response_body)
    rescue => ex
      exception_handler('statistics', ex, {})
    end
    stati ? Matterhorn::WorkflowStatistics.new(stati) : nil
  end


  # ------------------------------------------------------------------------------------- update ---

  def resume(wi_id)
    wi = nil
    begin
      split_response http_endpoint_client.post(
        "workflow/resume",
        { 'id' => wi_id }
      )
      wi = response_body
    rescue => ex
      exception_handler('resume', ex, {
          404 => "WorkflowInstance[#{wi_id}]: No suspended workflow instance " +
                 "with that identifier exists."
        }
      )
    end
    wi ? Matterhorn::WorkflowInstance.new(wi) : nil
  end


  def stop(wi_id)
    wi = nil
    begin
      split_response http_endpoint_client.post(
        "workflow/stop",
        { 'id' => wi_id }
      )
      wi = response_body
    rescue => ex
      exception_handler('stop', ex, {
          404 => "WorkflowInstance[#{wi_id}]: No running workflow instance " +
                 "with that identifier exists."
        }
      )
    end
    wi ? Matterhorn::WorkflowInstance.new(wi) : nil
  end


  # ------------------------------------------------------------------------------------- delete ---

  def remove(wi_id)
    wi_removed = false
    begin
      split_response http_endpoint_client.delete(
        "workflow/remove/#{wi_id}"
      )
      wi_removed = true
    rescue => ex
      exception_handler('remove', ex, {
          404 => "WorkflowInstance[#{wi_id}]: No workflow instance with that identifier exists."
        }
      )
    end
    wi_removed
  end

  
end # ------------------------------------------------------- end Matterhorn::Endpoint::Workflow ---