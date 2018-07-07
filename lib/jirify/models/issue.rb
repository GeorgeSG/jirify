require 'colorize'

module Jirify
  class Issue < Base
    def initialize(issue)
      @issue = issue
    end

    def mine?
      !assignee.nil? && assignee.emailAddress == Config.username
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
      status_justified = "(#{status.name})".rjust(14)
      status_colorized = case status.name
                         when 'Done'        then status_justified.green
                         when 'In Progress' then status_justified.blue
                         when 'In Review'   then status_justified.yellow
                         when 'Closed'      then status_justified.black
                         else                    status_justified
                         end

      url = "#{Config.issue_browse_url}#{key}"

      if verbose
        puts "#{status_colorized} #{key.ljust(7)}: #{summary} (#{url})"
      else
        puts "#{key.ljust(7)}: (#{url})"
      end
    end

    def method_missing(method, *args, &_block)
      if @issue.respond_to? method
        @issue.send method, *args
      else
        super
      end
    end

    def respond_to_missing?(method, *)
      @issue.respond_to? method
    end

    class << self
      def list_mine(verbose, statuses = [], all = false)
        my_issues = find_mine(all).sort_by { |issue| issue.status.name }

        my_issues.select! do |issue|
          statuses.empty? || statuses.any? { |status| issue.status? status }
        end

        my_issues.each { |issue| issue.print verbose }
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
