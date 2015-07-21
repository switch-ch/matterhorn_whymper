require 'uri'


# ============================================================ Matterhorn::Endpoint::Staticfiles ===

class Matterhorn::Endpoint::Staticfiles < Matterhorn::Endpoint


  # -------------------------------------------------------------------------- endpoint methodes ---

  # ------------------------------------------------------------------------------------- create ---

  # Uploads a file into the static file folder on Mattherhorn.
  # Return the uuid of this uploaded resources.
  #
  def upload(file)
    uuid = nil
    begin
      split_response http_endpoint_client.post(
        "staticfiles",
        { 'BODY' => file }
      )
      uuid = response_body
    rescue => ex
      exception_handler('upload', ex, {
          400 => "No filename or file to upload found. Or the uploaded size is too big"
        }
      )
    end
    uuid
  end


  # Persists a recently uploaded file to the permanent storage.
  #
  def persist(uuid)
    persisted = false
    begin
      split_response http_endpoint_client.post(
        "staticfiles/#{uuid}/persist",
        {}
      )
      persisted = true
    rescue => ex
      exception_handler('persist', ex, {
          400 => "No file by the given UUID #{uuid} found."
        }
      )
    end
    persisted
  end


  # --------------------------------------------------------------------------------------- read ---


  
  # ------------------------------------------------------------------------------------- update ---

  

  # ------------------------------------------------------------------------------------- delete ---

  # Remove the static file.
  #
  def delete(uuid)
    deleted = false
    begin
      split_response http_endpoint_client.delete(
        "staticfiles/#{uuid}"
      )
      deleted = true
    rescue => ex
      exception_handler('delete', ex, {
          400 => "No file by the given UUID #{uuid} found."
        }
      )
    end
    deleted
  end


  # ---------------------------------------------------------------------------- private section ---
  private


end # -------------------------------------------------------- Matterhorn::Endpoint::Staticfiles ---
