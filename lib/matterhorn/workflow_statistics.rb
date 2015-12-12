# =============================================================== Matterhorn::WorkflowStatistics ===

class Matterhorn::WorkflowStatistics

  attr_reader :instantiated, :running, :paused, :stopped, :finished, :failing, :failed, :total

  # -------------------------------------------------------------------------- const definitions ---


  # ----------------------------------------------------------------------------- initialization ---

  def initialize(json)
    @instantiated = json['statistics']['instantiated'].to_i
    @running      = json['statistics']['running'].to_i
    @paused       = json['statistics']['paused'].to_i
    @stopped      = json['statistics']['stopped'].to_i
    @finished     = json['statistics']['finished'].to_i
    @failing      = json['statistics']['failing'].to_i
    @failed       = json['statistics']['failed'].to_i
    @total        = json['statistics']['total'].to_i
  end


  # ----------------------------------------------------------------------------------- methodes ---


end # ------------------------------------------------------- end Matterhorn::WorkflowStatistics ---
