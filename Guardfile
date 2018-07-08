gem 'rspec', '~> 3.7'

guard 'rspec', cmd: 'bundle exec rspec --color --format doc' do
  watch(%r{^lib/(.+).rb$})  { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^spec/(.+).rb$}) { |m| "spec/#{m[1]}.rb" }
end
