require 'spec_helper'

describe Jirify::TransitionList do # rubocop:disable RSpec/FilePath
  subject(:transition_list) do
    described_class.all(issue_instance)
  end

  let(:transition_instance) { double(JIRA::Resource::Transition, id: 't', name: 'transition-1') }
  let(:issue_instance) { instance_double(JIRA::Resource::Issue, id: 'XX-1234') }

  before do
    allow(Jirify::Config).to receive(:options).and_return(mock_config)
    allow_any_instance_of(JIRA::Client).to receive_message_chain(:Transition, :all) { [transition_instance] }
  end

  describe '::all' do
    it 'invokes the Transition API' do # rubocop:disable RSpec/ExampleLength
      call_count = 0
      allow_any_instance_of(JIRA::Client).to receive_message_chain(:Transition, :all) do
        call_count += 1
        []
      end

      described_class.all(issue_instance)
      expect(call_count).to be 1
    end

    it 'unwraps values as needed' do
      allow_any_instance_of(JIRA::Client).to receive_message_chain(:Project, :all) { [transition] }
      expect(transition_list.list.first.id).to eq 't'
    end
  end

  describe '#list' do
    it 'returns the Transition list' do
      expect(transition_list.list).to eq [transition_instance]
    end
  end

  describe '#names' do
    it 'returns the names of all transitions' do
      expect(transition_list.names).to eq ['transition-1']
    end
  end

  context 'when finding by name' do
    it 'defines methods for finding every transition by name' do
      Jirify::Config.transitions.keys.each do |transition|
        expect(transition_list).to respond_to(transition.to_sym)
      end
    end
  end
end
