require 'nokogiri'


# ======================================================================= Matterhorn::DublinCore ===


# <?xml version="1.0"?>
# <dublincore xmlns="http://www.opencastproject.org/xsd/1.0/dublincore/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
#   xsi:schemaLocation="http://www.opencastproject.org http://www.opencastproject.org/schema.xsd" xmlns:dc="http://purl.org/dc/elements/1.1/"
#   xmlns:dcterms="http://purl.org/dc/terms/" xmlns:oc="http://www.opencastproject.org/matterhorn/">
#   <dcterms:title xml:lang="en">
#     Land and Vegetation: Key players on the Climate Scene
#     </dcterms:title>
#   <dcterms:subject>
#     climate, land, vegetation
#     </dcterms:subject>
#   <dcterms:description xml:lang="en">
#     Introduction lecture from the Institute for
#     Atmospheric and Climate Science.
#     </dcterms:description>
#   <dcterms:publisher>
#     ETH Zurich, Switzerland
#     </dcterms:publisher>
#   <dcterms:identifier>
#     10.0000/5819
#     </dcterms:identifier>
#   <dcterms:modified xsi:type="dcterms:W3CDTF">
#     2007-12-05
#     </dcterms:modified>
#   <dcterms:format xsi:type="dcterms:IMT">
#     video/x-dv
#     </dcterms:format>
#   <oc:promoted>
#     true
#   </oc:promoted>
# </dublincore>
#
#
class Matterhorn::DublinCore
 
  # -------------------------------------------------------------------------- const definitions ---

  NS = {
    'xmlns'              => "http://www.opencastproject.org/xsd/1.0/dublincore/",
    'xmlns:xsi'          => "http://www.w3.org/2001/XMLSchema-instance",
    'xsi:schemaLocation' => "http://www.opencastproject.org http://www.opencastproject.org/schema.xsd",
    'xmlns:dc'           => "http://purl.org/dc/elements/1.1/",
    'xmlns:dcterms'      => "http://purl.org/dc/terms/",
    'xmlns:oc'           => "http://www.opencastproject.org/matterhorn/"
  }


  # ----------------------------------------------------------------------------- initialization ---

  def initialize(xml = nil)
    if !xml.nil?
      @document = Nokogiri::XML(xml)
    else
      @document = Nokogiri::XML::Builder.new do |xml|
        xml.dublincore(NS) do
        end
      end
      .doc
    end
  end


  # ----------------------------------------------------------------------------------- methodes ---

  def document
    @document
  end

  
  def dcterms_title
    get_value('title', 'dcterms')
  end


  def dcterms_title=(title)
    set_value('title', title, 'dcterms')
  end


  def dcterms_creator
    get_value('creator', 'dcterms')
  end


  def dcterms_creator=(creator)
    set_value('creator', creator, 'dcterms')
  end


  def dcterms_contributor
    get_value('contributor', 'dcterms')
  end


  def dcterms_contributor=(contributor)
    set_value('contributor', contributor, 'dcterms')
  end


  def dcterms_subject
    get_value('subject', 'dcterms')
  end


  def dcterms_subject=(subject)
    set_value('subject', subject, 'dcterms')
  end


  def dcterms_language
    get_value('language', 'dcterms')
  end


  def dcterms_language=(language)
    set_value('language', language, 'dcterms')
  end


  def dcterms_license
    get_value('license', 'dcterms')
  end


  def dcterms_license=(license)
    set_value('license', license, 'dcterms')
  end


  def dcterms_description
    get_value('description', 'dcterms')
  end


  def dcterms_description=(description)
    set_value('description', description, 'dcterms')
  end


  def save(file)
    File.open(file, 'w') do |file|
      file.write(@document.to_xml)
    end
  end


  def to_xml
    @document.to_xml
  end


  # ------------------------------------------------------------------------------------ helpers ---

  def get_ns(ns)
    @document.root.namespace_definitions.find { |n| n.prefix == ns }
  end


  def get_value(key, ns = nil)
    elem = @document.xpath("/*/#{ns.nil? ? '' : ns + ':'}#{key}").first
    return nil    if elem.nil?
    elem.content
  end


  def set_value(key, value, ns = nil)
    if !(elem = @document.at_xpath("/*/#{ns}:#{key}")).nil?
      elem.content = value
    else
      elem = Nokogiri::XML::Element.new(key, @document)
      elem.content = value
      elem.namespace = get_ns(ns)    unless ns.nil?
      @document.root << elem
    end
    elem.content
  end


  def add_value(key, value, ns = nil)
    sibling = @document.xpath("/*/#{ns}:#{key}").last
    elem = Nokogiri::XML::Element.new(key, @document)
    elem.content = value
    elem.namespace = get_ns(ns)    unless ns.nil?
    if !sibling.nil?
      sibling.after(elem)
    else
      @document.root << elem
    end
    elem.content
  end

  
  def inspect
    to_xml.to_s
  end


end # --------------------------------------------------------------- end Matterhorn::DublinCore ---
