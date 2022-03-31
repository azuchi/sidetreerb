module Sidetree

  class Key

    attr_reader :private_key, :public_key, :id, :purpose

    # @param [Integer] private_key private key.
    # @param [ECDSA::Point] public_key public key
    def initialize(private_key: nil, public_key: nil, id: nil, purpose: nil)
      if private_key
        raise Error, 'private key is invalid range.' unless Key.valid_private_key?(private_key)

        @private_key = private_key
        pub = ECDSA::Group::Secp256k1.generator.multiply_by_scalar(private_key)
        if public_key
          raise Error, 'Public and private keys do not match.' unless pub == public_key
        else
          public_key = pub
        end
      end

      raise Error, 'Specify either the private key or the public key' unless public_key
      raise Error, 'public key must be an ECDSA::Point instance.' unless public_key.is_a?(ECDSA::Point)
      raise Error, 'public key is invalid.' unless ECDSA::Group::Secp256k1.valid_public_key?(public_key)

      @public_key = public_key

      raise Error, "Unknown purpose '#{purpose}' specified." if purpose && !PublicKeyPurpose.values.include?(purpose)

      @purpose = purpose
      @id = id
    end

    # Generate Secp256k1 key.
    # @option [String] id Public key ID.
    # @option [String] purpose Purpose for public key. Supported values defined by [Sidetree::PublicKeyPurpose].
    # @return [Sidetree::Key]
    # @raise [Sidetree::Error]
    def self.generate(id: nil, purpose: nil)
      private_key = 1 + SecureRandom.random_number(ECDSA::Group::Secp256k1.order - 1)
      Key.new(private_key: private_key, purpose: purpose, id: id)
    end

    # Generate key instance from jwk Hash.
    # @param [Hash] jwk_hash jwk Hash object.
    # @return [Sidetree::Key]
    # @raise [Sidetree::Error]
    def self.from_hash(jwk_hash)
      key_type = jwk_hash['kty']
      curve = jwk_hash['crv']
      raise Error, "Unsupported key type '#{key_type}' specified." if key_type.nil? || key_type != 'EC'
      raise Error, "Unsupported curve '#{curve}' specified." if curve.nil? || curve != 'secp256k1'
      raise Error, 'x property required.' unless jwk_hash['x']
      raise Error, 'y property required.' unless jwk_hash['y']

      x = Base64.urlsafe_decode64(jwk_hash['x'])
      y = Base64.urlsafe_decode64(jwk_hash['y'])
      point = ECDSA::Format::PointOctetString.decode(['04'].pack('H*') + x + y, ECDSA::Group::Secp256k1)
      private_key = jwk_hash['d'] ? Base64.urlsafe_decode64(jwk_hash['d']).unpack1('H*').to_i(16) : nil

      Key.new(public_key: point, private_key: private_key)
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
        kty: 'EC',
        crv: 'secp256k1',
        x: Base64.urlsafe_encode64(ECDSA::Format::FieldElementOctetString.encode(public_key.x, public_key.group.field), padding: false),
        y: Base64.urlsafe_encode64(ECDSA::Format::FieldElementOctetString.encode(public_key.y, public_key.group.field), padding: false)
      )
    end

  end

end