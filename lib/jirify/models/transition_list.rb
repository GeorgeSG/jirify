module Jirify
  class TransitionList < Base
    attr_accessor :list

    def initialize(list)
      @list = list
    end

    def names
      @list.map(&:name)
    end

    Config.transitions.keys.each do |transition_name|
      define_method(transition_name.to_sym) { find_by_name transition_name }
    end

    protected

    def find_by_name(name)
      @list.find { |transition| transition.name == Config.transitions[name] }
    end

    class << self
      def all(issue)
        TransitionList.new client.Transition.all(issue: issue)
      end
    end
  end
end
