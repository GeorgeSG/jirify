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
        project       = ask 'Enter a comma-separated list of JIRA Project keys to filter by every time (1 required):'
        filter_labels = ask 'Enter a comma-separated list of labels to filter by every time (optional):'

        labels = filter_labels.split ', ' if filter_labels
        projects = project.split ', ' if project

        if projects.nil? or projects.empty?
          say "You must enter at least one project key!".red
          exit(0)
        end

        options = {
          'options' => {
            'username' => username,
            'token'    => token,
            'site'     => site,
            'projects'  => projects
          }
        }

        options['options']['filter_by_labels'] = labels unless labels.empty?

        Config.write(options)

        say 'Done!'.green
        say "If you want to enable bash completion, source #{Config.config_folder}/jirify.bash_completion.sh"
      end

      desc 'verbose', 'Set always verbose to true or false'
      method_option :enable, type: :boolean, aliases: '-e', default: false, desc: 'Enable or Disable'
      def verbose
        Config.verbose = options[:enable]
      end

      desc 'bash_completion', 'Update your bash_completion file when a new version comes out'
      def bash_completion
        say "Updating #{Config.config_folder}/jirify.bash_completion.sh ...".blue
        Config.copy_bash_completion!

        say 'Done! You have to source the file again or open a new shell! :)'.green
      end

      desc 'projects', 'Set projects to query'
      method_option :set, type: :array, aliases: '-s', desc: 'List of projects'
      def projects
        if options[:set].nil? || options[:set].empty?
          say 'Pass a list of projects to set with -s. Run "jira setup help projects" for more information.'.red
          exit(0)
        end

        Config.projects = options[:set]
      end

      desc 'bash_completion', 'Update your bash_completion file when a new version comes out'
      def bash_completion
        say "Updating #{Config.config_folder}/jirify.bash_completion.sh ...".blue
        Config.copy_bash_completion!

        say 'Done! You have to source the file again or open a new shell! :)'.green
      end
    end
  end
end
