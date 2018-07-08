module Jirify
  module UI
    class WindowTooNarrow < StandardError; end

    class SprintCell
      attr_reader :issue, :max_cell_length

      def initialize(issue, max_cell_length)
        @issue = issue
        @max_cell_length = max_cell_length
      end

      def to_s(options)
        raise UI::WindowTooNarrow, 'The terminal window is too narrow.' if max_cell_length <= key.size

        row = ''
        row << key_and_summary_lines(options, max_cell_length)
        row << "\n#{ColorizedString[url].blue.underline}" if display_url?(options)
        row << assignee_line(max_cell_length) if show_assignee?(options)
        row
      end

      protected

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

      def display_url?(options)
        url.size <= max_cell_length && options[:url]
      end

      def wrap(string, columns, character = "\n")
        return '' if string.nil?

        start_pos = columns
        while start_pos < string.length
          space = string.rindex(' ', start_pos) || start_pos + 1
          string.slice!(space)
          string.insert(space, character)
          start_pos = space + columns + 1
        end

        string
      end

      def key_and_summary_lines(options, max_cell_length)
        bold_key = ColorizedString[key].bold
        return bold_key unless options[:summary]

        row = "#{bold_key}\n"
        row << wrap(summary.strip, max_cell_length)
        row
      end

      def assignee_line(max_cell_length)
        assignee_line = assignee
        assignee_line = "#{assignee[0...max_cell_length - 3]}..." if assignee_line.size >= max_cell_length

        "\n#{assignee_line.magenta}"
      end
    end
  end
end
