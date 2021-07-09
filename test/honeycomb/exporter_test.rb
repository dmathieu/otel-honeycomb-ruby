require 'test_helper'

describe OpenTelemetry::Exporters::Honeycomb::Exporter do
  SUCCESS = OpenTelemetry::SDK::Trace::Export::SUCCESS
  FAILURE = OpenTelemetry::SDK::Trace::Export::FAILURE

  let(:writekey) { SecureRandom.uuid }
  let(:dataset) { "my-dataset" }
  let(:exporter) { OpenTelemetry::Exporters::Honeycomb::Exporter.new(writekey: writekey, dataset: dataset) }

  describe '#initialize' do
    it 'initializes' do
      _(exporter).wont_be_nil
    end
  end

  describe '#export' do
    before do
      OpenTelemetry.tracer_provider = OpenTelemetry::SDK::Trace::TracerProvider.new
    end

    it 'returns FAILURE when shutdown' do
      exporter.shutdown
      result = exporter.export(nil)
      _(result).must_equal(FAILURE)
    end

    it 'exports a span_data' do
      span_data = create_span_data
      result = exporter.export([span_data])
      _(result).must_equal(SUCCESS)
    end

    it 'exports a span_dat with attributes' do
      span_data = create_span_data(attributes: {hello: "world"})
      result = exporter.export([span_data])
      _(result).must_equal(SUCCESS)
    end

    it 'exports a span_dat with events' do
      span_data = create_span_data(events: [OpenTelemetry::SDK::Trace::Event.new(name: "my-event")])
      result = exporter.export([span_data])
      _(result).must_equal(SUCCESS)
    end

    it 'exports a span_dat with links' do
      context = OpenTelemetry::Trace::SpanContext.new
      span_data = create_span_data(links: [OpenTelemetry::Trace::Link.new(context)])
      result = exporter.export([span_data])
      _(result).must_equal(SUCCESS)
    end
  end

  def create_span_data(name: '', kind: :client, status: nil, parent_span_id: OpenTelemetry::Trace::INVALID_SPAN_ID,
                            total_recorded_attributes: 0, total_recorded_events: 0, total_recorded_links: 0,
                            start_timestamp: Time.now.to_f * (10 ** 9), end_timestamp: Time.now.to_f * (10 ** 9) + 1000,
                            attributes: {}, links: [], events: [], resource: nil, instrumentation_library: nil,
                            span_id: OpenTelemetry::Trace.generate_span_id, trace_id: OpenTelemetry::Trace.generate_trace_id,
                            trace_flags: OpenTelemetry::Trace::TraceFlags::DEFAULT, tracestate: nil)
    OpenTelemetry::SDK::Trace::SpanData.new(name, kind, status, parent_span_id,
                                            total_recorded_attributes, total_recorded_events, total_recorded_links,
                                            start_timestamp, end_timestamp,
                                            attributes, links, events, resource, instrumentation_library,
                                            span_id, trace_id,
                                            trace_flags, tracestate)
  end
end
