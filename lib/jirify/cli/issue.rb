module Jirify
  module Subcommands
    class Issues < Thor
      default_task :mine

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
        statuses = build_issue_statuses(options)
        issues = Jirify::Issue.list_mine(statuses, options[:all])
        issues.each { |issue| issue.print options[:verbose] }
      end

      desc 'status [ISSUE]', 'Displays issue status'
      def status(issue_id)
        issue = Jirify::Issue.find_by_id(issue_id)
        puts issue.status.name
      end

      desc 'transitions [ISSUE]', 'Displays available transitions'
      def transitions(issue_id)
        issue = Jirify::Issue.find_by_id(issue_id)
        puts "Available transitions:"
        puts issue.transitions.names
      end

      desc 'transition [ISSUE] [TRANSITION]', 'Manually perform a transition'
      def transition(issue_id, transition_name)
        issue = Jirify::Issue.find_by_id(issue_id)
        transition = issue.transitions.list.find { |transition| transition.name == transition_name }

        if transition.nil?
          puts "ERROR: Issue cannto transition to #{transition_name}".red
          exit(0)
        end

        puts "Transitioning #{issue.key} with #{transition_name}...".green
        issue.transition! transition
      end

      desc 'block [ISSUE]', "Moves an issue to #{Config.statuses['blocked']}"
      def block(issue_id)
        issue = Jirify::Issue.find_by_id(issue_id)
        check_assigned_to_self issue

        issue.reopen! if issue.done?
        issue.stop_review! if issue.in_review?
        issue.block!
      end

      desc 'unblock [ISSUE]', 'Unblocks an issue'
      def unblock(issue_id)
        issue = Jirify::Issue.find_by_id(issue_id)
        check_assigned_to_self issue

        if issue.blocked?
          puts "Unblocking issue..."
          issue.unblock!
        else
          puts "Issue wasn't blocked anyway :)".green
        end
      end

      desc 'todo [ISSUE]', "Moves an issue to #{Config.statuses['todo']}"
      def todo(issue_id)
        issue = Jirify::Issue.find_by_id(issue_id)
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

      desc 'start [ISSUE]', "Moves an issue to #{Config.statuses['in_progress']}"
      def start(issue_id)
        issue = Jirify::Issue.find_by_id(issue_id)
        check_assigned_to_self issue

        issue.unblock! if issue.blocked?
        issue.reopen! if issue.done?

        if issue.in_review?
          issue.stop_review!
        else
          issue.start!
        end
      end

      desc 'review [ISSUE]', "Moves an issue to #{Config.statuses['in_review']}"
      def review(issue_id)
        issue = Jirify::Issue.find_by_id(issue_id)
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

      desc 'close [ISSUE]', "Moves an issue to #{Config.statuses['done']}"
      def close(issue_id)
        issue = Jirify::Issue.find_by_id(issue_id)
        check_assigned_to_self issue

        issue.unblock! if issue.blocked?
        issue.close!
      end

      protected

      def check_assigned_to_self(issue)
        unless issue.mine?
          exit(0) unless yes? 'WARNING! This issue is not assigned to you!'\
            ' Are you sure you want to continue? [Y/n]:'.yellow
        end
      end

      def build_issue_statuses(options)
        if options[:status]
          statuses = [options[:status]]
        else
          statuses = []
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
