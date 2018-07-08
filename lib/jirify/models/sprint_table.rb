require 'io/console'

module Jirify
  class SprintTable
    attr_reader :issues
    def initialize(issues)
      @issues = issues
    end

    def to_table(all_columns, verbose)
      grouped_issues = issues.group_by do |issue|
        all_columns ? issue.status.name : issue.status.statusCategory['name']
      end

      grouped_issues_as_table(grouped_issues, verbose)
    end

    protected

    def terminal_width
      IO.console.winsize[1]
    end

    def table_style
      { width: terminal_width, border_x: '-', border_i: 'x' }
    end

    def grouped_issues_as_table(grouped_issues, verbose)
      transposed = transpose(grouped_issues.values, verbose)
      return nil if transposed.empty?

      Terminal::Table.new(
        headings: grouped_issues.keys,
        rows: transposed,
        style: table_style
      )
    end

    def transpose(all_groups, verbose)
      total_col_width_padding = all_groups.size * 4

      # workaround - not all groups have the same size
      l = all_groups.map(&:length).max
      transposed = all_groups.map { |e| e.values_at(0...l) }.transpose

      max_cell_length = (terminal_width - total_col_width_padding) / all_groups.size

      transposed.map! do |row|
        row.map do |issue|
          next if issue.nil?
          SprintCell.new(issue, max_cell_length).to_s(verbose)
        end
      end

      transposed = transposed.zip([:separator] * transposed.size).flatten(1)
      transposed.pop
      transposed
    end
  end
end
