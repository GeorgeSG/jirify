module Jirify
  class CLI < Thor
    desc "mine", "List all of the issues assigned to you in the current sprint"
    method_option :in_progress, type: :boolean, aliases: '-i', desc: "Show only issues in progress"
    method_option :in_review, type: :boolean, aliases: '-r', desc: "Show only issues in review"
    method_option :closed, type: :boolean, aliases: '-c', desc: "Show only closed issues"
    method_option :todo, type: :boolean, aliases: '-t', desc: "Show only issues in todo"
    method_option :all, type: :boolean, aliases: '-a', desc: "Show all assigned issues in Project - not limited to sprint"
    method_option :status, banner: "<status>", type: :string, aliases: '-s', desc: "Show only issues with the specified status"
    method_option :statuses, banner: "<statuses>", type: :array, desc: "Show only issues with the specified statuses"
    def mine
      if options[:status]
        statuses = [options[:status]]
      else
        statuses = []
        statuses << "To Do" if options[:todo]
        statuses << "In Progress" if options[:in_progress]
        statuses << "In Review" if options[:in_review]
        statuses << "Closed" if options[:closed]
      end

      Jirify::Issues.mine(options[:verbose], statuses, options[:all])
    end
  end
end
