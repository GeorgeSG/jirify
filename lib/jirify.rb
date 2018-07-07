require 'thor'
require 'jira-ruby'
require 'colorize'

require 'jirify/config'
require 'jirify/models/base'
require 'jirify/models/status'
require 'jirify/models/transition_list'
require 'jirify/models/issue'
require 'jirify/models/sprint'
require 'jirify/models/project'
require 'jirify/cli/setup'
require 'jirify/cli/sprint'
require 'jirify/cli/issue'
require 'jirify/cli/project'

module Jirify
  class CLI < Thor
    class_option :verbose, type: :boolean, aliases: '-v', desc: 'Show more verbose information'

    desc 'issues SUBCOMMAND', 'Work with JIRA Issues'
    subcommand 'issues', Subcommands::Issues

    desc 'i SUBCOMMAND', 'Work with JIRA Issues'
    subcommand 'i', Subcommands::Issues

    desc 'projects SUBCOMMAND', 'Work with JIRA Projects'
    subcommand 'projects', Subcommands::Projects
  end
end
