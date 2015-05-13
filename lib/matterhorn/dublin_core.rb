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

  
  def save(file)
    File.open(file, 'w') do |file|
      file.write(@document.to_xml)
    end
  end


  def to_xml
    @document.to_xml
  end


  def inspect
    to_xml.to_s
  end


  def method_missing(method, *args, &block)
    # analyse mehtod
    splitted_method = method.to_s.split('_')
    if splitted_method.first == 'add'
      method_name = :add_value
      splitted_method.shift
    elsif splitted_method.first == 'list'
      method_name = :list_value
      splitted_method.shift
    elsif splitted_method.last.end_with?('=')
      method_name = :set_value
      splitted_method.last.chop!
    else
      method_name = :get_value
    end

    # namespace, key and value
    namespace = if !get_ns(splitted_method.first).nil?
                  splitted_method.shift
                else
                  'xmlns'
                end
    key       = splitted_method.join('_')
    value     = args[0]
    MatterhornWhymper.logger.debug { "#{self.class.name}#method_missing | " +
                                     "method: #{method_name.to_s}; namespace: #{namespace}; " +
                                     "key: #{key}; value: #{value.to_s}" }

    # call method
    params = case method_name
             when :get_value then [namespace, key]
             when :set_value then [namespace, key, args[0].to_s]
             when :add_value then [namespace, key, args[0].to_s]
             end
    send(method_name, *params)
  end  


  # ------------------------------------------------------------------------------------ helpers ---

  def get_ns(ns)
    @document.root.namespace_definitions.find { |n| n.prefix == ns }
  end


  def get_value(ns, key)
    elem = @document.xpath("/xmlns:dublincore/#{ns}:#{key}").first
    return nil    if elem.nil?
    elem.content
  end


  def set_value(ns, key, value)
    if !(elem = @document.at_xpath("/xmlns:dublincore/#{ns}:#{key}")).nil?
      elem.content = value
    else
      elem = Nokogiri::XML::Element.new(key, @document)
      elem.content = value
      elem.namespace = get_ns(ns)    unless ns.nil?
      @document.root << elem
    end
    elem.content
  end


  def add_value(ns, key, value)
    sibling = @document.xpath("/xmlns:dublincore/#{ns}:#{key}").last
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

  
end # --------------------------------------------------------------- end Matterhorn::DublinCore ---
