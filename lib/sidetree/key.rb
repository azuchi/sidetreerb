module Sidetree

  class Key

    attr_reader :private_key, :public_key

    # @param [Integer] private_key private key.
    # @param [ECDSA::Point] public_key public key
    def initialize(private_key: nil, public_key: nil)
      if private_key
        raise Error, 'private key is invalid range.' unless Key.valid_private_key?(private_key)

        @private_key = private_key
        public_key = ECDSA::Group::Secp256k1.generator.multiply_by_scalar(private_key) unless public_key
      end

      raise Error, 'Specify either the private key or the public key' unless public_key
      raise Error, 'public key must be an ECDSA::Point instance.' unless public_key.is_a?(ECDSA::Point)
      raise Error, 'public key is invalid.' unless ECDSA::Group::Secp256k1.valid_public_key?(public_key)

      @public_key = public_key
    end

    # Generate Secp256k1 key.
    def self.generate
      private_key = 1 + SecureRandom.random_number(ECDSA::Group::Secp256k1.order - 1)
      Key.new(private_key: private_key)
    end

    # Check whether private is valid range.
    # @param [Integer] private_key
    # @return [Boolean]
    def self.valid_private_key?(private_key)
      0x01 <= private_key && private_key < ECDSA::Group::Secp256k1.order
    end

    # Generate JSON::JWK object.
    # @return [JSON::JWK]
    def to_jwk
      JSON::JWK.new(
        kty: :EC,
        crv: :secp256k1,
        x: Base64.urlsafe_encode64(ECDSA::Format::FieldElementOctetString.encode(public_key.x, public_key.group.field), padding: false),
        y: Base64.urlsafe_encode64(ECDSA::Format::FieldElementOctetString.encode(public_key.y, public_key.group.field), padding: false)
      )
    end

  end

end