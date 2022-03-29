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