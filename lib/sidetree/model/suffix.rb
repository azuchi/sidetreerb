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

      def unique_suffix
        digest = Digest::SHA256.digest(to_h.to_json_c14n)
        multi_hash = Multihashes.encode(digest, 'sha2-256') # TODO Need to decide on what hash algorithm to use when hashing suffix data - https://github.com/decentralized-identity/sidetree/issues/965
        Base64.urlsafe_encode64(multi_hash, padding: false)
      end
    end
  end
end