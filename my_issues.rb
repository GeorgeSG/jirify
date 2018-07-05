require 'jira-ruby'
require 'colorize'

require_relative 'jira_config.rb'

def print_my_issues(verbose, chosen_status, all = false)
  client = JIRA::Client.new(JiraConfig::CLIENT_OPTIONS)
  project = JiraConfig::OPTIONS['project']
  all_clause = "AND sprint in openSprints() " unless all
  my_issues = client.Issue.jql("project='#{project}' #{all_clause}AND assignee='#{JiraConfig::OPTIONS["username"]}'")

  my_issues.sort_by! { |issue| issue.status.name }
  my_issues.each do |issue|
    status = issue.status.name

    next if chosen_status && chosen_status != status

    status_justified = "(#{status})".rjust(14)
    status_colorized = case status
      when "Done" then status_justified.green
      when "In Progress" then status_justified.blue
      when "In Review" then status_justified.yellow
      when "Closed" then status_justified.black
      else status_justified
    end

    if verbose
      print "#{status_colorized} #{issue.key.ljust(7)}: #{issue.summary} (#{JiraConfig::ISSUE_BROWSE_URL}#{issue.key})\n"
    else
      print "#{issue.key.ljust(7)}: (#{JiraConfig::ISSUE_BROWSE_URL}#{issue.key})\n"
    end
  end
end
