module Jirify
  class CLI < Thor
    desc 'setup', 'A guided setup for jirify'
    def setup
      say 'Welcome! This will guide you through the configuration of the jirify CLI tool.'

      if Config.initialized?
        exit(0) unless yes? 'You seem to have already configured jirify.\n' \
          'Do you want to continue and overwrite the current configuration? [Y/n]:'
      end

      username      = ask 'Enter username:'
      token         = ask 'Enter token (generate from https://id.atlassian.com):'
      site          = ask 'Enter JIRA url:'
      project       = ask 'Enter JIRA Project key:'
      filter_labels = ask 'Enter a comma-separated list of labels to filter by every time (optional):'

      labels = filter_labels.split ', ' if filter_labels

      options = {
        'options' => {
          'username' => username,
          'token'    => token,
          'site'     => site,
          'project'  => project
        }
      }

      options['options']['filter_by_labels'] = labels unless labels.empty?

      Config.write(options)
    end
  end
end
