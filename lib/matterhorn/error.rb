module Matterhorn

# --- Matterhorn Exceptions ------------------------------------------------------------------------

  class Matterhorn::Error < StandardError
  end
  
  class Matterhorn::HttpClientError < Matterhorn::Error
  end
  
  class Matterhorn::HttpServerError < Matterhorn::Error
  end


end
