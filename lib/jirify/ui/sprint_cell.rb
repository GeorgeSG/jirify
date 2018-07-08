module Jirify
  module UI
    class WindowTooNarrow < StandardError; end

    class SprintCell
      attr_reader :issue, :max_cell_length

      def initialize(issue, max_cell_length)
        @issue = issue
        @max_cell_length = max_cell_length
      end

      def key
        issue.key
      end

      def summary
        issue.summary
      end

      def show_assignee?(options)
        options[:assignee] && !options[:mine]
      end

      def assignee
        if issue.assignee.nil?
          'Unassigned'
        else
          issue.assignee.displayName
        end
      end

      def url
        "#{Config.issue_browse_url}#{issue.key}"
      end

      def to_s(options)
        raise UI::WindowTooNarrow, 'The terminal window is too narrow.' if max_cell_length <= key.size

        options[:verbose] ? to_verbose_cell(options) : to_short_cell(options)
      end

      protected

      def display_url?
        url.size <= max_cell_length
      end

      def assignee_line(options, max_cell_length)
        return '' unless show_assignee?(options)

        assignee_line = assignee
        assignee_line = "#{assignee[0...max_cell_length - 3]}..." if assignee_line.size >= max_cell_length

        "\n#{assignee_line.magenta}"
      end

      def key_and_summary_lines(options, max_cell_length)
        return key unless options[:summary]

        key_and_summary = "#{key}: #{summary}"

        if key_and_summary.size <= max_cell_length
          key_and_summary
        else
          "#{key}\n#{summary[0...max_cell_length - 3]}..."
        end
      end

      def to_verbose_cell(options)
        row = ''
        row << key_and_summary_lines(options, max_cell_length)
        row << "\n#{url.blue}" if display_url? && options[:url]
        row << assignee_line(options, max_cell_length)
        row
      end

      def to_short_cell(options)
        return key unless display_url? && options[:url]

        single_row = "#{key}: #{url}"

        if single_row.size <= max_cell_length
          "#{key}: #{url.blue}"
        else
          "#{key}\n#{url.blue}"
        end
      end
    end
  end
end
