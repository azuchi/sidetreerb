module Sidetree
  module Model
    class Service

      MAX_TYPE_LENGTH = 30

      attr_reader :id       # String
      attr_reader :type     # String
      attr_reader :endpoint # URI string or JSON object

      # @raise [Sidetree::Error]
      def initialize(id, type, endpoint)
        Sidetree::OP::Validator.validate_id!(id)
        raise Error, 'type should be String.' unless type.is_a?(String)
        raise Error, "Service endpoint type length #{type.length} exceeds max allowed length of #{MAX_TYPE_LENGTH}." if type.length > MAX_TYPE_LENGTH
        raise Error, 'Service endpoint value cannot be an array.' if endpoint.is_a?(Array)

        Sidetree::OP::Validator.validate_uri!(endpoint) if endpoint.is_a?(String)
        @id = id
        @type = type
        @endpoint = endpoint
      end

      # Generate service from json object.
      # @param [Hash] data Hash params.
      # @option data [String] :id id
      # @option data [String] :type type
      # @option data [String || Object] :endpoint endpoint url
      # @raise [Sidetree::Error]
      # @return [Sidetree::Model::Service]
      def self.from_hash(data)
        Service.new(data['id'], data['type'], data['serviceEndpoint'])
      end

      # Convert data to Hash object.
      # @return [Hash]
      def to_h
        hash = {}
        hash['id'] = id if id
        hash['type'] = type if type
        hash['serviceEndpoint'] = endpoint if endpoint
        hash
      end
    end
  end
end