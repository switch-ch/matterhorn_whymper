require 'nokogiri'


# ===================================================================== Matterhorn::MediaPackage ===

class Matterhorn::MediaPackage
 
  # -------------------------------------------------------------------------- const definitions ---

  XML_NS_MEDIAPACKAGE = "http://mediapackage.opencastproject.org"
  

  # ----------------------------------------------------------------------------- initialization ---

  def initialize(xml = nil, options = {})
    if xml
      @document = Nokogiri::XML(xml)
    else
      @document = Nokogiri::XML::Builder.new do |xml|
        xml.mediapackage('xmlns' => XML_NS_MEDIAPACKAGE) do
          xml.media
          xml.metadata
          xml.attachments
        end
      end
      .doc
    end
    @path     = if (path = options[:path])
                  path + (path[-1] == '/' ? '' : '/')        # guarantee that path ends with a slash
                else
                  nil
                end
    @prefix   = options[:prefix]
    @filename = if @prefix
                  "#{@prefix}_manifest.xml"
                else
                  'manifest.xml'
                end
  end


  # ----------------------------------------------------------------------------------- methodes ---

  def document
    @document
  end

  
  def to_xml
    @document.to_xml
  end


  def inspect
    to_xml.to_s
  end


  #  <attachments>
  #    <attachment type="switchcastrecorder/metadata">
  #      <tags/>
  #      <url>metadata.plist</url>
  #    </attachment>
  #  </attachments>
  #
  def add_attachment(file, flavor)
    Nokogiri::XML::Builder.with(@document.at('attachments')) do |xml|
      xml.attachment(:type => flavor) {
        xml.tags
        xml.url file.sub(@path, '')
      }
    end
  end


  # <metadata>
  #   <catalog type="dublincore/episode">
  #     <mimetype>text/xml</mimetype>
  #     <tags/>
  #     <url>dublincore.xml</url>
  #   </catalog>
  # </metadata>
  #
  def add_catalog(file, flavor, mimetype = 'text/xml')
    Nokogiri::XML::Builder.with(@document.at('metadata')) do |xml|
      xml.catalog(:type => flavor) {
        xml.mimetype mimetype
        xml.tags
        xml.url file.sub(@path, '')
      }
    end
  end


  def add_dc_catalog(dublin_core)
    filename = @prefix ? "#{@prefix}_dublincore.xml" : 'dublincore.xml'
    flavor   = 'dublincore/episode'
    dc_doc   = Nokogiri::XML(dublin_core)
    dc_file  = File.join(@path, filename)
    File.open(dc_file, 'w') do |file|
      file.write(dc_doc.to_xml)
    end
    add_catalog(dc_file, flavor)
  end


  def dc_catalog_url
    url_elem = @document.at_xpath('//xmlns:catalog[@type="dublincore/episode"]/xmlns:url',
                                  {'xmlns' => XML_NS_MEDIAPACKAGE})
    if url_elem
      url_elem.content
    else
      nil
    end
  end


  # <media>
  #   <track type="presenter/source+partial">
  #     <tags/>
  #     <url>source1/mux_2013_12-17T14_51_29_738.mov</url>
  #   </track>
  # </media>
  #
  def add_track(file, flavor)
    Nokogiri::XML::Builder.with(@document.at('media')) do |xml|
      xml.track(:type => flavor) {
        xml.tags
        xml.url file.sub(@path, '')
      }
    end
  end


  def track_url(flavor)
    url_elem = @document.at_xpath("//xmlns:track[contains(@type, \"#{flavor}\")]/xmlns:url",
                                  {'xmlns' => Matterhorn::MediaPackage::XML_NS_MEDIAPACKAGE})
    if url_elem
      url_elem.content
    else
      nil
    end
  end


  # Returns the id attribute of mediapackage element.
  # <mediapackage xmlns="http://mediapackage.opencastproject.org" id="1" duration="2704016" start="2014-04-23T12:35:00Z">
  #
  def identifier
    @document.xpath('/xmlns:mediapackage/@id', {'xmlns' => XML_NS_MEDIAPACKAGE}).first.value
  end


  def save(path = @path, filename = @filename)
    unless path
      raise(Matterhorn::Error, "No path was set, where manifest file should be saved!")
    end
    manifest_file = File.join(path, filename)
    File.open(manifest_file, 'w') do |file|
      file.write(to_xml)
    end
  end


end # ------------------------------------------------------------- end Matterhorn::MediaPackage ---
