module JIRA
  module Resource
    class Issue
      def transition!(transition)
        attrs = { transition: transition.id }.to_json
        client.send(:post, "#{url}/transitions", attrs)
      end

      def assign_to!(username)
        attrs = { name: username }.to_json
        client.send(:put, "#{url}/assignee", attrs)
      end
    end
  end
end
