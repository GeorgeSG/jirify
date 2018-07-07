require 'yaml'

module Jirify
  class Config
    class << self
      def initialized?
        File.exist? config_file
      end

      def write(config)
        puts 'Writing config:'
        puts config.to_yaml

        File.write(config_file, config.to_yaml)
      end

      def verbose(value)
        unless initialized?
          puts 'ERROR: You must initialize Jirify first!'.red
          exit(0)
        end

        config = YAML.load_file(config_file)
        config['options']['verbose'] = value
        write(config)
      end

      def config_file
        @config_file ||= "#{Dir.home}/.jirify"
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
        options['statuses'] || {
          'blocked'     => 'Blocked',
          'todo'        => 'To Do',
          'in_progress' => 'In Progress',
          'in_review'   => 'In Review',
          'done'        => 'Closed'
        }
      end

      def transitions
        options['transitions'] || {
          'block'        => 'Blocked',
          'unblock'      => 'Unblock',
          'start'        => 'Start Progress',
          'stop'         => 'Stop Progress',
          'start_review' => 'Code Review',
          'stop_review'  => 'Back to In Progress',
          'close'        => 'Close',
          'reopen'       => 'Reopen'
        }
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
