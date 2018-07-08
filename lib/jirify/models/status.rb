module Jirify
  module Models
    class Status < Base
      def pretty_name
        justified = "(#{name})".rjust(longest_status_name + 2)
        case name
        when Config.statuses['blocked']     then justified.red
        when Config.statuses['done']        then justified.green
        when Config.statuses['in_progress'] then justified.blue
        when Config.statuses['in_review']   then justified.yellow
        when Config.statuses['todo']        then justified.black
        else                                     justified
        end
      end

      def <=>(other)
        this_index  = Status.status_order.index(name)
        other_index = Status.status_order.index(other.name)
        return 1 if other_index.nil?
        return 0 if this_index.nil?

        this_index - other_index
      end

      protected

      def longest_status_name
        Config.statuses.values.map(&:length).max
      end

      class << self
        def all
          client.Status.all.map { |status| Status.new status }
        end

        def status_order
          [
            Config.statuses['blocked'],
            Config.statuses['todo'],
            Config.statuses['in_progress'],
            Config.statuses['in_review'],
            Config.statuses['done']
          ]
        end
      end
    end
  end
end
