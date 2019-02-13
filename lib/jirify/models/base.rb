module Jirify
  module Models
    class Base
      def initialize(entity)
        @entity = entity
      end

      def method_missing(method, *args, &_block)
        if @entity.respond_to? method
          @entity.send method, *args
        else
          super
        end
      end

      def respond_to_missing?(method, *)
        @entity.respond_to? method
      end

      class << self
        def client
          @client ||= JIRA::Client.new(Config.client_options)
        end
      end
    end
  end
end
