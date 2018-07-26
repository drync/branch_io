require_relative "response"

module BranchIO
  class Client
    module Events
      # See: https://docs.branch.io/pages/apps/v2event/#available-events
      def log_standard_event(options = {})
        log_event("/v2/event/standard", options)
      end

      def log_custom_event(options = {})
        log_event("/v2/event/custom", options)
      end

      private

      def log_event(path, options = {})
        # Load and check the event properties
        event_properties = BranchIO::EventProperties.wrap(options)

        # Build the request
        defaults = {
            sdk: :api,
            branch_key: self.branch_key
        }
        event_json = defaults.merge(event_properties.as_json)

        # Call branch.io public API
        raw_response = self.post(path, event_json)

        # Wrap the result in a Response
        if raw_response.success?
          UrlResponse.new(raw_response)
        else
          ErrorResponse.new(raw_response)
        end
      end
    end
  end
end
