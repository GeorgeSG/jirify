module Jirify
  class Status < Base
    def pretty_name
      justified = "(#{name})".rjust(longest_status_name + 2)
      case name
      when Config.statuses['done']        then justified.green
      when Config.statuses['in_progress'] then justified.blue
      when Config.statuses['in_review']   then justified.yellow
      when Config.statuses['todo']        then justified.black
      else                                     justified
      end
    end

    protected

    def longest_status_name
      Config.statuses.values.map(&:length).max
    end

    class << self
      def all
        @all ||= client.Status.all
      end

      def to_do
        @to_do ||= find_by_name Config.statuses['todo']
      end

      def in_progress
        @in_progress ||= find_by_name Config.statuses['in_progress']
      end

      def in_review
        @in_review ||= find_by_name Config.statuses['in_review']
      end

      def closed
        @closed ||= find_by_name Config.statuses['done']
      end

      protected

      def find_by_name(status_name)
        all.select { |status| status.name == status_name }
      end
    end
  end
end
