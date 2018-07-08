require 'terminal-table'
require 'json'

module Jirify
  class Sprint < Base
    class << self
      def current(verbose = false, all_columns = false, only_mine = false)
        issues = client.Issue.jql current_sprint_jql(only_mine), max_results: 200
        SprintTable.new(issues).to_table(all_columns, verbose)
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
    end
  end
end
