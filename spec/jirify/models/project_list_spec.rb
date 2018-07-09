require 'spec_helper'

describe Jirify::Models::ProjectList do
  subject(:project_list) do
    described_class.all
  end

  let(:project_resources) do
    [
      double(JIRA::Resource::Project, key: 'XX1', name: 'Project 1'),
      double(JIRA::Resource::Project, key: 'XX2', name: 'Project 2')
    ]
  end

  before do
    allow(Jirify::Config).to receive(:options).and_return(mock_config)
    allow_any_instance_of(JIRA::Client).to receive_message_chain(:Project, :all) { project_resources }
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

    it 'unwraps values as needed' do
      allow_any_instance_of(JIRA::Client).to receive_message_chain(:Project, :all) { project_resources }
      expect(project_list.first.key).to eq 'XX1'
    end
  end

  describe '#list' do
    it 'returns the project list' do
      expect(project_list.count).to be 2
    end

    it 'maps returned projects to instances of Project models' do
      expect(project_list.first).to be_a(Jirify::Models::Project)
    end
  end

  describe '#names' do
    it 'returns the names of all projects' do
      expect(project_list.names).to eq ['Project 1', 'Project 2']
    end
  end
end
