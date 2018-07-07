require 'thor'
require 'jira-ruby'
require 'colorize'

require 'jirify/config'
require 'jirify/models/base'
require 'jirify/models/status'
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

    desc "project SUBCOMMAND", "Work with JIRA Projects"
    subcommand "project", Subcommands::Project
  end
end
