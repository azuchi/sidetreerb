module Sidetree
  class DID

    attr_reader :method
    attr_reader :suffix
    attr_reader :long_suffix

    # @raise [Sidetree::Error]
    def initialize(did)
      raise Error, 'Expected DID method not given in DID.' if !did.start_with?('did:ion:') && !did.start_with?('did:sidetree:')
      raise Error, 'Unsupported DID format.' if did.count(':') > 3

      _, @method, @suffix, @long_suffix = did.split(':')
      if @long_suffix
        raise Error, 'DID document mismatches short-form DID.' unless suffix == create_op.suffix.unique_suffix
      end
    end

    # Create DID from +document+, +update_key+ and +recovery_key+.
    # @param [Sidetree::Model::Document] document
    # @param [Sidetree::Key] update_key update key
    # @param [Sidetree::Key] recovery_key recovery key
    # @param [String] method DID method, default value is sidetree.
    # @raise [Sidetree::Error]
    # @return [String] Long-Form DID
    def self.create(document, update_key, recovery_key, method: Sidetree::Params::DEFAULT_METHOD)
      raise Error, 'document must be Sidetree::Model::Document instance.' unless document.is_a?(Sidetree::Model::Document)
      raise Error, 'update_key must be Sidetree::Key instance.' unless update_key.is_a?(Sidetree::Key)
      raise Error, 'recovery_key must be Sidetree::Key instance.' unless recovery_key.is_a?(Sidetree::Key)

      patches = [{'action': OP::PatchAction::REPLACE, 'document': document.to_h}]
      delta = Model::Delta.new(patches, update_key.to_commitment)
      suffix = Sidetree::Model::Suffix.new(delta.to_hash, recovery_key.to_commitment)
      OP::Create.new(suffix, delta).did(method: method, include_long: true)
    end

    def short_form?
      long_suffix.nil?
    end

    def long_form?
      !short_form?
    end

    def create_op
      long_form? ? OP::Create.from_base64(@long_suffix) : nil
    end

  end
end