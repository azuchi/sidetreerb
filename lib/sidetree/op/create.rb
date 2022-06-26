module Sidetree
  module OP
    # Create operation class.
    class Create < Base
      attr_reader :suffix, :delta

      # @param [Sidetree::Model::Suffix] suffix
      # @param [Sidetree::Model::Delta] delta
      def initialize(suffix, delta)
        @delta = delta
        @suffix = suffix
      end

      # Generate create operation with new generate key.
      # @param [String] method DID method defined in +Sidetree::Params::METHODS+.
      # @return [Sidetree::OP::Create]
      def self.generate(method: Sidetree::Params::METHODS[:ion])
        recovery_key = Sidetree::Key.generate
        update_key = Sidetree::Key.generate
        signing_key = Sidetree::Key.generate(id: "signing-key")
        document = Sidetree::Model::Document.new(public_keys: [signing_key])
        did =
          Sidetree::DID.create(
            document,
            update_key,
            recovery_key,
            method: method
          )
        did.create_op
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
          expected_base64 =
            Base64.urlsafe_encode64(json.to_json_c14n, padding: false)
          unless expected_base64 == base64_str
            raise Error, "Initial state object and JCS string mismatch."
          end

          Create.new(
            Sidetree::Model::Suffix.parse(json[:suffixData]),
            Sidetree::Model::Delta.parse(json[:delta])
          )
        rescue JSON::ParserError
          raise Error, "Long form initial state should be encoded jcs."
        end
      end

      def to_h
        { suffixData: suffix.to_h, delta: delta.to_h }
      end

      # Generate long_suffix for DID.
      # @return [String] Base64 encoded long_suffix.
      def long_suffix
        Base64.urlsafe_encode64(to_h.to_json_c14n, padding: false)
      end

      # Generate DID
      # @param [String] method DID method.
      # @param [Boolean] include_long
      # @return [String] DID
      def did(method: Sidetree::Params::DEFAULT_METHOD, include_long: false)
        did = "did:#{method}"
        did += ":#{Sidetree::Params.network}" if Sidetree::Params.testnet?
        did += ":#{suffix.unique_suffix}"
        did += ":#{long_suffix}" if include_long
        did
      end
    end
  end
end
