require 'spec_helper'

describe Jirify::Models::Transition do
  subject(:transition) { described_class.new transition_resource }

  let(:transition_resource) { double(JIRA::Resource::Transition, name: 'Transition 1') }

  it 'unwraps values as needed' do
    expect(transition.name).to eq 'Transition 1'
  end
end
