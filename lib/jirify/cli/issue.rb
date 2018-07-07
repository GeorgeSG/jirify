module Jirify
  class CLI < Thor
    desc 'mine', 'List all of the issues assigned to you in the current sprint'
    method_option :in_progress, type: :boolean, aliases: '-i', desc: 'Show only issues in progress'
    method_option :in_review, type: :boolean, aliases: '-r', desc: 'Show only issues in review'
    method_option :closed, type: :boolean, aliases: '-c', desc: 'Show only closed issues'
    method_option :todo, type: :boolean, aliases: '-t', desc: 'Show only issues in todo'
    method_option :all,
                  type: :boolean,
                  aliases: '-a',
                  desc: 'Show all assigned issues in Project - not limited to sprint'
    method_option :status,
                  banner: '<status>',
                  type: :string,
                  aliases: '-s',
                  desc: 'Show only issues with the specified status'
    method_option :statuses,
                  banner: '<statuses>',
                  type: :array,
                  desc: 'Show only issues with the specified statuses'
    def mine
      if options[:status]
        statuses = [options[:status]]
      else
        statuses = []
        statuses << 'To Do' if options[:todo]
        statuses << 'In Progress' if options[:in_progress]
        statuses << 'In Review' if options[:in_review]
        statuses << 'Closed' if options[:closed]
      end

      Jirify::Issue.mine(options[:verbose], statuses, options[:all])
    end

    desc 'start ISSUE', 'Start an issue that\'s currently To Do'
    def start(issue_id)
      issue = Jirify::Issue.find_by_id(issue_id)

      if issue.assignee.emailAddress != Config.username
        exit(0) unless yes? 'WARNING! This ticket is not assigned to you! Are you sure you want to continue? [Y/n]:'
      end

      if issue.status.name != 'To Do'
        exit(0) unless yes? 'WARNING! This issue is not in status "To Do"! Are you sure you want to continue? [Y/n]:'
      end

      Jirify::Issue.start(issue)
    rescue JIRA::HTTPError
      puts "Unable to find issue #{issue_id}."
    end
  end
end
