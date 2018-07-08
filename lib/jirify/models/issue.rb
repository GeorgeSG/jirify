module Jirify
  module Models
    class Issue < Base
      class InvalidTransitionError < StandardError; end

      def mine?
        !assignee.nil? && assignee.emailAddress == Config.username
      end

      def assign_to_me!
        @entity.assign_to!(Config.username.split('@')[0])
      end

      def unassign!
        @entity.assign_to!(nil)
      end

      def status
        @status ||= Status.new @entity.status
      end

      def status?(status_name)
        status_name = status_name.to_s if status_name.is_a? Symbol
        status.name == status_name
      end

      Config.statuses.keys.each do |status_key|
        define_method "#{status_key.to_sym}?" do
          status.name == Config.statuses[status_key]
        end
      end

      def transitions(reload = false)
        if reload
          @transitions = TransitionList.all @entity
        else
          @transitions ||= TransitionList.all @entity
        end
      end

      Config.transitions.keys.each do |transition_name|
        define_method "#{transition_name}!".to_sym do
          transition = transitions(true).send(transition_name.to_sym)

          if transition.nil?
            puts ColorizedString["  ERROR: Issue can't be transitioned with \"#{transition_name}\"  "]
              .white.on_red.bold
            exit(0)
          end

          puts "Transitioning #{key} with \"#{transition_name}\"...".green
          @entity.transition! transition
        end
      end

      def to_s(verbose)
        url = ColorizedString["#{Config.issue_browse_url}#{key}"].blue.underline
        bold_key = ColorizedString["#{key.ljust(7)}:"].bold

        if verbose
          "#{status.pretty_name} #{bold_key} #{summary} (#{url})"
        else
          "#{bold_key} #{url}"
        end
      end

      class << self
        def list_mine(statuses = [], all = false)
          my_issues = find_mine(all).sort_by { |issue| issue.status.name }

          my_issues.select do |issue|
            statuses.empty? || statuses.any? { |status| issue.status? status }
          end
        end

        def find_mine(all)
          client.Issue.jql(my_issues_jql(all)).map { |issue| Issue.new issue }
        end

        def find_by_id(issue_id)
          Issue.new client.Issue.find(issue_id)
        rescue StandardError
          nil
        end

        protected

        def my_issues_jql(all_issues)
          all_clause = 'AND sprint in openSprints()' unless all_issues
          "project='#{project}' #{all_clause} AND assignee='#{Config.username}'"
        end
      end
    end
  end
end
