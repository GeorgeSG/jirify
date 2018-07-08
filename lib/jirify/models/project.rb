module Jirify
  module Models
    class Project < Base
      class << self
        def all
          client.Project.all.map { |project| Project.new project }
        end
      end
    end
  end
end
