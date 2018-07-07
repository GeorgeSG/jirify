module JIRA
  module Resource
    class Issue
      def transition!(transition)
        attrs = { transition: transition.id }.to_json
        client.send(:post, "#{url}/transitions", attrs)
      end

      def assign_to!(username)
        client.send(:put, "#{url}/assignee", { name: username }.to_json)
      end
    end
  end
end
