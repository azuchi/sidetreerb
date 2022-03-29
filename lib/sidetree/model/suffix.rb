module Sidetree
  module Model
    class Suffix
      attr_reader :delta_hash, :recovery_commitment

      def initialize(delta_hash, recovery_commitment)
        @delta_hash = delta_hash
        @recovery_commitment = recovery_commitment
      end

      def self.parse(object)
        Sidetree::OP::Validator.validate_suffix_data!(object)
        Suffix.new(object[:deltaHash], object[:recoveryCommitment])
      end

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