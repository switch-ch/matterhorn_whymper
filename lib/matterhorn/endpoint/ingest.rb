# ================================================================= Matterhorn::Endpoint::Ingest ===

class Matterhorn::Endpoint::Ingest < Matterhorn::Endpoint


  # -------------------------------------------------------------------------- endpoint methodes ---

  def addAttachment(file, flavor)
    unless @media_pkg_remote then raise(Matterhorn::Error, "No media package is available!"); end
    @media_pkg_local.add_attachment(file, flavor)    if @media_pkg_local
    begin
      @media_pkg_remote = http_client.post(
        "ingest/addAttachment",
        { 'flavor' => flavor,
          'mediaPackage' => @media_pkg_remote,
          'BODY' => file
        }
      ).body
    rescue Matterhorn::HttpClientError => ex
      MatterhornWhymper.logger.error { "#{self.class.name}::addAttachment | " +
                                 "Media package not valid! / media package:\n#{@media_pkg_remote}" }
      raise ex
    rescue Matterhorn::HttpServerError => ex
      MatterhornWhymper.logger.error { "#{self.class.name}::addAttachment | " +
                                       "An internal server error has occurred on Matterhorn!" }
      raise ex
    end
    @media_pkg_remote
  end


  def addCatalog(file, flavor)
    unless @media_pkg_remote then raise(Matterhorn::Error, "No media package is available!"); end
    @media_pkg_local.add_catalog(file, flavor)    if @media_pkg_local
    begin
      @media_pkg_remote = http_client.post(
        "ingest/addCatalog",
        { 'flavor' => flavor,
          'mediaPackage' => @media_pkg_remote,
          'BODY' => file
        }
      ).body
    rescue Matterhorn::HttpClientError => ex
      MatterhornWhymper.logger.error { "#{self.class.name}::addCatalog | " +
                                 "Media package not valid! / media package:\n#{@media_pkg_remote}" }
      raise ex
    rescue Matterhorn::HttpServerError => ex
      MatterhornWhymper.logger.error { "#{self.class.name}::addCatalog | " +
                                       "An internal server error has occurred on Matterhorn!" }
      raise ex
    end
    @media_pkg_remote
  end


  def addDCCatalog(dublin_core)
    unless @media_pkg_remote then raise(Matterhorn::Error, "No media package is available!"); end
    @media_pkg_local.add_dc_catalog(dublin_core)    if @media_pkg_local
    begin
      @media_pkg_remote = http_client.post(
        "ingest/addDCCatalog",
        { 'flavor' => 'dublincore/episode',
          'mediaPackage' => @media_pkg_remote,
          'dublinCore' => dublin_core
        }
      ).body
    rescue Matterhorn::HttpClientError => ex
      MatterhornWhymper.logger.error { "#{self.class.name}::addDCCatalog | " +
                                 "Media package not valid! / media package:\n#{@media_pkg_remote}" }
      raise ex
    rescue Matterhorn::HttpServerError => ex
      MatterhornWhymper.logger.error { "#{self.class.name}::addDCCatalog | " +
                                       "An internal server error has occurred on Matterhorn!" }
      raise ex
    end
    @media_pkg_remote
  end

  HTTP_PROTOCOL_RE = /^https?:/

  def addTrack(file_or_url, flavor)
    unless @media_pkg_remote then raise(Matterhorn::Error, "No media package is available!"); end
    @media_pkg_local.add_track(file_or_url, flavor) if @media_pkg_local
    begin
      @media_pkg_remote = 
        if HTTP_PROTOCOL_RE =~ file_or_url
          http_client.post(
            "ingest/addTrack",
            {
              'flavor' => flavor,
              'mediaPackage' => @media_pkg_remote,
              'url' => file_or_url
            }
          ).body
        else
          http_client.post(
            "ingest/addTrack",
            {
              'flavor' => flavor,
              'mediaPackage' => @media_pkg_remote,
              'BODY' => file_or_url
            }
          ).body
        end
    rescue Matterhorn::HttpClientError => ex
      MatterhornWhymper.logger.error { "#{self.class.name}::addTrack | " +
                                 "Media package not valid! / media package:\n#{@media_pkg_remote}" }
      raise ex
    rescue Matterhorn::HttpServerError => ex
      MatterhornWhymper.logger.error { "#{self.class.name}::addTrack | " +
                                       "An internal server error has occurred on Matterhorn!" }
      raise ex
    end
    @media_pkg_remote
  end


  # Create a media package on the matterhorn server.
  # If the source_path to the source folder of uploaded items for that media package is given,
  # then a local media description file 'manifest.xml' will be automaticaly saved in that folder.
  #
  def createMediaPackage(source_path = nil)
    if @media_pkg_remote then raise(Matterhorn::Error, "A media package is allready created!"); end
    @media_pkg_local = source_path ? Matterhorn::MediaPackage.new(source_path) : nil
    begin
      @media_pkg_remote = http_client.get(
        "ingest/createMediaPackage"
      ).body
    rescue Matterhorn::HttpServerError => ex
      MatterhornWhymper.logger.error { "#{self.class.name}::createMediaPackage | " +
                                       "An internal server error has occurred on Matterhorn!" }
      raise ex
    end
    @media_pkg_remote
  end


  def ingest(wdID = 'full', options = {})
    unless @media_pkg_remote then raise(Matterhorn::Error, "No media package is available!"); end
    @media_pkg_local.save    if @media_pkg_local
    options['mediaPackage'] = @media_pkg_remote
    begin
      @workflow_inst = http_client.post(
        "ingest/ingest/#{wdID}",
        options
      ).body
    rescue Matterhorn::HttpClientError => ex
      MatterhornWhymper.logger.error { "#{self.class.name}::ingest | " +
                                 "Media package not valid! / media package:\n#{@media_pkg_remote}" }
      raise ex
    rescue Matterhorn::HttpServerError => ex
      MatterhornWhymper.logger.error { "#{self.class.name}::ingest | " +
                                       "An internal server error has occurred on Matterhorn!" }
      raise ex
    end
    workflow_instance
  end


  # ---------------------------------------------------------------------------- helper methodes ---

  def media_package(kind = 'local')
    unless @media_pkg_remote then raise(Matterhorn::Error, "No media package is available!"); end
    if kind == 'local' && @media_pkg_local
      return @media_pkg_local
    elsif @media_pkg_remote
      Matterhorn::MediaPackage.new(@media_pkg_remote)
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
