require 'colorize'

module Jirify
  class Issues < Base
    class << self
      def mine(verbose, statuses = [], all = false)
        all_clause = "AND sprint in openSprints() " unless all
        my_issues = client.Issue.jql("project='#{project}' #{all_clause}AND assignee='#{Config.options["username"]}'")

        my_issues.sort_by! { |issue| issue.status.name }
        my_issues.each do |issue|
          status = issue.status.name

          next if statuses.any? && !statuses.include?(status)

          status_justified = "(#{status})".rjust(14)
          status_colorized = case status
            when "Done" then status_justified.green
            when "In Progress" then status_justified.blue
            when "In Review" then status_justified.yellow
            when "Closed" then status_justified.black
            else status_justified
          end

          if verbose
            print "#{status_colorized} #{issue.key.ljust(7)}: #{issue.summary} (#{Config.issue_browse_url}#{issue.key})\n"
          else
            print "#{issue.key.ljust(7)}: (#{Config.issue_browse_url}#{issue.key})\n"
          end
        end
      end
    end
  end
end
