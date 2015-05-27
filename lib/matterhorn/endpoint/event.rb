# ================================================================== Matterhorn::Endpoint::Event ===

# This endpoint is not a pure wrapper of the admin endpoint.
# Create should be done over ingest endpoint
# Update is implemented over the external API
#
class Matterhorn::Endpoint::Event < Matterhorn::Endpoint


  # -------------------------------------------------------------------------- endpoint methodes ---

  # ------------------------------------------------------------------------------------- create ---


  # --------------------------------------------------------------------------------------- read ---

  def read_media_package(media_package_id)
    media_package_xml = nil
    begin
      split_response http_endpoint_client.get(
        "archive/archive/mediapackage/#{media_package_id}"
      )
      media_package_xml = response_body
    rescue => ex
      exception_handler('read_media_package', ex, {
          404 => "The media package of event[#{media_package_id}] could not be found."
        }
      )
    end
    media_package_xml
  end


  # ------------------------------------------------------------------------------------- update ---

  def update(media_package_id, dublin_core)
    split_response http_api_client.get(
      "api/events/#{media_package_id}"
    )
  end


  # ------------------------------------------------------------------------------------- delete ---


  # ---------------------------------------------------------------------------- private section ---
  private



end # ---------------------------------------------------------- end Matterhorn::Endpoint::Event ---
