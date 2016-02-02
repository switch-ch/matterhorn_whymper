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


  # Return a list of worklows as a hash
  # {
  #   "workflows": {
  #     "totalCount": "224",
  #     "count": "20",
  #     "startPage": "0",
  #     "workflow": [
  #       {
  #         "id": "267313",
  #         "state": "FAILED",
  #         "template": "switchcast-publish-all-1.0",
  #         "mediapackage": {
  #           "id": "3756ddd8-2f2a-4728-9367-5790cdf4980f",
  #           "title": "Paedagogische und psychologische Grundbegriffe",
  #           "series": "abf06ea8-d068-4e6e-8b37-b252b101694f",
  #           "seriestitle": "Vorlesungen PH Luzern H13F14"
  #         }
  #       }
  #       ...
  #
  # /workflow/instances.json?state=&q=&seriesId=&seriesTitle=&creator=&contributor=&fromdate=&todate=&language=&license=&title=&subject=&workflowdefinition=switchcast-publish-all-1.0&mp=&op=&sort=&startPage=0&count=0&compact=
  #
  def find(options = {})
    instances = nil
    begin
      split_response http_endpoint_client.get(
        "workflow/instances.json#{build_query_str(options)}"
      )
      instances = filter_workflows(JSON.parse(response_body))
    rescue => ex
      exception_handler('find', ex, {})
    end
    instances
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


  # ---------------------------------------------------------------------------- private section ---
  private
  
  def filter_workflows(response_hash)
    workflows = { 'workflows' => { 'workflow' => [] } }
    return workflows    if response_hash.nil? ||
                           !response_hash.kind_of?(Hash) ||
                           response_hash['workflows'].nil?
    workflows_hash = response_hash['workflows']
    return workflows    if workflows_hash.nil? ||
                           !workflows_hash.kind_of?(Hash) ||
                           workflows_hash['workflow'].nil?
    unless workflows_hash['workflow'].kind_of?(Array)
      workflows_hash['workflow'] = [ workflows_hash['workflow'] ]
    end
    ['totalCount', 'count', 'startPage'].each do |key|
      workflows['workflows'][key] = workflows_hash[key]
    end
    workflows_hash['workflow'].each do |workflow_hash|
      next unless workflow_hash.kind_of?(Hash)
      workflows['workflows']['workflow'] << filter_workflow(workflow_hash)
    end
    workflows
  end


  def filter_workflow(workflow_hash)
    workflow = {}
    return workflow    unless workflow_hash.kind_of?(Hash)
    ['id', 'state', 'template'].each do |key|
      workflow[key] = workflow_hash[key]
    end
    workflow['mediapackage'] = filter_mediapackage(workflow_hash['mediapackage'])
    workflow
  end
  

  def filter_mediapackage(mediapackage_hash)
    mediapackage = {}
    return mediapackage    unless mediapackage_hash.kind_of?(Hash)
    ['id', 'title', 'series', 'seriestitle'].each do |key|
      mediapackage[key] = mediapackage_hash[key]
    end
    mediapackage
  end


end # ------------------------------------------------------- end Matterhorn::Endpoint::Workflow ---