# =============================================================== Matterhorn::Endpoint::Workflow ===

class Matterhorn::Endpoint::Workflow < Matterhorn::Endpoint


  # -------------------------------------------------------------------------- endpoint methodes ---

  def instance(wi_id)
    wi = nil
    begin
      split_response http_client.get(
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


  def remove(wi_id)
    wi_removed = false
    begin
      split_response http_client.delete(
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


  def resume(wi_id)
    wi = nil
    begin
      split_response http_client.post(
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
      split_response http_client.post(
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

  
end # ------------------------------------------------------- end Matterhorn::Endpoint::Workflow ---