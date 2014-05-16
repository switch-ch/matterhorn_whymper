require 'nokogiri'


# =================================================================================== Matterhorn ===

module Matterhorn

  
  # =========================================================================== Matterhorn::Smil ===

  class Smil
    

    # ------------------------------------------------------------------------------- attributes --- 

    attr_reader :head, :body
  
  
    # --------------------------------------------------------------------------- initialization ---
  
    def initialize()
      @head = Smil::Head.new
      @body = Smil::Body.new
    end
  

    # --------------------------------------------------------------------------------- methodes ---

    def save(smil_file)
      File.open(smil_file, 'w') do |file|
        file.write(self.to_xml)
      end
      Rails.logger.debug { "Matterhorn::Smil::save | Smil description =\n#{self.to_xml}" }
      true
    end


    def to_xml
      doc = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |bx|
      bx.smil('xmlns' => "http://www.w3.org/ns/SMIL") do
        head.to_xml(bx)
        body.to_xml(bx)
      end
      doc.to_xml
    end


  end # ------------------------------------------------------------------- end Matterhorn::Smil ---



  # ===================================================================== Matterhorn::Smil::Head ===

  class Smil::Head

    def to_xml(bx)
      bx.head do
      end
    end


  end # ------------------------------------------------------------- end Matterhorn::Smil::Head ---



  # ===================================================================== Matterhorn::Smil::Body ===

  class Smil::Body


    # ------------------------------------------------------------------------------- attributes ---

    attr_reader :par_list


    # --------------------------------------------------------------------------- initialization ---

    def initialize()
      @par_list = Array.new
    end


    # --------------------------------------------------------------------------------- methodes ---
    
    def add_par()
      par = Smil::Par.new
      @par_list << par
      par
    end


    def to_xml(bx)
      bx.body do
        @par_list.each do |par|
          par.to_xml(bx)
        end
      end
    end


  end # ------------------------------------------------------------- end Matterhorn::Smil::Body ---



  # ================================================================== Matterhorn::Smil::Element ===

  class Smil::Element


    # ------------------------------------------------------------------------------- attributes ---

    attr_reader :start_point, :end_point, :rel_begin, :duration, :parent


    # --------------------------------------------------------------------------- initialization ---

    def initialize(parent = nil)
      @start_point = nil
      @end_point   = nil
      @rel_begin   = nil
      @duration    = nil
      @parent      = parent
    end


    # --------------------------------------------------------------------------------- methodes ---
    
    def attr_list
      attr_list = Hash.new
      if !@rel_begin.nil?
        attr_list[:begin] = "#{(@rel_begin * 1000).round.to_s}ms"
      end
      if !@duration.nil?
        attr_list[:dur] = "#{(@duration * 1000).round.to_s}ms"
      end
      attr_list
    end

    
    # ------------------------------------------------------------------------ protected section ---
    protected

    def start_point=(new_start_point)
      if new_start_point.kind_of? String
        # start_point is an absolut time position and must be in the format 2013-12-02T14:12:42.364
        new_start_point = new_start_point.to_datetime.to_f
      elsif new_start_point.respond_to?('to_f')
        new_start_point = new_start_point.to_f
      else
        new_start_point = nil
      end
      @start_point = new_start_point
    end


    def end_point=(new_end_point)
      if new_end_point.kind_of? String
        # end_point is an absolut time position and must be in the format 2013-12-02T14:12:42.364
        new_end_point = new_end_point.to_datetime.to_f
      elsif new_end_point.respond_to?('to_f')
        new_end_point = new_end_point.to_f
      else
        new_end_point = nil
      end
      @end_point = new_end_point
    end


    def rel_begin=(new_rel_begin)
      if new_rel_begin.kind_of? Fixnum
        new_rel_begin = new_rel_begin / 1000.0
      elsif new_rel_begin.respond_to?('to_f')
        new_rel_begin = new_rel_begin.to_f
      else
        new_rel_begin = nil
      end
      @rel_begin = new_rel_begin
    end


    def duration=(new_duration)
      if new_duration.kind_of? Fixnum
        # duration is in ms
        new_duration = new_duration / 1000
      elsif duration.respond_to?('to_f')
        # duration is in s
        new_duration = new_duration.to_f
      else
        new_duration = nil
      end
      @end_point = start_point + new_duration   if !start_point.nil? && !new_duration.nil?
      @duration = new_duration
    end


    def update(sub_elem)
      if !sub_elem.start_point.nil? && (start_point.nil? || start_point > sub_elem.start_point)
        @start_point = sub_elem.start_point
      else
        # do not update start_point
      end
      
      if !sub_elem.end_point.nil? && (end_point.nil? || end_point < sub_elem.end_point)
        @end_point = sub_elem.end_point
      else
        # do not update start_point
      end

      if !start_point.nil? && !end_point.nil?
        @duration = end_point - start_point
      end
      # update parent if any
      parent.update(self)    if !parent.nil?
      propagate(self)        if parent.nil?
    end


    def propagate(parent_elem)
    end


  end # ---------------------------------------------------------- end Matterhorn::Smil::Element ---



  # ====================================================================== Matterhorn::Smil::Par ===

  class Smil::Par < Smil::Element


    # --------------------------------------------------------------------------- initialization ---

    def initialize()
      super
      @seq_list = Array.new
    end


    # --------------------------------------------------------------------------------- methodes ---
    
    def add_seq
      seq = Smil::Seq.new(self)
      @seq_list << seq
      seq
    end


    def propagate(parent_elem)
      @seq_list.each do |seq|
        seq.propagate(self)
      end
    end


    def to_xml(bx)
      bx.par(attr_list) do
        @seq_list.each do |seq|
          seq.to_xml(bx)
        end
      end
    end


  end # -------------------------------------------------------------- end Matterhorn::Smil::Par ---



  # ====================================================================== Matterhorn::Smil::Seq ===

  class Smil::Seq < Smil::Element


    # --------------------------------------------------------------------------- initialization ---

    def initialize(parent)
      super(parent)
      @track_list = Array.new
    end


    # --------------------------------------------------------------------------------- methodes ---
    
    def attr_list
      attrib_list = super
      attrib_list.delete(:begin)
      attrib_list
    end


    def add_track(kind, file, start_point, duration)
      track = Smil::Track.new(self, kind, file, start_point, duration)
      @track_list << track
      update(track)
      track
    end


    def propagate(parent_elem)
      @rel_begin = start_point - parent_elem.start_point
      @track_list.each do |track|
        # propagate with par element
        track.propagate(parent_elem)
      end
    end


    def to_xml(bx)
      bx.seq(attr_list) do
        @track_list.each do |track|
          track.to_xml(bx)
        end
      end
    end


  end # -------------------------------------------------------------- end Matterhorn::Smil::Seq ---

  

  # ====================================================================================== Track ===

  class Smil::Track < Smil::Element


    # --------------------------------------------------------------------------- initialization ---

    def initialize(parent, kind, file, start_point, duration)
      super(parent)
      @kind = kind
      @src = file
      self.start_point = start_point
      self.duration = duration
    end


    # --------------------------------------------------------------------------------- methodes ---
    
    def propagate(parent_elem)
      @rel_begin = start_point - parent_elem.start_point
    end


    def to_xml(bx)
      attributes = attr_list
      if !@src.nil?
        attributes[:src] = @src.to_s
      end
      bx.tag_(@kind, attributes)
    end


  end # ------------------------------------------------------------ end Matterhorn::Smil::Track ---


end # --------------------------------------------------------------------------- end Matterhorn ---
