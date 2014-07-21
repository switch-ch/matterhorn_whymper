module Support
  module RemoteHelpers
    def self.included(context)
      context.before do
        MatterhornWhymper.logger.level = Logger::DEBUG
        WebMock.allow_net_connect!
      end

      context.after do
        WebMock.disable_net_connect!
        MatterhornWhymper.logger.level = Logger::WARN
      end
    end
  end
end