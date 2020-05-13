require 'opentelemetry-sdk'
require 'libhoney'

module OpenTelemetry
  module Exporters
    module Honeycomb
      class Exporter
        SUCCESS = OpenTelemetry::SDK::Trace::Export::SUCCESS
        FAILED_RETRYABLE = OpenTelemetry::SDK::Trace::Export::FAILED_RETRYABLE
        FAILED_NOT_RETRYABLE = OpenTelemetry::SDK::Trace::Export::FAILED_NOT_RETRYABLE
        private_constant(:SUCCESS, :FAILED_RETRYABLE, :FAILED_NOT_RETRYABLE)

        def initialize(writekey: nil, dataset: nil)
          @client = Libhoney::Client.new(writekey: writekey, dataset: dataset)
          @shutdown = false
        end

        def export(span_data)
          return FAILED_NOT_RETRYABLE if @shutdown
          span_data.each do |span|
            export_single(span)
          end unless span_data.nil?
          SUCCESS
        end

        def export_single(span)
          ev = @client.event
          add_attributes(ev, span)

          ev.timestamp = span.start_timestamp

          spanData = {
            name: span.name,
            "trace.span_id": span.span_id,
            "trace.trace_id": span.trace_id,
          }
          if span.parent_span_id != "" && span.parent_span_id != OpenTelemetry::Trace::INVALID_SPAN_ID
            spanData["trace.parent_id"] = span.parent_span_id
          end
          if !span.start_timestamp.nil? && !span.end_timestamp.nil?
            spanData["duration_ms"] = (span.end_timestamp - span.start_timestamp) * 1000
          end
          ev.add(spanData)

          span.events.each do |event|
            spanEv = @client.event
            add_attributes(spanEv, span)
            add_attributes(spanEv, event)

            spanEv.timestamp = event.timestamp

            spanEv.add({
              name: event.name,
              "trace.trace_id": span.trace_id,
              "trace.parent_id": span.trace_id,
              "trace.parent_name": span.name,
              "meta.span_type": "span_event"
            })

            spanEv.send
          end unless span.events.nil?

          span.links.each do |link|
            linkEv = @client.event
            linkEv.add({
              "trace.trace_id": span.trace_id,
              "trace.parent_id": span.trace_id,
              "trace.link.trace_id": link.context.trace_id,
              "trace.link.span_id": link.context.span_id,
              "meta.span_type": "link",
              "ref_type": 0,
            })
            linkEv.send
          end unless span.links.nil?

          ev.send_presampled
        end

        def add_attributes(event, span)
          span.attributes.each do |k,v|
            event.add_field(k, v)
          end unless span.attributes.nil?
        end

        def shutdown
          @client.close(true)
          @shutdown = true
        end
      end
    end
  end
end
