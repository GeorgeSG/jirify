require 'colorize'

module Jirify
  class Issue < Base
    class << self
      def mine(verbose, statuses = [], all = false)
        all_clause = 'AND sprint in openSprints()' unless all
        my_issues = client.Issue.jql("project='#{project}' #{all_clause} AND assignee='#{Config.username}'")

        my_issues.sort_by! { |issue| issue.status.name }
        my_issues.each do |issue|
          status = issue.status.name
          next if statuses.any? && !statuses.include?(status)

          print_issue(issue, verbose)
        end
      end

      def find_by_id(issue_id)
        client.Issue.find(issue_id)
      end

      def start(issue)
        puts "starting #{issue.summary}..."
        puts '... to be implemented ...'
      end

      protected

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

        if verbose
          puts "#{status_colorized} #{issue.key.ljust(7)}: #{issue.summary} (#{Config.issue_browse_url}#{issue.key})"
        else
          puts "#{issue.key.ljust(7)}: (#{Config.issue_browse_url}#{issue.key})"
        end
      end
    end
  end
end
