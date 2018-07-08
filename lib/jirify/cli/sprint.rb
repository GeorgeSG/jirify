module Jirify
  class CLI < Thor
    desc 'sprint', 'Show the current sprint table'
    method_option :mine, type: :boolean, aliases: '-m', desc: 'Show only issues assigned to me'
    method_option :all_columns, type: :boolean, aliases: '-c', default: true, desc: 'Show all columns'
    method_option :assignee, type: :boolean, aliases: '-a', desc: 'Show issue assignee'
    method_option :summary, type: :boolean, aliases: '-s', desc: 'Show issue summary'
    method_option :url, type: :boolean, aliases: '-u', desc: 'Show issue url'
    def sprint
      verbose = Config.always_verbose || options[:verbose]
      issues  = Models::Sprint.issues_in_current_sprint(options[:mine])

      duplicate_options = options.dup
      if verbose
        duplicate_options[:assignee] = true
        duplicate_options[:url] = true
        duplicate_options[:summary] = true
      end
      say UI::SprintTable.new(issues).to_table(duplicate_options)
    rescue UI::WindowTooNarrow
      say 'ERROR: Your terminal window is too narrow to print the sprint table!'.red
    end
  end
end
