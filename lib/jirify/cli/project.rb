module Jirify
  module Subcommands
    class Projects < Thor
      default_task :list

      desc 'list', 'List all projects'
      def list
        projects = Models::ProjectList.all
        longest_key = projects.keys.map(&:size).max

        projects.each do |project|
          key = "#{project.key}:".ljust(longest_key + 1)
          say "#{key} #{project.name}"
        end
      end
    end
  end
end
