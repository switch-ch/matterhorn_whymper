require 'json'

# =================================================================== Matterhorn::Endpoint::User ===

class Matterhorn::Endpoint::User < Matterhorn::Endpoint


  # -------------------------------------------------------------------------- endpoint methodes ---

  # ------------------------------------------------------------------------------------- create ---

  # Create a new user with username, password, name, email and a list of roles.
  #
  def create(username, password, name, email, roles)
    done = false
    begin
      split_response http_endpoint_client.post(
        "user-utils",
        convert_to_form_param(username, password, name, email, roles)
      )
      done = true
    rescue => ex
      exception_handler('create', ex, {
          409 => "An user with this username: #{username} already exist!"
        }
      )
    end
    done
  end


  # --------------------------------------------------------------------------------------- read ---

  # Return a list of users as a hash
  # {
  #   'users' => {
  #     'user' => [
  #       {
  #         'username' => <username>,
  #         'name' => <name>,
  #         'email' => <email>,
  #         'roles' => [ <role>, ...]
  #       },
  #       ...
  #     ]
  #   }
  # }
  #
  def index(offset = 0, limit = 100)
    users = {}
    begin
      split_response http_endpoint_client.get(
        "/user-utils/users.json?limit=#{limit}&offset=#{offset}"
      )
      users = filter_users(JSON.parse(response_body))
    rescue => ex
      exception_handler('index', ex, {})
    end
    users
  end


  # Return a given user as a hash
  # {
  #   'user' => {
  #     'username' => <username>,
  #     'name' => <name>,
  #     'email' => <email>,
  #     'roles' => [ <role>, ...]
  #   }
  # }
  #
  def get(username)
    user = nil
    begin
      split_response http_endpoint_client.get(
        "user-utils/#{username}.json"
      )
      user = { 'user' => filter_user(JSON.parse(response_body)['user']) }
    rescue => ex
      exception_handler('create', ex, {
          404 => "User[#{username}] not found!"
        }
      )
    end
    user
  end


  # ------------------------------------------------------------------------------------- update ---

  def update(username, password, name, email, roles)
    done = false
    begin
      split_response http_endpoint_client.put(
        "user-utils/#{username}.json",
        convert_to_form_param(nil, password, name, email, roles)
      )
      done = true
    rescue => ex
      exception_handler('create', ex, {
          404 => "User[#{username}] not found!"
        }
      )
    end
    done
  end


  # ------------------------------------------------------------------------------------- delete ---

  def delete(username)
    done = false
    begin
      split_response http_endpoint_client.delete(
        "user-utils/#{username}.json"
      )
      done = true
    rescue => ex
      exception_handler('create', ex, {
          404 => "User[#{username}] not found!"
        }
      )
    end
    done
  end


  # ---------------------------------------------------------------------------- private section ---
  private

  def convert_to_form_param(username, password, name, email, roles)
    form_param = {}
    form_param['username'] = username.to_s    unless username.nil?
    form_param['password'] = password.to_s
    form_param['name']     = name.to_s
    form_param['email']    = email.to_s
    form_param['roles']    = roles.to_s
    form_param
  end
  

  def filter_users(respons_hash)
    unless respons_hash['users']['user'].kind_of?(Array)
      respons_hash['users']['user'] = [ respons_hash['users']['user'] ]
    end
    users = { 'users' => { 'user' => [] } }
    respons_hash['users']['user'].each do |user_hash|
      next unless user_hash.kind_of?(Hash)
      users['users']['user'] << filter_user(user_hash)
    end
    users
  end


  def filter_user(user_hash)
    return {} unless user_hash.kind_of?(Hash)
    return {
      'username' => user_hash['username'],
      'name'     => user_hash['name'],
      'email'    => user_hash['email'],
      'roles'    => filter_roles(user_hash['roles'])
    }
  end


  def filter_roles(roles_hash)
    role_list = { 'role' => [] }
    return role_list    if roles_hash.nil? ||
                           !roles_hash.kind_of?(Hash) ||
                           roles_hash['role'].nil?
    unless roles_hash['role'].kind_of?(Array)
      roles_hash['role'] = [ roles_hash['role'] ]
    end
    roles_hash['role'].each do |role|
      next unless role.kind_of?(Hash) &&
                  !role['name'].nil?
      role_list['role'] << role['name']
    end
    role_list
  end


end # ----------------------------------------------------------- end Matterhorn::Endpoint::User ---
