require 'launchy'

module Jirify
  module Subcommands
    class Issues < Thor
      default_task :mine

      desc 'mine', 'List all of the issues assigned to you in the current sprint'
      method_option :key_only, type: :boolean, aliases: '-k', desc: 'Show only issue keys'
      method_option :in_progress, type: :boolean, aliases: '-i', desc: 'Show only issues in progress'
      method_option :in_review, type: :boolean, aliases: '-r', desc: 'Show only issues in review'
      method_option :closed, type: :boolean, aliases: '-c', desc: 'Show only closed issues'
      method_option :todo, type: :boolean, aliases: '-t', desc: 'Show only issues in todo'
      method_option :blocked, type: :boolean, aliases: '-b', desc: 'Show only blocked issues'
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
        statuses = build_issue_statuses(options)
        issues = Issue.list_mine(statuses, options[:all])
        issues.each do |issue|
          if options[:key_only]
            say issue.key
          else
            say issue.to_s Config.always_verbose || options[:verbose]
          end
        end
      end

      desc 'open [ISSUE]', 'Opens an issue in your browser'
      method_option :force, type: :boolean, aliases: '-f', desc: 'Don\'t check if issue exists'
      def open(issue_id)
        get_issue_or_exit issue_id unless options[:force]
        Launchy.open("#{Config.issue_browse_url}#{issue_id}")
      end

      #-------------------------#
      # Issue Assignee commands #
      #-------------------------#

      desc 'assignee [ISSUE]', 'Display issue assignee'
      def assignee(issue_id)
        issue = get_issue_or_exit issue_id

        if issue.assignee.nil?
          say 'Unassigned'.yellow
        else
          say issue.assignee.name
        end
      end

      desc 'unassign [ISSUE]', 'Unassign an issue'
      def unassign(issue_id)
        issue = get_issue_or_exit issue_id

        if issue.assignee.nil?
          say 'Issue already unassigned'.yellow
          exit(0)
        end

        say "Previous assignee: #{issue.assignee.name}. Unassigning..."
        issue.unassign!
      end

      desc 'take [ISSUE]', 'Assign an issue to you'
      def take(issue_id)
        issue = get_issue_or_exit issue_id

        say "Assigning #{issue.key} to #{Config.username}..."
        issue.assign_to_me!
      end

      #-----------------------#
      # Issue Status commands #
      #-----------------------#

      desc 'status [ISSUE]', 'Display issue status'
      def status(issue_id)
        issue = get_issue_or_exit issue_id

        say "Status: #{issue.status.name}"
      end

      desc 'transitions [ISSUE]', 'Display available transitions'
      def transitions(issue_id)
        issue = get_issue_or_exit issue_id

        say 'Available transitions:'
        issue.transitions.names.each { |name| say name }
      end

      desc 'transition [ISSUE] [TRANSITION]', 'Manually perform a transition'
      def transition(issue_id, transition_name)
        issue = get_issue_or_exit issue_id
        transition = issue.transitions.find_by_name(transition_name)

        if transition.nil?
          say "ERROR: Issue can't transition to #{transition_name}".red
          exit(0)
        end

        say "Transitioning #{issue.key} with #{transition_name}...".green
        issue.transition! transition
      end

      desc 'block [ISSUE]', "Moves an issue to #{Config.statuses['blocked']}"
      def block(issue_id)
        issue = get_issue_or_exit issue_id
        check_assigned_to_self issue

        issue.reopen! if issue.done?
        issue.stop_review! if issue.in_review?
        issue.block!
      end

      desc 'unblock [ISSUE]', 'Unblock an issue'
      def unblock(issue_id)
        issue = get_issue_or_exit issue_id
        check_assigned_to_self issue

        if issue.blocked?
          say 'Unblocking issue...'
          issue.unblock!
        else
          say 'Issue wasn\'t blocked anyway :)'.green
        end
      end

      desc 'todo [ISSUE]', "Move an issue to #{Config.statuses['todo']}"
      def todo(issue_id)
        issue = get_issue_or_exit issue_id
        check_assigned_to_self issue

        if issue.blocked?
          issue.unblock!
        elsif issue.in_progress?
          issue.stop!
        elsif issue.in_review?
          issue.stop_review!
          issue.stop!
        elsif issue.done?
          issue.reopen!
        end
      end

      desc 'start [ISSUE]', "Move an issue to #{Config.statuses['in_progress']}"
      def start(issue_id)
        issue = get_issue_or_exit issue_id
        check_assigned_to_self issue

        issue.unblock! if issue.blocked?
        issue.reopen! if issue.done?

        if issue.in_review?
          issue.stop_review!
        else
          issue.start!
        end
      end

      desc 'review [ISSUE]', "Move an issue to #{Config.statuses['in_review']}"
      def review(issue_id)
        issue = get_issue_or_exit issue_id
        check_assigned_to_self issue

        if issue.blocked?
          issue.unblock!
          issue.start!
        elsif issue.todo?
          issue.start!
        elsif issue.done?
          issue.reopen!
          issue.start!
        end

        issue.start_review!
      end

      desc 'close [ISSUE]', "Move an issue to #{Config.statuses['done']}"
      def close(issue_id)
        issue = get_issue_or_exit issue_id
        check_assigned_to_self issue

        issue.unblock! if issue.blocked?
        issue.close!
      end

      protected

      def get_issue_or_exit(issue_id)
        issue = Issue.find_by_id(issue_id)

        if issue.nil?
          say 'ERROR: Issue not found'.red
          exit(0)
        else
          issue
        end
      end

      def check_assigned_to_self(issue)
        return if issue.mine?

        exit(0) unless yes? 'WARNING! This issue is not assigned to you!'\
          ' Are you sure you want to continue? [Y/n]:'.yellow
      end

      def build_issue_statuses(options) # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
        if options[:status]
          statuses = [options[:status]]
        else
          statuses = []
          statuses << Config.statuses['blocked']     if options[:blocked]
          statuses << Config.statuses['todo']        if options[:todo]
          statuses << Config.statuses['in_progress'] if options[:in_progress]
          statuses << Config.statuses['in_review']   if options[:in_review]
          statuses << Config.statuses['done']        if options[:closed]
        end

        statuses
      end
    end
  end
end
