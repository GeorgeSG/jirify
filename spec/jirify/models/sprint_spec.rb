require 'spec_helper'

describe Jirify::Models::Sprint do
  let(:issue_instance) { double(JIRA::Resource::Issue) }

  before do
    allow(Jirify::Config).to receive(:options).and_return(mock_config)
    allow_any_instance_of(JIRA::Client).to receive_message_chain(:Issue, :jql) { [issue_instance] }
  end

  describe '::issues_in_current_sprint' do
    it 'invokes the Issue API with JQL' do # rubocop:disable RSpec/ExampleLength
      call_count = 0
      allow_any_instance_of(JIRA::Client).to receive_message_chain(:Issue, :jql) do
        call_count += 1
        []
      end

      described_class.issues_in_current_sprint
      expect(call_count).to be 1
    end

    it 'maps returned issues to instances' do
      expect(described_class.issues_in_current_sprint.first).to be_an(Jirify::Models::Issue)
    end
  end
end
