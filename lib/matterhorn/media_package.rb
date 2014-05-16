require 'nokogiri'


# =================================================================================== Matterhorn ===

module Matterhorn


  # =================================================================== Matterhorn::MediaPackage ===

  class MediaPackage
   
    # ------------------------------------------------------------------------ const definitions ---

    XML_NS_MEDIAPACKAGE = "http://mediapackage.opencastproject.org"
    

    # --------------------------------------------------------------------------- initialization ---
  
    def initialize(path, xml = nil)
      @path = path + (path[-1] == '/' ? '' : '/')            # guarantee that path ends with a slash
      if !xml.nil?
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
    end

  
    # --------------------------------------------------------------------------------- methodes ---

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
      filename = 'dublincore.xml'
      flavor   = 'dublincore/episode'
      dc_doc   = Nokogiri::XML(dublin_core)
      dc_file  = File.join(@path, filename)
      File.open(dc_file, 'w') do |file|
        file.write(dc_doc.to_xml)
      end
      add_catalog(dc_file, flavor)
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


    def save(path = @path)
      manifest_file = File.join(path, 'manifest.xml')
      File.open(manifest_file, 'w') do |file|
        file.write(@document.to_xml)
      end
    end


    def to_xml
      @document.to_xml
    end


  end # ----------------------------------------------------------- end Matterhorn::MediaPackage ---


end # --------------------------------------------------------------------------- end Matterhorn ---