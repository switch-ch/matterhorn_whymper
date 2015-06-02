# ================================================================= Matterhorn::Endpoint::Ingest ===

class Matterhorn::Endpoint::Ingest < Matterhorn::Endpoint


  # -------------------------------------------------------------------------- endpoint methodes ---

  def addAttachment(file, flavor)
    unless @media_pkg_xml_remote then raise(Matterhorn::Error, "No media package is available!"); end
    @media_pkg_local.add_attachment(file, flavor)    if @media_pkg_local
    begin
      spit_response http_endpoint_client.post(
        "ingest/addAttachment",
        { 'flavor' => flavor,
          'mediaPackage' => @media_pkg_xml_remote,
          'BODY' => file
        }
      )
      @media_pkg_xml_remote = response_body
    rescue => ex
      exception_handler('addAttachment', ex, {
          400 => "Media package not valid! / media package:\n#{@media_pkg_xml_remote}"
        }
      )
      raise ex
    end
    @media_pkg_xml_remote
  end


  def addCatalog(file, flavor)
    unless @media_pkg_xml_remote then raise(Matterhorn::Error, "No media package is available!"); end
    @media_pkg_local.add_catalog(file, flavor)    if @media_pkg_local
    begin
      split_response http_endpoint_client.post(
        "ingest/addCatalog",
        { 'flavor' => flavor,
          'mediaPackage' => @media_pkg_xml_remote,
          'BODY' => file
        }
      )
      @media_pkg_xml_remote = response_body
    rescue => ex
      exception_handler('addCatalog', ex, {
          400 => "Media package not valid! / media package:\n#{@media_pkg_xml_remote}"
        }
      )
      raise ex
    end
    @media_pkg_xml_remote
  end


  def addDCCatalog(dublin_core)
    unless @media_pkg_xml_remote then raise(Matterhorn::Error, "No media package is available!"); end
    @media_pkg_local.add_dc_catalog(dublin_core)    if @media_pkg_local
    begin
      split_response http_endpoint_client.post(
        "ingest/addDCCatalog",
        { 'flavor' => 'dublincore/episode',
          'mediaPackage' => @media_pkg_xml_remote,
          'dublinCore' => dublin_core
        }
      )
      @media_pkg_xml_remote = response_body
    rescue => ex
      exception_handler('create', ex, {
          400 => "Media package not valid! / media package:\n#{@media_pkg_xml_remote}"
        }
      )
      raise ex
    end
    @media_pkg_xml_remote
  end

  HTTP_PROTOCOL_RE = /^https?:/

  def addTrack(file_or_url, flavor)
    unless @media_pkg_xml_remote then raise(Matterhorn::Error, "No media package is available!"); end
    @media_pkg_local.add_track(file_or_url, flavor) if @media_pkg_local
    begin
      if HTTP_PROTOCOL_RE =~ file_or_url
        split_response http_endpoint_client.post(
          "ingest/addTrack",
          { 'flavor' => flavor,
            'mediaPackage' => @media_pkg_xml_remote,
            'url' => file_or_url
          }
        )
      else
        split_response http_endpoint_client.post(
          "ingest/addTrack",
          { 'flavor' => flavor,
            'mediaPackage' => @media_pkg_xml_remote,
            'BODY' => file_or_url
          }
        )
      end
      @media_pkg_xml_remote = response_body
    rescue => ex
      exception_handler('addTrack', ex, {
          400 => "Media package not valid! / media package:\n#{@media_pkg_xml_remote}"
        }
      )
      raise ex
    end
    @media_pkg_xml_remote
  end


  # Create a media package on the matterhorn server.
  # If the source_path to the source folder of uploaded items for that media package is given,
  # then a local media description file 'manifest.xml' will be automaticaly saved in that folder.
  #
  def createMediaPackage(source_path = nil)
    if @media_pkg_xml_remote then raise(Matterhorn::Error, "A media package is allready created!"); end
    @media_pkg_local = if source_path
                         Matterhorn::MediaPackage.new(nil, {:path => source_path})
                       else
                         nil
                       end
    begin
      split_response http_endpoint_client.get(
        "ingest/createMediaPackage"
      )
      @media_pkg_xml_remote = response_body
    rescue => ex
      exception_handler('createMediaPackage', ex, {})
      raise ex
    end
    @media_pkg_xml_remote
  end


  def ingest(wdID = 'full', options = {})
    unless @media_pkg_xml_remote then raise(Matterhorn::Error, "No media package is available!"); end
    @media_pkg_local.save    if @media_pkg_local
    options['mediaPackage'] = @media_pkg_xml_remote
    begin
      split_response http_endpoint_client.post(
        "ingest/ingest/#{wdID}",
        options
      )
      @workflow_inst = response_body
    rescue => ex
      exception_handler('create', ex, {
          400 => "Media package not valid! / media package:\n#{@media_pkg_xml_remote}"
        }
      )
      raise ex
    end
    workflow_instance
  end


  def media_package_idenfifier
    return nil unless @media_pkg_xml_remote
    Matterhorn::MediaPackage.new(@media_pkg_xml_remote).identifier
  end


  # ---------------------------------------------------------------------------- helper methodes ---

  def media_package(kind = 'local')
    unless @media_pkg_xml_remote then raise(Matterhorn::Error, "No media package is available!"); end
    if kind == 'local' && @media_pkg_local
      return @media_pkg_local
    elsif @media_pkg_xml_remote
      Matterhorn::MediaPackage.new(@media_pkg_xml_remote)
    else
      nil
    end
  end


  def setTitle(title)
    dublin_core = <<DUBLIN_CORE
<?xml version="1.0" encoding="UTF-8"?>
<dublincore xmlns="http://www.opencastproject.org/xsd/1.0/dublincore/" xmlns:dcterms="http://purl.org/dc/terms/">
  <dcterms:title>#{title.encode(:xml => :text)}</dcterms:title>
</dublincore>
DUBLIN_CORE
    addDCCatalog(dublin_core)
  end


  def workflow_instance
    @workflow_inst ? Matterhorn::WorkflowInstance.new(@workflow_inst) : nil
  end

  
end # --------------------------------------------------------- end Matterhorn::Endpoint::Ingest ---
