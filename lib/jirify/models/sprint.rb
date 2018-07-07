require 'colorize'
require 'terminal-table'
require 'json'

module Jirify
  class Sprint < Base
    class << self
      def current(verbose = false, all_columns = false, only_mine = false)
        issues = client.Issue.jql current_sprint_jql(only_mine), max_results: 200

        grouped_issues = issues.group_by do |issue|
          all_columns ? issue.status.name : issue.status.statusCategory['name']
        end

        print_grouped_issues_as_table(grouped_issues, verbose)
      end

      protected

      def current_sprint_jql(only_mine)
        labels = Config.options['filter_by_labels']
        labels = labels.join(', ') if labels

        labels_clause = "AND labels in (#{labels})" if labels
        mine_clause   = "AND assignee='#{Config.username}'" if only_mine
        sprint_clause = 'AND sprint in openSprints()'

        "project='#{project}' #{sprint_clause} #{labels_clause} #{mine_clause}"
      end

      def print_grouped_issues_as_table(grouped_issues, verbose)
        all_groups = grouped_issues.values

        l = all_groups.map(&:length).max
        transposed = all_groups.map { |e| e.values_at(0...l) }.transpose

        transposed = transposed.map do |row|
          row.map do |issue|
            if issue
              key     = issue.key.ljust(7)
              url     = "(#{Config.issue_browse_url}/#{issue.key})".blue
              summary = "#{issue.summary[0, 35]}...\n" if verbose

              "#{key}: #{summary}#{url}"
            else
              ''
            end
          end
        end

        puts Terminal::Table.new headings: grouped_issues.keys, rows: transposed unless transposed.empty?
      end
    end
  end
end
