require 'thor'
require 'jira-ruby'

require 'jirify/config'
require 'jirify/cli/setup'
require 'jirify/cli/sprint'
require 'jirify/cli/issue'
require 'jirify/models/base'
require 'jirify/models/issues'
require 'jirify/models/sprint'

module Jirify
  class CLI < Thor
    class_option :verbose, type: :boolean, aliases: '-v', desc: "Show more verbose information"
  end
end
