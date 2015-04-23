require 'nokogiri'


# =================================================================================== Matterhorn ===

module Matterhorn


  # ============================================================================ Matterhorn::Acl ===

  # <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
  # <acl xmlns="http://org.opencastproject.security">
  #   <ace>
  #     <role>admin</role>
  #     <action>delete</action>
  #     <allow>true</allow>
  #   </ace>
  # </acl>
  #
  #
  class Acl

    attr_accessor :aces


    # ===================================================================== Matterhorn::Acl::Ace ===
  
    class Ace

      attr_accessor :role, :action, :allow

      def initialize(role = nil, action = nil, allow = true)
        @role = role
        @action = action
        @allow = allow
      end

    end # ------------------------------------------------------------- end Matterhorn::Acl::Ace ---
   

    # ------------------------------------------------------------------------ const definitions ---

    NS = {
      'xmlns' => "http://org.opencastproject.security",
    }


    # --------------------------------------------------------------------------- initialization ---
  
    def initialize(xml = nil)
      if !xml.nil?
        doc = Nokogiri::XML(xml)
        @aces = []
        doc.xpath("/ace").each do |ace_elem|
          ace = Ace.new
          ace = ace_elem.at_xpath("/role").content
          ace = ace_elem.at_xpath("/action").content
          ace = ace_elem.at_xpath("/allow").content
          @aces << ace
        end
      else
        @aces = []
      end
    end

  
    # --------------------------------------------------------------------------------- methodes ---

    def save(file)
      File.open(file, 'w') do |file|
        file.write(to_xml)
      end
    end


    def to_xml
      Nokogiri::XML::Builder.new do |xml|
        xml.acl(NS) do
          @aces.each do |ace|
            xml.ace do 
              xml.role(ace.role)
              xml.action(ace.action)
              xml.allow(ace.allow)
            end
          end
        end
      end.doc.to_xml
    end


  end # -------------------------------------------------------------------- end Matterhorn::Acl ---


end # --------------------------------------------------------------------------- end Matterhorn ---