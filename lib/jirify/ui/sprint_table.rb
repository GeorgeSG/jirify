require 'io/console'
require 'terminal-table'

module Jirify
  module UI
    class SprintTable
      attr_reader :issues
      def initialize(issues)
        @issues = issues
      end

      def to_table(options)
        grouped_issues = issues.group_by do |issue|
          options[:all_columns] ? issue.status.name : issue.status.statusCategory['name']
        end

        grouped_issues_as_table(grouped_issues, options)
      end

      protected

      def terminal_width
        IO.console.winsize[1]
      end

      def table_style
        { width: terminal_width, border_x: '-', border_i: 'x' }
      end

      def headings(grouped_issues)
        grouped_issues.keys.sort_by do |name|
          status_index = Models::Status.status_order.index(name)
          if status_index.nil?
            grouped_issues.keys.length
          else
            status_index
          end
        end
      end

      def grouped_issues_as_table(grouped_issues, options)
        transposed = transpose(grouped_issues.values, options)
        return nil if transposed.empty?

        Terminal::Table.new(
          headings: headings(grouped_issues),
          rows: transposed,
          style: table_style
        )
      end

      def transpose(grouped_issues, options)
        col_padding_per_row = grouped_issues.size * 4
        max_cell_length     = (terminal_width - col_padding_per_row) / grouped_issues.size

        # workaround - not all groups have the same size
        l = grouped_issues.map(&:length).max
        grouped_as_array = grouped_issues.map { |e| e.values_at(0...l) }

        grouped_as_array.sort_by! do |row|
          issue = row.find { |i| !i.nil? }
          issue.status
        end

        transposed = grouped_as_array.transpose

        transposed.map! do |row|
          row.map do |issue|
            next if issue.nil?
            SprintCell.new(issue, max_cell_length).to_s(options)
          end
        end

        transposed = transposed.zip([:separator] * transposed.size).flatten(1)
        transposed.pop
        transposed
      end
    end
  end
end
