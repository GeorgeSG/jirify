module Jirify
  module Models
    class TransitionList < Base
      attr_accessor :list

      def initialize(list)
        @list = list
      end

      def find_by_name(name)
        @list.find { |transition| transition.name == name }
      end

      def names
        @list.map(&:name)
      end

      Config.transitions.keys.each do |transition_name|
        define_method(transition_name.to_sym) do
          find_by_name Config.transitions[transition_name]
        end
      end

      class << self
        def all(issue)
          TransitionList.new client.Transition.all(issue: issue)
        end
      end
    end
  end
end
