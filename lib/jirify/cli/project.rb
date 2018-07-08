module Jirify
  module Subcommands
    class Projects < Thor
      default_task :list

      desc 'list', 'List all projects'
      def list
        Models::Project.all.map(&:name).each { |name| say name }
      end
    end
  end
end
