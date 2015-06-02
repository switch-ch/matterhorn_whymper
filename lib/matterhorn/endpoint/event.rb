require 'json'

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
    media_package = nil
    begin
      split_response http_endpoint_client.get(
        "archive/archive/mediapackage/#{media_package_id}"
      )
      media_package = Matterhorn::MediaPackage.new(response_body)
    rescue => ex
      exception_handler('read_media_package', ex, {
          404 => "The media package of event[#{media_package_id}] could not be found."
        }
      )
    end
    media_package
  end


  def read_dublin_core(media_package_id)
    dublin_core = nil
    begin
      mp = read_media_package(media_package_id)
      if !mp.nil?
        dc_uri = URI.parse(mp.dc_catalog_url)
        split_response http_endpoint_client.get(dc_uri.request_uri)
        dublin_core = Matterhorn::DublinCore.new(response_body)
      end
    rescue => ex
      exception_handler('read_dublin_core', ex, {
          404 => "The media package of event[#{media_package_id}] could not be found."
        }
      )
    end
    dublin_core
  end


  # ------------------------------------------------------------------------------------- update ---

  def changeable_element?(element_name)
    ['title', 'subject', 'description', 'language', 'license',
     'contributer', 'source'].include?(element_name)
  end 


  def update_dublin_core(media_package_id, dublin_core)
    updated = false
    begin
      dc_field_arr = []
      dublin_core.each_dcterms_element do |name, content|
        if changeable_element?(name) && !content.blank?
          dc_field_arr << {
            'id'    => name,
            'value' => content
          }
        end
      end
      split_response http_api_client.put(
        "api/events/#{media_package_id}/metadata?type=dublincore/episode",
        { 'metadata' => dc_field_arr.to_json }
      )
      updated = true
    rescue => ex
      exception_handler('update_dublin_core', ex, {
          400 => "The request is invaldi or inconsistent.",
          404 => "The media package of event[#{media_package_id}] could not be found."
        }
      )
    end
    updated
  end


  # ------------------------------------------------------------------------------------- delete ---

  def delete(media_package_id)
    begin
      split_response http_endpoint_client.delete(
        "archive/delete/#{media_package_id}"
      )
    rescue => ex
      exception_handler('delete', ex, {})
    end
  end


  # ---------------------------------------------------------------------------- private section ---
  private



end # ---------------------------------------------------------- end Matterhorn::Endpoint::Event ---
