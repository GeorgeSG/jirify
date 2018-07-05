require 'jira-ruby'
require 'colorize'
require 'terminal-table'
require 'json'

require_relative 'jira_config.rb'

def print_current_sprint(verbose = false, all_columns = false, only_mine = false)
  client = JIRA::Client.new(JiraConfig::CLIENT_OPTIONS)

  project = JiraConfig::OPTIONS['project']

  labels = JiraConfig::OPTIONS['filter_by_labels']
  labels = labels.join(", ") if labels

  labels_clause = "AND labels in (#{labels})" if labels
  mine_clause = "AND assignee='#{JiraConfig::OPTIONS["username"]}'" if only_mine

  issues = client.Issue.jql("project='#{project}' AND sprint in openSprints() #{labels_clause} #{mine_clause}", { max_results: 200 })

  if all_columns
    grouped_issues = issues.group_by { |issue| issue.status.name }
  else
    grouped_issues = issues.group_by { |issue| issue.status.statusCategory['name'] }
  end

  all_groups = grouped_issues.values

  l = all_groups.map(&:length).max
  transposed = all_groups.map{ |e| e.values_at(0...l) }.transpose

  transposed = transposed.map do |row|
    row.map do |issue|
      if issue
        key = issue.key.ljust(7)
        url = "(#{JiraConfig::ISSUE_BROWSE_URL}/#{issue.key})".blue
        summary = "#{issue.summary[0, 35]}...\n" if verbose
        "#{key}: #{summary}#{url}"
      else
        ""
      end
    end
  end

  table = Terminal::Table.new headings: grouped_issues.keys, rows: transposed

  puts table
end
