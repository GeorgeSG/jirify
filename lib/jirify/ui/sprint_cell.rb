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

      def url
        "#{Config.issue_browse_url}#{issue.key}"
      end

      def to_s(verbose)
        raise UI::WindowTooNarrow, 'The terminal window is too narrow.' if max_cell_length <= key.size

        verbose ? to_verbose_cell : to_short_cell
      end

      protected

      def display_url?
        url.size <= max_cell_length
      end

      def to_verbose_cell
        key_and_summary = "#{key}: #{summary}"

        if key_and_summary.size <= max_cell_length
          row = key_and_summary
        else
          row = "#{key}\n#{summary[0...max_cell_length - 3]}..."
        end

        row << "\n#{url.blue}" if display_url?
        row
      end

      def to_short_cell
        return key unless display_url?

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
