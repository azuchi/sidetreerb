module Sidetree
  module Model
    class Delta
      attr_reader :patches, :update_commitment

      # @param [Array[Hash]] patches
      # @param [String] update_commitment
      # @raise [Sidetree::Error]
      def initialize(patches, update_commitment)
        @patches = patches
        @update_commitment = update_commitment
      end

      def self.parse(object)
        Sidetree::Validator.validate_delta!(object)
        Delta.new(object[:patches], object[:updateCommitment])
      end

      def to_h
        { patches: patches, updateCommitment: update_commitment }
      end

      def to_hash
        Sidetree.to_hash(to_h)
      end

      def ==(other)
        return false unless other.is_a?(Delta)
        to_hash == other.to_hash
      end
    end
  end
end
