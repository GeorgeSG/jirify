require 'spec_helper'

describe Jirify::Models::Project do
  subject(:project) { described_class.new project_resource }

  let(:project_resource) { double(JIRA::Resource::Project, key: 'XX') }

  it 'unwraps values as needed' do
    expect(project.key).to eq 'XX'
  end
end
