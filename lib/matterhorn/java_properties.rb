require 'nokogiri'


# =================================================================== Matterhorn::JavaProperties ===

class Matterhorn::JavaProperties
 
  # -------------------------------------------------------------------------- const definitions ---


  # ----------------------------------------------------------------------------------- methodes ---

  def self.write(hash, path, options = {})
    xml = generate_xml(hash, options)
    MatterhornWhymper.logger.warn { "xml = #{xml}" }
    File.write(path, generate_xml(hash, options))
  end


  def self.generate_xml(hash, options = {})
    Nokogiri::XML::Builder.new do |xml|
      xml.doc.create_internal_subset('properties', nil, 'http://java.sun.com/dtd/properties.dtd')
      xml.properties do
        xml.comment_(options[:comment])    unless options[:comment].nil?
        hash.each_pair do |key, value|
          if options[:cdata] && options[:cdata].include?(key)
            xml.entry(:key => key) do
              xml.cdata(value)
            end
          else
            xml.entry(value, :key => key)
          end
        end
      end
    end.doc.to_xml
  end


end # ----------------------------------------------------------- end Matterhorn::JavaProperties ---
