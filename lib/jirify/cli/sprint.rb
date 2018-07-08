module Jirify
  class CLI < Thor
    desc 'sprint', 'Show the current sprint table'
    method_option :mine, type: :boolean, aliases: '-m', desc: 'Show only issues assigned to me'
    method_option :all_columns, type: :boolean, aliases: '-a', desc: 'Show all columns'
    def sprint
      say Jirify::Sprint.current(Config.always_verbose || options[:verbose],
                                 options[:all_columns],
                                 options[:mine])
    rescue Jirify::UI::WindowTooNarrow => e
      say 'ERROR: Your terminal window is too narrow to print the sprint table!'.red
    end
  end
end
