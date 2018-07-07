module Jirify
  module Subcommands
    class Project < Thor
      desc "list", "List all projects"
      def list
        puts Jirify::Project.all.map(&:name)
      end
    end
  end
end
