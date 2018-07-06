module Jirify
  class Base
    class << self
      def client
        @client ||= JIRA::Client.new(Config.client_options)
      end

      def project
        @project ||= Config.options['project']
      end
    end
  end
end
