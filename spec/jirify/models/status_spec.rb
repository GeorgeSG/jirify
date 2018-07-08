require 'spec_helper'

describe Jirify::Models::Status do
  let(:status_instances) do
    [
      double(JIRA::Resource::Status, name: 'Custom To Do'),
      double(JIRA::Resource::Status, name: 'Done')
    ]
  end

  before do
    allow(Jirify::Config).to receive(:options).and_return(mock_config)
    allow_any_instance_of(JIRA::Client).to receive_message_chain(:Status, :all) { status_instances }
  end

  describe '::all' do
    it 'invokes the Status API' do # rubocop:disable RSpec/ExampleLength
      call_count = 0
      allow_any_instance_of(JIRA::Client).to receive_message_chain(:Status, :all) do
        call_count += 1
        []
      end

      described_class.all
      expect(call_count).to be 1
    end
  end

  it 'unwraps values as needed' do
    expect(described_class.all.first.name).to eq 'Custom To Do'
  end
end
