module Jirify
  module Models
    class ProjectList < BaseList
      def initialize(list)
        @list = list.map { |project| Project.new project }
      end

      def find_by_name(name)
        find { |project| project.name == name }
      end

      def keys
        map &:key
      end

      def names
        map &:name
      end

      class << self
        def all
          ProjectList.new client.Project.all
        end
      end
    end
  end
end
