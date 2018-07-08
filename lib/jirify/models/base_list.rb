module Jirify
  module Models
    class BaseList < Base
      include Enumerable

      attr_reader :list

      def each(&block)
        list.each(&block)
      end
    end
  end
end
