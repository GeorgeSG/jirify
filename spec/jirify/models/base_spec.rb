require 'spec_helper'

describe Jirify::Base do # rubocop:disable RSpec/FilePath
  before do
    allow(Jirify::Config).to receive(:options).and_return(mock_config)
  end

  describe '::client' do
    it 'instantiates a JIRA::Client' do
      allow(JIRA::Client).to receive(:new)
      described_class.client

      expect(JIRA::Client).to have_received(:new).with(Jirify::Config.client_options)
    end
  end

  describe '::project' do
    it 'provides a project' do
      expect(described_class.project).to eq 'TP'
    end
  end

  context 'when invoked with a missing method' do
    it 'tries to send it to the wrapped @entity' do
      entity = instance_double('entity', random_method: 1)
      instance = described_class.new(entity)
      instance.random_method

      expect(entity).to have_received(:random_method)
    end
  end

  describe '#respond_to?' do
    it 'returns true if the wrapped @entity can respond to a method' do
      entity = instance_double('entity', random_method: 1)
      instance = described_class.new(entity)

      expect(instance.respond_to?(:random_method)).to be true
    end

    it 'returns false if the wrapped @entitiy can\'t respond to a method' do
      entity = instance_double('entity')
      instance = described_class.new(entity)

      expect(instance.respond_to?(:random_method2)).to be false
    end
  end
end
