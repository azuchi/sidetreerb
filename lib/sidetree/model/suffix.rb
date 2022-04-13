module Sidetree
  module Model
    class Suffix
      attr_reader :delta_hash, :recovery_commitment

      # @param [String] delta_hash Base64 encoded delta hash.
      # @param [String] recovery_commitment Base64 encoded recovery commitment.
      def initialize(delta_hash, recovery_commitment)
        @delta_hash = delta_hash
        @recovery_commitment = recovery_commitment
      end

      # Generate Suffix object from Hash object.
      # @return [Sidetree::Model::Suffix]
      # @raise [Sidetree::Error]
      def self.parse(object)
        Sidetree::Validator.validate_suffix_data!(object)
        Suffix.new(object[:deltaHash], object[:recoveryCommitment])
      end

      # Convert data to Hash object.
      # @return [Hash]
      def to_h
        {deltaHash: delta_hash, recoveryCommitment: recovery_commitment}
      end

      # Calculate unique suffix
      # @return [String] unique suffix
      def unique_suffix
        Sidetree.to_hash(to_h)
      end
    end
  end
end