require 'opentelemetry-sdk'
require 'libhoney'

module OpenTelemetry
  module Exporters
    module Honeycomb
      class Exporter
        SUCCESS = OpenTelemetry::SDK::Trace::Export::SUCCESS
        FAILURE = OpenTelemetry::SDK::Trace::Export::FAILURE
        private_constant(:SUCCESS, :FAILURE)

        def initialize(writekey: nil, dataset: nil)
          @client = Libhoney::Client.new(writekey: writekey, dataset: dataset)
          @shutdown = false
        end

        def export(span_data, timeout: nil)
          return FAILURE if @shutdown
          span_data.each do |span|
            export_single(span)
          end unless span_data.nil?
          SUCCESS
        end

        def force_flush(timeout: nil)
          SUCCESS
        end

        def shutdown(timeout: nil)
          @client.close(true)
          @shutdown = true
        end

        private

        def export_single(span)
          ev = @client.event
          add_attributes(ev, span)

          ev.timestamp = Time.at(0, span.start_timestamp, :nanosecond).utc

          spanData = {
            name: span.name,
            "trace.span_id": span.hex_span_id,
            "trace.trace_id": span.hex_trace_id,
          }
          if span.hex_parent_span_id != "" && span.hex_parent_span_id != OpenTelemetry::Trace::INVALID_SPAN_ID.unpack1('H*')
            spanData["trace.parent_id"] = span.hex_parent_span_id
          end
          if !span.start_timestamp.nil? && !span.end_timestamp.nil?
            spanData["duration_ms"] = (span.end_timestamp - span.start_timestamp).to_f / 1000000.0
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
              "trace.link.trace_id": link.span_context.trace_id,
              "trace.link.span_id": link.span_context.span_id,
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
      end
    end
  end
end
