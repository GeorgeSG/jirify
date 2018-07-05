require 'yaml'

module JiraConfig
  CONFIG_FILE = YAML.load_file(File.join(File.dirname(File.expand_path(__FILE__)), 'config.yml'))
  OPTIONS = self::CONFIG_FILE['options']

  ATLASSIAN_URL =self::OPTIONS['site']
  ISSUE_BROWSE_URL = "#{JiraConfig::ATLASSIAN_URL}/browse/"

  CLIENT_OPTIONS = {
    :username     => self::OPTIONS['username'],
    :password     => self::OPTIONS['token'],
    :site         => ATLASSIAN_URL,
    :context_path => '',
    :auth_type    => :basic,
  }
end
