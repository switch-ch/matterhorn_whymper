require 'json'

# ==================================================================== Matterhorn::Endpoint::Acl ===

class Matterhorn::Endpoint::Acl < Matterhorn::Endpoint


  # -------------------------------------------------------------------------- endpoint methodes ---

  # ------------------------------------------------------------------------------------- create ---

  # Create a new acl with name and acl list.
  #
  def create(name, acl)
    ret_acl = false
    begin
      split_response http_endpoint_client.post(
        "acl-manager/acl",
        { 'name' => name.to_s, 'acl' => acl.to_json }
      )
      ret_acl = JSON.parse(response_body)
    rescue => ex
      exception_handler('create', ex, {
          400 => "Unable to parse the ACL!",
          409 => "An ACL with the same name[#{name}] already exists!"
        }
      )
    end
    ret_acl
  end


  # --------------------------------------------------------------------------------------- read ---

  def index
    acls = {}
    begin
      split_response http_endpoint_client.get(
        "acl-manager/acl/acls.json"
      )
      acls = JSON.parse(response_body)
    rescue => ex
      exception_handler('index', ex, {})
    end
    acls
  end


  def get(acl_id)
    acl = {}
    begin
      split_response http_endpoint_client.get(
        "acl-manager/acl/#{acl_id}"
      )
      acl = JSON.parse(response_body)
    rescue => ex
      exception_handler('index', ex, {
          404 => "The Acl[#{acl_id}] has not been found!"
        }
      )
    end
    acl
  end


  # ------------------------------------------------------------------------------------- update ---

  def update(acl_id, name, acl)
    ret_acl = false
    begin
      split_response http_endpoint_client.put(
        "acl-manager/acl/#{acl_id}",
        { 'name' => name.to_s, 'acl' => acl.to_json }
      )
      ret_acl = JSON.parse(response_body)
    rescue => ex
      exception_handler('create', ex, {
          400 => "Unable to parse the ACL!",
          404 => "The Acl[#{acl_id}] has not been found!"
        }
      )
    end
    ret_acl
  end


  # ------------------------------------------------------------------------------------- delete ---

  def delete(acl_id)
    done = false
    begin
      split_response http_endpoint_client.delete(
        "acl-manager/acl/#{acl_id}"
      )
      done = true
    rescue => ex
      exception_handler('create', ex, {
          404 => "The Acl[#{acl_id}] has not been found!",
          409 => "The Acl[#{acl_id}] could not be deleted, there are still references on it!"
        }
      )
    end
    done
  end


  # ---------------------------------------------------------------------------- private section ---
  private


end # ------------------------------------------------------------ end Matterhorn::Endpoint::Acl ---
