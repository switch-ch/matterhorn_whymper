require 'json'

# ================================================================== Matterhorn::Endpoint::Event ===

# This endpoint is not a pure wrapper of the archive endpoint.
# Create should be done over ingest endpoint
# Update is implemented over the external API
# In the code the evnent_id is used. This id is equal to media_package_id.
#
class Matterhorn::Endpoint::Event < Matterhorn::Endpoint


  # -------------------------------------------------------------------------- endpoint methodes ---

  # ------------------------------------------------------------------------------------- create ---


  # --------------------------------------------------------------------------------------- read ---

  def read(event_id)
    event = nil
    begin
      split_response http_api_client.get(
        "api/events/#{event_id}"
      )
      event = JSON.parse(response_body)
    rescue => ex
      exception_handler('read', ex, {
          404 => "The Event[#{event_id}] could not be found!"
        }
      )
    end
    event
  end


  # ------------------------------------------------------------------------------------- update ---

  def changeable_element?(element_name)
    ['title', 'subject', 'description', 'language', 'license', 'source', 'isPartOf'].
    include?(element_name)
  end 


  def update_dublin_core(event_id, dublin_core)
    updated = false
    begin
      dc_field_arr = []
      dublin_core.each_dcterms_element do |name, content|
        if changeable_element?(name) && !content.empty?
          dc_field_arr << {
            'id'    => name,
            'value' => content
          }
        end
      end
      split_response http_api_client.put(
        "api/events/#{event_id}/metadata?type=dublincore/episode",
        { 'metadata' => dc_field_arr.to_json }
      )
      updated = true
    rescue => ex
      exception_handler('update_dublin_core', ex, {
          400 => "The request is invaldi or inconsistent.",
          404 => "The media package of event[#{event_id}] could not be found."
        }
      )
    end
    updated
  end


  # ------------------------------------------------------------------------------------- delete ---

  def delete(event_id)
    begin
      done = false
      split_response http_api_client.delete(
        "api/events/#{event_id}"
      )
      done = true
    rescue => ex
      exception_handler('delete', ex, {
          404 => "The Event[#{event_id}] could not be found!"
        }
      )
    end
    done
  end


  # ---------------------------------------------------------------------------- private section ---
  private



end # ---------------------------------------------------------- end Matterhorn::Endpoint::Event ---
