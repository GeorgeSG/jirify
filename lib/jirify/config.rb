require 'yaml'
require 'fileutils'

module Jirify
  class Config
    class << self
      CONFIG_FOLDER = "#{Dir.home}/.jirify".freeze
      CONFIG_FILE   = "#{CONFIG_FOLDER}/.jirify".freeze

      def config_folder
        initialize! unless initialized?
        @config_folder ||= CONFIG_FOLDER
      end

      def config_file
        initialize! unless initialized?
        @config_file ||= CONFIG_FILE
      end

      def initialized?
        File.directory?(CONFIG_FOLDER) && File.exist?(CONFIG_FILE)
      end

      def initialize!
        FileUtils::mkdir_p CONFIG_FOLDER
        FileUtils::touch CONFIG_FILE
        FileUtils::cp "#{File.expand_path('..', File.dirname(__dir__))}/jirify.bash_completion.sh", CONFIG_FOLDER
      end

      def write(config)
        puts 'Writing config:'
        puts config.to_yaml

        File.write(config_file, config.to_yaml)
      end

      def verbose=(value)
        unless initialized?
          puts 'ERROR: You must initialize Jirify first!'.red
          exit(0)
        end

        config = YAML.load_file(config_file)
        config['options']['verbose'] = value
        write(config)
      end

      def options
        unless initialized?
          puts 'ERROR: You must initialize Jirify first!'.red
          exit(0)
        end

        @options ||= YAML.load_file(config_file)['options']
      end

      def always_verbose
        options['verbose']
      end

      def atlassian_url
        options['site']
      end

      def username
        options['username']
      end

      def issue_browse_url
        "#{atlassian_url}/browse/"
      end

      def statuses
        default = {
          'blocked'     => 'Blocked',
          'todo'        => 'To Do',
          'in_progress' => 'In Progress',
          'in_review'   => 'In Review',
          'done'        => 'Closed'
        }

        if initialized?
          options['statuses'] || default
        else
          default
        end
      end

      def transitions
        default = {
          'block'        => 'Blocked',
          'unblock'      => 'Unblock',
          'start'        => 'Start Progress',
          'stop'         => 'Stop Progress',
          'start_review' => 'Code Review',
          'stop_review'  => 'Back to In Progress',
          'close'        => 'Close',
          'reopen'       => 'Reopen'
        }

        if initialized?
          options['transitions'] || default
        else
          default
        end
      end

      def client_options
        {
          username:     options['username'],
          password:     options['token'],
          site:         atlassian_url,
          context_path: '',
          auth_type:    :basic
        }
      end
    end
  end
end
