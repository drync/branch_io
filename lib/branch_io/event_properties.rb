module BranchIO
  class EventProperties
    attr_reader :branch_key
    attr_reader :name
    attr_reader :user_data
    attr_reader :custom_data
    attr_reader :event_data
    attr_reader :content_items
    attr_reader :metadata

    def self.wrap(options)
      if options.kind_of?(EventProperties)
        options
      else
        new(options)
      end
    end

    def initialize(options = {})
      @branch_key     = options.delete(:branch_key)     || options.delete("branch_key")
      @name           = options.delete(:name)           || options.delete("name")
      @user_data      = options.delete(:user_data)      || options.delete("user_data")
      @custom_data    = options.delete(:custom_data)    || options.delete("custom_data")
      @event_data     = options.delete(:event_data)     || options.delete("event_data")
      @content_items  = options.delete(:content_items)  || options.delete("content_items")
      @metadata       = options.delete(:metadata)       || options.delete("metadata")

      unless options.empty?
        raise ErrorInvalidParameters, options.keys
      end
    end

    def as_json
      json = {}
      json[:branch_key]    = branch_key if branch_key
      json[:name]          = name if name
      json[:user_data]     = user_data if user_data
      json[:custom_data]   = custom_data if custom_data
      json[:event_data]    = event_data if event_data
      json[:content_items] = content_items if content_items
      json[:metadata]      = metadata if metadata
      json
    end

    class ErrorInvalidParameters < StandardError
      attr_reader :parameters
      def initialize(parameters)
        @parameters = parameters
        super("Invalid parameters for BranchIO::EventProperties: \"#{@parameters.join(', ')}\"")
      end
    end
  end
end
