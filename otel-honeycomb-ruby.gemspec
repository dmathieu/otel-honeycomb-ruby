lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'opentelemetry/exporters/honeycomb/version'

Gem::Specification.new do |spec|
  spec.name        = 'otel-honeycomb-ruby'
  spec.version     = OpenTelemetry::Exporters::Honeycomb::VERSION
  spec.authors     = ['Damien Mathieu']
  spec.email       = ['42@dmathieu.com']

  spec.summary     = 'Honeycomb trace exporter for the OpenTelemetry framework'
  spec.description = 'Honeycomb trace exporter for the OpenTelemetry framework'
  spec.homepage    = 'https://github.com/dmathieu/otel-honeycomb-ruby'
  spec.license     = 'Hippocratic 2.1'

  spec.files = ::Dir.glob('lib/**/*.rb') +
               ::Dir.glob('*.md') +
               ['LICENSE']
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.5.0'

  spec.add_dependency 'opentelemetry-api', '~> 0.4.0'
  spec.add_dependency 'opentelemetry-sdk', '~> 0.4.0'
  spec.add_dependency 'libhoney', '~> 1.14.4'

  spec.add_development_dependency 'bundler', '>= 1.17'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'simplecov', '~> 0.17'
end
