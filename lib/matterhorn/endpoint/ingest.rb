class Matterhorn::Endpoint::Ingest < Matterhorn::Endpoint

  # --- attributes -------------------------------------------------------------


  # --- end point methodes -----------------------------------------------------

  def addAttachment(file, flavor)
    if @media_pkg_remote.nil?
      raise(Matterhorn::Error, "No media package is available!")
    end
    @media_pkg_local.add_attachment(file, flavor)
    @media_pkg_remote = http_client.post(
      "ingest/addAttachment",
      { 'flavor' => flavor,
        'mediaPackage' => @media_pkg_remote,
        'BODY' => file
      }
    ).body
  end


  def addCatalog(file, flavor)
    if @media_pkg_remote.nil?
      raise(Matterhorn::Error, "No media package is available!")
    end
    @media_pkg_local.add_catalog(file, flavor)
    @media_pkg_remote = http_client.post(
      "ingest/addCatalog",
      { 'flavor' => flavor,
        'mediaPackage' => @media_pkg_remote,
        'BODY' => file
      }
    ).body
  end


  def addDCCatalog(dublin_core)
    if @media_pkg_remote.nil?
      raise(Matterhorn::Error, "No media package is available!")
    end
    @media_pkg_local.add_dc_catalog(dublin_core)
    @media_pkg_remote = http_client.post(
      "ingest/addDCCatalog",
      { 'flavor' => 'dublincore/episode',
        'mediaPackage' => @media_pkg_remote,
        'dublinCore' => dublin_core
      }
    ).body
  end

     
  def addTrack(file, flavor)
    if @media_pkg_remote.nil?
      raise(Matterhorn::Error, "No media package is available!")
    end
    @media_pkg_local.add_track(file, flavor)
    @media_pkg_remote = http_client.post(
      "ingest/addTrack",
      { 'flavor' => flavor,
        'mediaPackage' => @media_pkg_remote,
        'BODY' => file
      }
    ).body
  end


  def createMediaPackage(path = '')
    if !@media_pkg_remote.nil?
      raise(Matterhorn::Error, "A media package is allready created!")
    end
    @media_pkg_local = Matterhorn::MediaPackage.new(path)
    @media_pkg_remote = http_client.get(
      "ingest/createMediaPackage"
    ).body
  end


  def ingest(wdID = 'full', options = {})
    if @media_pkg_remote.nil?
      raise(Matterhorn::Error, "No media package is available!")
    end
    @media_pkg_local.save    if !@media_pkg_local.nil?
    options['mediaPackage'] = @media_pkg_remote
    @workflow_inst = http_client.post(
      "ingest/ingest/#{wdID}",
      options
    ).body
    workflow_instance
  end


  def media_package(kind = 'local')
    if kind == 'local' && !@media_pkg_local.nil?
      return @media_pkg_local
    elsif !@media_pkg_remote.nil?
      Matterhorn::MediaPackage.new(@media_pkg_remote)
    else
      nil
    end
  end


  def setTitle(title)
    dublin_core = <<DUBLIN_CORE
<?xml version="1.0" encoding="UTF-8"?>
<dublincore xmlns="http://www.opencastproject.org/xsd/1.0/dublincore/" xmlns:dcterms="http://purl.org/dc/terms/">
  <dcterms:title>#{title}</dcterms:title>
</dublincore>
DUBLIN_CORE
    addDCCatalog(dublin_core)
  end


  def workflow_instance
    if !@workflow_inst.nil?
      Matterhorn::WorkflowInstance.new(@workflow_inst)
    else
      nil
    end
  end

  
end