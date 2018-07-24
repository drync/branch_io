require_relative "response"

module BranchIO
  class Client
    module Events
      STANDARD_EVENT_LINK_PATH = "/v2/event/standard"
      CUSTOM_EVENT_LINK_PATH = "/v2/event/custom"
      # See: https://docs.branch.io/pages/apps/v2event/#available-events
      STANDARD_EVENT_NAMES = [
        "ADD_TO_CART",            # Commerce Event
        "ADD_TO_WISHLIST",        # Commerce Event
        "VIEW_CART",              # Commerce Event
        "INITIATE_PURCHASE",      # Commerce Event
        "ADD_PAYMENT_INFO",       # Commerce Event
        "PURCHASE",               # Commerce Event
        "SPEND_CREDITS",          # Commerce Event
        "SEARCH",                 # Content Event
        "VIEW_ITEM",              # Content Event
        "VIEW_ITEMS",             # Content Event
        "RATE",                   # Content Event
        "SHARE",                  # Content Event
        "COMPLETE_REGISTRATION",  # Lifecycle Event
        "COMPLETE_TUTORIAL",      # Lifecycle Event
        "ACHIEVE_LEVEL",          # Lifecycle Event
        "UNLOCK_ACHIEVEMENT"      # Lifecycle Event
      ]

      def event!(options = {})
        res = event(options)
        res.validate!
        res
      end

      def event(options = {})
        # Load and check the event properties
        event_properties = BranchIO::EventProperties.wrap(options)

        # Build the request
        defaults = {
            sdk: :api,
            branch_key: self.branch_key
        }
        event_json = defaults.merge(event_properties.as_json)

        # Determine standard vs custom event
        event_name = event_json[:name] || ""
        path = if STANDARD_EVENT_NAMES.include?(event_name)
          STANDARD_EVENT_LINK_PATH
        else
          CUSTOM_EVENT_LINK_PATH
        end

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
