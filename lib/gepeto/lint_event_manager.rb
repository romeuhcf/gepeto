module Gepeto
  module LintEventManager
    @@event_listerners = {}
    def on(event, &block)
      @@event_listerners[event] ||= []
      @@event_listerners[event] << block
    end

    def emit_event(event, *args)
      listeners_of(event).each do |listener|
        listener.call(*args)
      end
    end

    def listeners_of(event)
      @@event_listerners[event] || []
    end
  end
end
