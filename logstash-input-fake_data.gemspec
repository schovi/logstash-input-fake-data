Gem::Specification.new do |s|
  s.name = 'logstash-input-fake_data'
  s.version = '1.0.0-beta.1'
  s.licenses = ['Apache License (2.0)']
  s.summary = "Fake data generator"
  s.description = "This logstash input plugin allows you to generate object with predefined structure. You can change any property and depth of object."
  s.authors = ["David Schovanec"]
  s.email = 'david@schovi.cz'
  s.homepage = "https://github.com/schovi/logstash-input-fake_data"
  s.require_paths = ["lib"]

  # Files
  s.files = Dir[
              'lib/**/*','spec/**/*',
              'vendor/**/*',
              '*.gemspec',
              '*.md',
              'CONTRIBUTORS',
              'Gemfile',
              'LICENSE',
              'NOTICE.TXT'
            ]

   # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "input" }

  # Gem dependencies
  s.add_runtime_dependency "logstash-core", ">= 2.0.0", "< 3.0.0"
  s.add_runtime_dependency 'logstash-codec-plain'
  s.add_runtime_dependency 'stud', '>= 0.0.22'
  s.add_runtime_dependency 'fake_data'

  s.add_development_dependency 'logstash-devutils', '>= 0.0.16'
end
