module Jirify
  class CLI < Thor
    desc 'sprint', 'Show the current sprint table'
    method_option :mine, type: :boolean, aliases: '-m', desc: 'Show only issues assigned to me'
    method_option :all_columns, type: :boolean, aliases: '-a', desc: 'Show all columns'
    def sprint
      Jirify::Sprint.current(options[:verbose], options[:all_columns], options[:mine])
    end
  end
end
