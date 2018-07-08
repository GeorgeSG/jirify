module Jirify
  class CLI < Thor
    desc 'sprint', 'Show the current sprint table'
    method_option :mine, type: :boolean, aliases: '-m', desc: 'Show only issues assigned to me'
    method_option :all_columns, type: :boolean, aliases: '-a', desc: 'Show all columns'
    def sprint
      verbose = Config.always_verbose || options[:verbose]
      issues  = Jirify::Sprint.issues_in_current_sprint(options[:mine])

      say UI::SprintTable.new(issues).to_table(options[:all_columns], verbose)
    rescue UI::WindowTooNarrow
      say 'ERROR: Your terminal window is too narrow to print the sprint table!'.red
    end
  end
end
