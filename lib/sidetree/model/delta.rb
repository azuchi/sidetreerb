module Sidetree
  module Model
    class Delta
      attr_reader :patches, :update_commitment

      def initialize(patches, update_commitment)
        @patches = patches
        @update_commitment = update_commitment
      end

      def self.parse(object)
        Sidetree::OP::Validator.validate_delta!(object)
        Delta.new(object[:patches], object[:updateCommitment])
      end
    end
  end
end