require 'terminal-table'

module Jirify
  module UI
    class SprintTable
      attr_reader :issues
      def initialize(issues)
        @issues = issues
      end

      def to_table(options)
        return '' if issues.empty?

        # group issues by status name
        grouped_issues = issues.group_by do |issue|
          options[:all_columns] ? issue.status.name : issue.status.statusCategory['name']
        end

        Terminal::Table.new(
          headings: headings(grouped_issues),
          rows: issues_as_rows(grouped_issues.values, options),
          style: table_style
        )
      end

      protected

      def terminal_width
        IO.console.winsize[1]
      end

      def table_style
        { width: terminal_width, border_x: '-', border_i: 'x' }
      end

      def get_max_cell_length(grouped_issues)
        col_padding_per_row = grouped_issues.size * 3 + 1
        (terminal_width - col_padding_per_row) / grouped_issues.size
      end

      def headings(grouped_issues)
        max_cell_length = get_max_cell_length(grouped_issues)

        sorted_headings = sort_headings(grouped_issues.keys)
        sorted_headings.map do |heading|
          original_heading = heading
          heading = fit_heading_to_cell(heading, max_cell_length)

          case original_heading
          when Config.statuses['todo']        then ColorizedString[heading].white.on_black.bold
          when Config.statuses['in_progress'] then ColorizedString[heading].white.on_blue.bold
          when Config.statuses['in_review']   then ColorizedString[heading].white.on_yellow.bold
          when Config.statuses['blocked']     then ColorizedString[heading].white.on_red.bold
          when Config.statuses['done']        then ColorizedString[heading].white.on_green.bold
          else                                     ColorizedString[heading].white.on_green.bold
          end
        end
      end

      def sort_headings(heading_names)
        heading_names.sort_by! do |name|
          status_index = Models::Status.status_order.index(name)
          if status_index.nil?
            # If status is not defined in order, put it at the end
            grouped_issues.keys.length
          else
            status_index
          end
        end
      end

      def fit_heading_to_cell(name, max_cell_length)
        if name.length >= max_cell_length
          # If the heading name is longer than the max length, add ellipsis.
          "#{name[0...max_cell_length - 3]}..."
        else
          # Add spaces around the heading name to center it.
          buffer = max_cell_length - name.length
          left = ' ' * (buffer / 2)
          right = ' ' * (buffer / 2)
          right += ' ' if buffer.odd?

          "#{left}#{name}#{right}"
        end
      end

      def issues_as_rows(grouped_issues, options)
        options[:max_length] = get_max_cell_length(grouped_issues)

        # Workaround - not all groups have the same size.
        l = grouped_issues.map(&:length).max
        grouped_as_array = grouped_issues.map { |e| e.values_at(0...l) }

        # Sort columns by status and transpose them to become rows.
        grouped_as_array.sort_by! { |row| row.first.status }
        transposed = grouped_as_array.transpose

        # Map every Issue in every row to its display representation.
        transposed.map! do |row|
          row.map do |issue|
            next if issue.nil?
            IssueRenderer.new(issue).as_table_cell(options)
          end
        end

        # add separators after each row
        transposed = transposed.zip([:separator] * transposed.size).flatten(1)
        # remove the separator after the last row, it's not needed
        transposed.pop

        transposed
      end
    end
  end
end
