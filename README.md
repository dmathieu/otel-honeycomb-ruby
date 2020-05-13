# A Ruby OpenTelemetry Exporter for Honeycomb

An unofficial Ruby OpenTelemetry exporter for Honeycomn

## Setup

Add the gem to your dependencies.
We're not currently published to rubygems on purpose, as this is an unofficial gem.

```ruby
gem "otel-honeycomb-ruby", github: "dmathieu/otel-honeycomb-ruby"
```

Configure OpenTelemetry to use that exporter:

```ruby
require "opentelemetry/exporters/honeycomb"

OpenTelemetry::SDK.configure do |c|
  c.add_span_processor(
    OpenTelemetry::SDK::Trace::Export::SimpleSpanProcessor.new(
      OpenTelemetry::Exporters::Honeycomb::Exporter.new(writekey: ENV["HONEYCOMB_WRITEKEY"], dataset: "your-dataset")
    )
  )
end
```
