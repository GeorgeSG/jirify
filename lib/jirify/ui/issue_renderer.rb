module Jirify
  module UI
    class WindowTooNarrow < StandardError; end

    class IssueRenderer
      attr_reader :issue

      def initialize(issue)
        @issue = issue
      end

      def as_table_cell(options)
        options[:max_length] ||= IO.console.winsize[1] - 4
        options[:summary]    ||= false
        options[:url]        ||= false
        options[:assignee]   ||= false

        raise UI::WindowTooNarrow, 'The terminal window is too narrow.' if options[:max_length] <= key.size

        row = ''
        row << "#{ColorizedString[key].bold}"
        row << summary_line(options)  if show_summary?(options)
        row << url_line               if show_url?(options)
        row << assignee_line(options) if show_assignee?(options)
        row
      end

      def as_card(options)
        card = as_table_cell(options)
        Terminal::Table.new(rows: [[card]])
      rescue RuntimeError
        raise UI::WindowTooNarrow, 'The terminal window is too narrow.'
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

      def assignee_line(options)
        max_length = options[:max_length]
        assignee_line = assignee
        assignee_line = "#{assignee[0...max_length - 3]}..." if assignee_line.size >= max_length

        "\n#{assignee_line.magenta}"
      end

      def show_url?(options)
        url.size <= options[:max_length] && options[:url]
      end

      def url
        "#{Config.issue_browse_url}#{issue.key}"
      end

      def url_line
        "\n#{ColorizedString[url].blue.underline}"
      end

      def show_summary?(options)
        options[:summary]
      end

      def summary_line(options)
        "\n#{wrap(summary.strip, options[:max_length])}"
      end

      def wrap(string, columns, character = "\n")
        return '' if string.nil?

        start_pos = columns
        while start_pos < string.length
          space = string.rindex(' ', start_pos) || start_pos - 1
          string.slice!(space)
          string.insert(space, character)
          start_pos = space + columns + 1
        end

        string
      end
    end
  end
end
