require 'nokogiri'

module Matterhorn

  class WorkflowInstance

    XML_NS_WORKFLOW = "http://workflow.opencastproject.org"
  
    # --- const definitions ------------------------------------------------------
  
    # --- attributes -------------------------------------------------------------
  
    # --- validations ------------------------------------------------------------
  
    # --- callback declarations --------------------------------------------------
  
  
    # --- relations --------------------------------------------------------------
  
  
    # --- initialization ---------------------------------------------------------
  
    def initialize(xml)
      @document = Nokogiri::XML(xml)
    end
  
    # --- methodes ---------------------------------------------------------------

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

  
    # ========================================================================== #
    # === protected section                                                  === #
    # ========================================================================== #
    protected
  
  
    # ========================================================================== #
    # === private section                                                    === #
    # ========================================================================== #
    private
  
  end

end