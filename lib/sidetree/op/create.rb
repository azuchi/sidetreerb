module Sidetree
  module OP
    # Create operation class.
    class Create < Base

      attr_reader :suffix, :delta

      def initialize(suffix, delta)
        @delta = delta
        @suffix = suffix
      end

      def type
        Sidetree::OP::Type::CREATE
      end

      # Check whether suffix's delta_hash equal to hash of delta.
      # @return [Boolean] result
      def match_delta_hash?
        suffix.delta_hash == delta.to_hash
      end

      # @return [Sidetree::OP::Create] create operation.
      def self.from_base64(base64_str)
        jcs = Base64.urlsafe_decode64(base64_str)
        begin
          json = JSON.parse(jcs, symbolize_names: true)
          # validate jcs
          expected_base64 = Base64.urlsafe_encode64(json.to_json_c14n, padding: false)
          raise Error, 'Initial state object and JCS string mismatch.' unless expected_base64 == base64_str

          Create.new(Sidetree::Model::Suffix.parse(json[:suffixData]), Sidetree::Model::Delta.parse(json[:delta]))
        rescue JSON::ParserError
          raise Error, 'Long form initial state should be encoded jcs.'
        end
      end

    end
  end
end
