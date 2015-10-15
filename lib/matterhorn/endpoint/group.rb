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

  # Return a list of groups as a hash
  # {
  #   'groups' => {
  #     'group' => [
  #       {
  #         'id' => <group_id>,
  #         'name' => <name>,
  #         'description' => <description>,
  #         'role' => <role>,
  #         'memebers' => [ <username>, ... ],
  #         'roles' => [ <role>, ...],
  #       },
  #       ...
  #     ]
  #   }
  # }
  #
  def index(offset = 0, limit = 100)
    groups = {}
    begin
      split_response http_endpoint_client.get(
        "groups/groups.json?limit=#{limit}&offset=#{offset}"
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
    groups = { 'groups' => { 'group' => [] } }
    return groups    if respons_hash.nil? ||
                        !respons_hash.kind_of?(Hash) ||
                        respons_hash['groups'].nil?
    groups_hash = respons_hash['groups']
    return groups    if groups_hash.nil? ||
                        !groups_hash.kind_of?(Hash) ||
                        groups_hash['group'].nil?
    unless groups_hash['group'].kind_of?(Array)
      groups_hash['group'] = [ groups_hash['group'] ]
    end
    groups_hash['group'].each do |group_hash|
      next unless group_hash.kind_of?(Hash)
      groups['groups']['group'] << {
        'id' => group_hash['id'],
        'name' => group_hash['name'],
        'description' => group_hash['description'],
        'role' => group_hash['role'],
        'members' => filter_members(group_hash['members']),
        'roles' => filter_roles(group_hash['roles'])
      }
    end
    groups
  end


  def filter_members(members_hash)
    member_list = [] 
    return member_list    if members_hash.nil? ||
                             !members_hash.kind_of?(Hash) ||
                             members_hash['member'].nil?
    unless members_hash['member'].kind_of?(Array)
      members_hash['member'] = [ members_hash['member'] ]
    end
    members_hash['member'].each do |member|
      next unless member.kind_of?(String)
      member_list << member
    end
    member_list
  end


  def filter_roles(roles_hash)
    role_list = []
    return role_list    if roles_hash.nil? ||
                           !roles_hash.kind_of?(Hash) ||
                           roles_hash['role'].nil?
    unless roles_hash['role'].kind_of?(Array)
      roles_hash['role'] = [ roles_hash['role'] ]
    end
    roles_hash['role'].each do |role|
      next unless role.kind_of?(Hash) &&
                  !role['name'].nil?
      role_list << role['name']
    end
    role_list
  end


end # ---------------------------------------------------------- end Matterhorn::Endpoint::Group ---
