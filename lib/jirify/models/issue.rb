module Jirify
  class Issue < Base
    def mine?
      !assignee.nil? && assignee.emailAddress == Config.username
    end

    def status
      @status ||= Jirify::Status.new @entity.status
    end

    def todo?
      status.name == Config.statuses['todo']
    end

    def status?(status_name)
      status.name == status_name
    end

    def start!
      puts "starting #{summary}..."
      # @issue.save! status: Status.in_progress
    end

    def close!
      puts "closing #{summary}..."
      # @issue.save! status: Status.closed
    end

    def print(verbose)
      url = "#{Config.issue_browse_url}#{key}".blue

      if verbose
        puts "#{status.pretty_name} #{key.ljust(7)}: #{summary} (#{url})"
      else
        puts "#{key.ljust(7)}: (#{url})"
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
      end

      protected

      def my_issues_jql(all_issues)
        all_clause = 'AND sprint in openSprints()' unless all_issues
        "project='#{project}' #{all_clause} AND assignee='#{Config.username}'"
      end
    end
  end
end
