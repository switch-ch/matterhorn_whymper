require 'json'

# ================================================================== Matterhorn::Endpoint::Group ===

class Matterhorn::Endpoint::Group < Matterhorn::Endpoint


  # -------------------------------------------------------------------------- endpoint methodes ---

  # ------------------------------------------------------------------------------------- create ---

  # Create a new group with name and descritption.
  # The group_id will be created from the name -> downcase and underscore.
  # If a role is unknown to the system, it will be created.
  # If a user is unknown only the relation ship beteen the group and the member will be stored.
  # The user will not be created!
  #
  def create(name, description = nil, roles = nil, users = nil)
    done = false
    begin
      split_response http_endpoint_client.post(
        "groups",
        convert_to_form_param(name, description, roles, users)
      )
      done = true
    rescue => ex
      exception_handler('create', ex, {
          400 => "Group name: #{name} too long!"
        }
      )
    end
    done
  end


  # --------------------------------------------------------------------------------------- read ---

  def index(offset = 0, limit = 100)
    groups = {}
    begin
      split_response http_endpoint_client.get(
        "groups/groups.json"
      )
      groups = filter_groups(JSON.parse(response_body))
    rescue => ex
      exception_handler('index', ex, {})
    end
    groups
  end



  # ------------------------------------------------------------------------------------- update ---

  def update(group_id, name, description = nil, roles = nil, users = nil)
    done = false
    begin
      split_response http_endpoint_client.put(
        "groups/#{group_id}",
        convert_to_form_param(name, description, roles, users)
      )
      done = true
    rescue => ex
      exception_handler('create', ex, {
          400 => "Group name: #{name} too long!",
          404 => "Group[#{group_id}] not found!"
        }
      )
    end
    done
  end


  # ------------------------------------------------------------------------------------- delete ---

  def delete(group_id)
    done = false
    begin
      split_response http_endpoint_client.delete(
        "groups/#{group_id}"
      )
      done = true
    rescue => ex
      exception_handler('create', ex, {
          404 => "Group[#{group_id}] not found!"
        }
      )
    end
    done
  end


  # ---------------------------------------------------------------------------- private section ---
  private

  def convert_to_form_param(name, description, roles, users)
    form_param = {}
    form_param['name'] = name.to_s
    if description.kind_of?(String)
      form_param['description'] = description
    end
    if roles.kind_of?(String)
      form_param['roles'] = roles
    elsif roles.kind_of?(Array)
      form_param['roles'] = roles.compact.uniq.join(',')
    end
    if users.kind_of?(String)
      form_param['users'] = users
    elsif users.kind_of?(Array)
      form_param['users'] = users.compact.uniq.join(',')
    end
    form_param
  end
  

  def filter_groups(respons_hash)
    MatterhornWhymper.logger.debug { respons_hash.inspect }
    groups = { }
    respons_hash['groups']['group'].each do |group_hash|

      groups[group_hash['id']] = {
        :group_id => group_hash['id'],
        :name => group_hash['name'],
        :description => group_hash['description'],
        :role => group_hash['role'],
      }

      groups[group_hash['id']][:members] = 
        if    group_hash['members'].nil?                       then []
        elsif group_hash['members'].kind_of?(String)           then []
        elsif group_hash['members']['member'].nil?             then []
        elsif group_hash['members']['member'].kind_of?(Array)  then group_hash['members']['member']
        elsif group_hash['members']['member'].kind_of?(String) then [ group_hash['members']['member'] ]
        else                                                        []
        end

      groups[group_hash['id']][:roles] = 
        if    group_hash['roles'].nil?                    then []
        elsif group_hash['roles'].kind_of?(String) &&
              group_hash['roles'].empty?                  then []
        elsif group_hash['roles'].kind_of?(String) &&
              !group_hash['roles'].empty?                 then [ group_hash['roles'] ]
        elsif group_hash['roles']['role'].nil?            then []
        elsif group_hash['roles']['role'].kind_of?(Array) then group_hash['roles']['role'].map { |r| r['name'] }
        elsif group_hash['roles']['role'].kind_of?(Hash)  then [ group_hash['roles']['role']['name'] ]
        else                                                   []
        end

    end
    groups
  end


end # ---------------------------------------------------------- end Matterhorn::Endpoint::Group ---
