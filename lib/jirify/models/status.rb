module Jirify
  class Status < Base
    class << self
      def all
        @all ||= client.Status.all
      end

      def to_do
        @to_do ||= find_by_status_name Config.statuses['todo']
      end

      def in_progress
        @in_progress ||= find_by_status_name Config.statuses['in_progress']
      end

      def in_review
        @in_review ||= find_by_status_name Config.statuses['in_review']
      end

      def closed
        @closed ||= find_by_status_name Config.statuses['done']
      end

      protected

      def find_by_status_name(status_name)
        all.select { |status| status.name == status_name }
      end
    end
  end
end
