module Jirify
  module Subcommands
    class Projects < Thor
      desc 'list', 'List all projects'
      def list
        puts Jirify::Project.all.map(&:name)
      end

      default_task :list
    end
  end
end
