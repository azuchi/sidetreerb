module Sidetree
  class Key
    attr_reader :private_key, :public_key, :id, :purposes, :type

    # @param [Integer] private_key private key.
    # @param [ECDSA::Point] public_key public key
    # @param [String] id
    # @param [Array[String]] purposes
    # @param [String] type
    def initialize(
      private_key: nil,
      public_key: nil,
      id: nil,
      purposes: [],
      type: nil
    )
      if private_key
        unless Key.valid_private_key?(private_key)
          raise Error, 'private key is invalid range.'
        end

        @private_key = private_key
        pub = ECDSA::Group::Secp256k1.generator.multiply_by_scalar(private_key)
        if public_key
          unless pub == public_key
            raise Error, 'Public and private keys do not match.'
          end
        else
          public_key = pub
        end
      end

      unless public_key
        raise Error, 'Specify either the private key or the public key'
      end
      unless public_key.is_a?(ECDSA::Point)
        raise Error, 'public key must be an ECDSA::Point instance.'
      end
      unless ECDSA::Group::Secp256k1.valid_public_key?(public_key)
        raise Error, 'public key is invalid.'
      end

      @public_key = public_key

      purposes.each do |purpose|
        if purpose && !Sidetree::OP::PublicKeyPurpose.values.include?(purpose)
          raise Error, "Unknown purpose '#{purpose}' specified."
        end
      end

      Sidetree::Validator.validate_id!(id) if id

      @purposes = purposes
      @id = id
      @type = type
    end

    # Generate Secp256k1 key.
    # @option [String] id Public key ID.
    # @option [String] purpose Purpose for public key. Supported values defined by [Sidetree::PublicKeyPurpose].
    # @return [Sidetree::Key]
    # @raise [Sidetree::Error]
    def self.generate(id: nil, purposes: [])
      private_key =
        1 + SecureRandom.random_number(ECDSA::Group::Secp256k1.order - 1)
      Key.new(private_key: private_key, purposes: purposes, id: id)
    end

    # Generate key instance from jwk Hash.
    # @param [Hash] data jwk Hash object.
    # @return [Sidetree::Key]
    # @raise [Sidetree::Error]
    def self.from_hash(data)
      key_data = data['publicKeyJwk'] ? data['publicKeyJwk'] : data
      key_type = key_data['kty']
      curve = key_data['crv']
      if key_type.nil? || key_type != 'EC'
        raise Error, "Unsupported key type '#{key_type}' specified."
      end
      if curve.nil? || curve != 'secp256k1'
        raise Error, "Unsupported curve '#{curve}' specified."
      end
      raise Error, 'x property required.' unless key_data['x']
      raise Error, 'y property required.' unless key_data['y']

      # `x` and `y` need 43 Base64URL encoded bytes to contain 256 bits.
      unless key_data['x'].length == 43
        raise Error, "Secp256k1 JWK 'x' property must be 43 bytes."
      end
      unless key_data['y'].length == 43
        raise Error, "Secp256k1 JWK 'y' property must be 43 bytes."
      end

      x = Base64.urlsafe_decode64(key_data['x'])
      y = Base64.urlsafe_decode64(key_data['y'])
      point =
        ECDSA::Format::PointOctetString.decode(
          ['04'].pack('H*') + x + y,
          ECDSA::Group::Secp256k1
        )
      private_key =
        if key_data['d']
          Base64.urlsafe_decode64(key_data['d']).unpack1('H*').to_i(16)
        else
          nil
        end

      purposes = data['purposes'] ? data['purposes'] : []
      Key.new(
        public_key: point,
        private_key: private_key,
        purposes: purposes,
        id: data['id'],
        type: data['type']
      )
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
      jwk =
        JSON::JWK.new(
          kty: 'EC',
          crv: 'secp256k1',
          x:
            Base64.urlsafe_encode64(
              ECDSA::Format::FieldElementOctetString.encode(
                public_key.x,
                public_key.group.field
              ),
              padding: false
            ),
          y:
            Base64.urlsafe_encode64(
              ECDSA::Format::FieldElementOctetString.encode(
                public_key.y,
                public_key.group.field
              ),
              padding: false
            )
        )
      jwk['d'] =
        Base64.urlsafe_encode64(
          [private_key.to_s(16).rjust(32 * 2, '0')].pack('H*')
        ) if private_key
      jwk
    end

    # Generate commitment for this key.
    # @return [String] Base64 encoded commitment.
    def to_commitment
      digest = Digest::SHA256.digest(to_jwk.normalize.to_json_c14n)

      # Digest::SHA256.digest(to_jwk.normalize.to_json_c14n)
      Sidetree.to_hash(digest)
    end

    def to_h
      h = { publicKeyJwk: to_jwk.normalize, purposes: purposes }
      h[:id] = id if id
      h[:type] = type if type
      h.stringify_keys
    end
  end
end
