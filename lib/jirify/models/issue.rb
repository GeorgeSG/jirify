require 'colorize'

module Jirify
  class Issue < Base
    def initialize(issue)
      @issue = issue
    end

    def mine?
      !@issue.assignee.nil? && @issue.assignee.emailAddress == Config.username
    end

    def todo?
      @issue.status.name == Config.statuses['todo']
    end

    def start!
      puts "starting #{@issue.summary}..."
      # @issue.save! status: Status.in_progress
    end

    def close!
      puts "closing #{@issue.summary}..."
      # @issue.save! status: Status.closed
    end

    class << self
      def list_mine(verbose, statuses = [], all = false)
        my_issues = client.Issue.jql my_issues_jql(all)
        my_issues.sort_by! { |issue| issue.status.name }

        my_issues.each do |issue|
          status = issue.status.name
          next if statuses.any? && !statuses.include?(status)

          print_issue(issue, verbose)
        end
      end

      def find_by_id(issue_id)
        Issue.new client.Issue.find(issue_id)
      end

      protected

      def my_issues_jql(all_issues)
        all_clause = 'AND sprint in openSprints()' unless all_issues
        "project='#{project}' #{all_clause} AND assignee='#{Config.username}'"
      end

      def print_issue(issue, verbose)
        status = issue.status.name
        status_justified = "(#{status})".rjust(14)
        status_colorized = case status
                           when 'Done'        then status_justified.green
                           when 'In Progress' then status_justified.blue
                           when 'In Review'   then status_justified.yellow
                           when 'Closed'      then status_justified.black
                           else                    status_justified
                           end

        key = issue.key.ljust(7)
        url = "#{Config.issue_browse_url}#{issue.key}"

        if verbose
          puts "#{status_colorized} #{key}: #{issue.summary} (#{url})"
        else
          puts "#{key}: (#{url})"
        end
      end
    end
  end
end
