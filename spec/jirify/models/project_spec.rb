require 'spec_helper'

describe Jirify::Project do # rubocop:disable RSpec/FilePath
  let(:project_instance) { instance_double(JIRA::Resource::Project, id: 'key') }

  before do
    allow(Jirify::Config).to receive(:options).and_return(mock_config)
    allow_any_instance_of(JIRA::Client).to receive_message_chain(:Project, :all) { [project_instance] }
  end

  describe '::all' do
    it 'invokes the Project API' do # rubocop:disable RSpec/ExampleLength
      call_count = 0
      allow_any_instance_of(JIRA::Client).to receive_message_chain(:Project, :all) do
        call_count += 1
        []
      end

      described_class.all
      expect(call_count).to be 1
    end

    it 'maps returned projects to instances' do
      expect(described_class.all.first).to be_an(described_class)
    end
  end

  it 'unwraps values as needed' do
    expect(described_class.all.first.id).to eq 'key'
  end
end
