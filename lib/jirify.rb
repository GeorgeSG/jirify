require 'thor'
require 'jira-ruby'
require 'colorize'

require 'jirify/version'
require 'jirify/config'
require 'jirify/monkey_patches/jira_issue'

require 'jirify/models/base'
require 'jirify/models/status'
require 'jirify/models/transition_list'
require 'jirify/models/issue'
require 'jirify/models/sprint'
require 'jirify/models/project'

require 'jirify/ui/sprint_cell'
require 'jirify/ui/sprint_table'

require 'jirify/cli/setup'
require 'jirify/cli/sprint'
require 'jirify/cli/issue'
require 'jirify/cli/project'

module Jirify
  class CLI < Thor
    class_option :verbose, type: :boolean, aliases: '-v', desc: 'Show more verbose information'

    desc 'version', 'Prints Jirify version'
    def version
      puts "Current Jirify version: #{VERSION}"
    end

    desc 'setup [SUBCOMMAND]', 'Jirify setup tools'
    subcommand 'setup', Subcommands::Setup

    desc 'i [SUBCOMMAND]', 'Alias for <jira issues>'
    subcommand 'i', Subcommands::Issues

    desc 'issues [SUBCOMMAND]', 'Work with JIRA Issues'
    subcommand 'issues', Subcommands::Issues

    desc 'projects [SUBCOMMAND]', 'Work with JIRA Projects'
    subcommand 'projects', Subcommands::Projects
  end
end
