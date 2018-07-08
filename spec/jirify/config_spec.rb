require 'spec_helper'
require 'yaml'

describe Jirify::Config do
  let(:config) { described_class }
  let(:config_dir) { "#{Dir.home}/.jirify" }
  let(:config_file) { "#{Dir.home}/.jirify/.jirify" }
  let(:mock_options) { mock_config }

  before do
    allow(FileUtils).to receive(:mkdir_p)
    allow(FileUtils).to receive(:cp)
    allow(FileUtils).to receive(:touch)
    allow(File).to      receive(:write)
    allow(File).to      receive(:exist?)
    allow(File).to      receive(:directory?)
  end

  describe '::config_folder' do
    before do
      allow(config).to receive(:initialized?)
      allow(config).to receive(:initialize!)
    end

    it 'provides a correct location for the folder' do
      expect(config.config_folder).to eq config_dir
    end

    it 'checks that Jirify is initialized' do
      config.config_folder

      expect(config).to have_received(:initialized?)
    end

    it 'tries to initialize if Jirify wasn\'t initialized' do
      allow(config).to receive(:intialized?).and_return(false)
      config.config_folder

      expect(config).to have_received(:initialize!)
    end
  end

  describe '::config_file' do
    before do
      allow(config).to receive(:initialized?)
      allow(config).to receive(:initialize!)
    end

    it 'provides a correct location for the file' do
      expect(config.config_file).to eq config_file
    end

    it 'checks that Jirify is initialized' do
      config.config_file
      expect(config).to have_received(:initialized?)
    end

    it 'tries to initialize if Jirify wasn\'t initialized' do
      allow(config).to receive(:initialized?).and_return(false)
      config.config_file

      expect(config).to have_received(:initialize!)
    end
  end

  describe '::intialized?' do
    it 'checks that the config folder exists' do
      config.initialized?
      expect(File).to have_received(:directory?).with(config_dir)
    end

    it 'checks that the config file exists' do
      allow(File).to receive(:directory?).and_return(true)
      config.initialized?

      expect(File).to have_received(:exist?).with(config_file)
    end

    it 'returns false if the folder doesn\'t exist' do
      allow(File).to receive(:directory?).with(config_dir).and_return(false)

      expect(config.initialized?).to be false
    end

    it 'returns false if the file doesn\'t exist' do
      allow(File).to receive(:directory?).with(config_dir).and_return(true)
      allow(File).to receive(:exist?).with(config_file).and_return(false)

      expect(config.initialized?).to be false
    end
  end

  describe '::initialize!' do
    it 'creates the config folder' do
      config.initialize!
      expect(FileUtils).to have_received(:mkdir_p).with(config_dir)
    end

    it 'creates an empty config file' do
      config.initialize!
      expect(FileUtils).to have_received(:touch).with(config_file)
    end

    it 'moves the completion script to the config folder' do
      config.initialize!
      expect(FileUtils).to have_received(:cp)
        .with("#{File.expand_path('..', File.dirname(__dir__))}/jirify.bash_completion.sh", config_dir)
    end
  end

  describe '::write' do
    it 'writes json to the config file as yaml' do
      options = { a: [1, 2], b: 3 }

      config.write(options)
      expect(File).to have_received(:write).with(config_file, options.to_yaml)
    end
  end

  describe '::verbose' do
    it 'exits if the config hasn\'t been initialized' do
      allow(config).to receive(:initialized?).and_return(false)
      expect { config.verbose = true }.to raise_error(SystemExit)
    end

    it 'appends verbose to the end of the config options' do
      allow(config).to receive(:initialized?).and_return(true)
      allow(config).to receive(:write)
      allow(YAML).to receive(:load_file).and_return('options' => { 'opt1' => '1' })

      config.verbose = true

      expect(config).to have_received(:write).with('options' => { 'opt1' => '1', 'verbose' => true })
    end
  end

  describe '::options' do
    it 'exits if the config hasn\'t been initialized' do
      allow(config).to receive(:initialized?).and_return(false)
      expect { config.options }.to raise_error(SystemExit)
    end

    it 'returns the options as json' do
      allow(config).to receive(:initialized?).and_return(true)
      allow(YAML).to receive(:load_file).and_return('options' => { 'opt1' => '1' })

      expect(config.options).to eq('opt1' => '1')
    end
  end

  describe 'config option getters' do
    before do
      allow(config).to receive(:options).and_return(mock_options)
    end

    describe '::always_verbose' do
      it 'returns the config verbose value' do
        expect(config.always_verbose).to be true
      end
    end

    describe '::atlassian_url' do
      it 'returns the config site value' do
        expect(config.atlassian_url).to eq 'https://test.atlassian.com'
      end
    end

    describe '::username' do
      it 'returns the config username value' do
        expect(config.username).to eq 'test@test.com'
      end
    end

    describe '::issue_browse_url' do
      it 'returns the jira issue browse url' do
        expect(config.issue_browse_url).to eq 'https://test.atlassian.com/browse/'
      end
    end

    describe '::client_options' do
      it 'returns client options for jira-ruby' do # rubocop:disable RSpec/ExampleLength
        expect(config.client_options).to eq(
          username:     'test@test.com',
          password:     '123abc',
          site:         'https://test.atlassian.com',
          context_path: '',
          auth_type:    :basic
        )
      end
    end

    describe '::statuses' do
      it 'returns default if jirify wasn\'t initialized' do
        allow(config).to receive(:initialized?).and_return(false)
        expect(config.statuses).to include('todo' => 'To Do')
      end

      it 'returns statuses hash from config' do
        allow(config).to receive(:initialized?).and_return(true)
        expect(config.statuses).to include('todo' => 'Custom To Do')
      end
    end

    describe '::transitions' do
      it 'returns default if jirify wasn\'t initialized' do
        allow(config).to receive(:initialized?).and_return(false)
        expect(config.transitions).to include('start' => 'Start Progress')
      end

      it 'returns transitions hash from config' do
        allow(config).to receive(:initialized?).and_return(true)
        expect(config.transitions).to include('start' => 'Custom Start Progress')
      end
    end
  end
end
