module Jirify
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

    protected

    def longest_status_name
      Config.statuses.values.map(&:length).max
    end

    class << self
      def all
        client.Status.all.map { |status| Status.new status }
      end
    end
  end
end
