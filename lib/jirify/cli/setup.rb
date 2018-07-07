module Jirify
  module Subcommands
    class Setup < Thor
      default_task :init

      desc 'init', 'A guided setup for jirify'
      def init
        say 'Welcome! This will guide you through the configuration of the jirify CLI tool.'

        if Config.initialized?
          exit(0) unless yes? 'You seem to have already configured jirify. ' \
            'Do you want to continue and overwrite the current configuration? [Y/n]:'.yellow
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

        say "Done!"
        say "If you want to enable bash completion, source #{Config.config_folder}/jirify.bash_completion.sh"
      end

      desc 'verbose', 'Set always verbose to true or false'
      method_option :enable, type: :boolean, aliases: '-e', default: false, desc: 'Enable or Disable'
      def verbose
        Config.verbose = options[:enable]
      end
    end
  end
end
