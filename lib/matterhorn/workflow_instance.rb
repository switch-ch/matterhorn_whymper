require 'nokogiri'


# =================================================================================== Matterhorn ===

module Matterhorn


  # =============================================================== Matterhorn::WorkflowInstance ===

  class WorkflowInstance


    # ------------------------------------------------------------------------ const definitions ---

    XML_NS_WORKFLOW = "http://workflow.opencastproject.org"

  
    # --------------------------------------------------------------------------- initialization ---
  
    def initialize(xml)
      @document = Nokogiri::XML(xml)
    end

  
    # --------------------------------------------------------------------------------- methodes ---

    def id
      @document.xpath('/nsw:workflow/@id', {"nsw" => XML_NS_WORKFLOW}).first.value
    end


    def state
      @document.xpath('/nsw:workflow/@state', {"nsw" => XML_NS_WORKFLOW}).first.value
    end


    def template
      @document.xpath('/nsw:workflow/nsw:template', {"nsw" => XML_NS_WORKFLOW}).first.content       
    end


    def to_xml
      @document.to_xml
    end

  
  end # ------------------------------------------------------- end Matterhorn::WorkflowInstance ---


end # --------------------------------------------------------------------------- end Matterhorn ---