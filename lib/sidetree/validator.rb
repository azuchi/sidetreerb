module Sidetree
  module Validator
    module_function

    # @param [Hash] delta delta object.
    # @return [Sidetree::Error]
    def validate_delta!(delta)
      raise Error, 'Delta does not defined.' unless delta
      delta_size = delta.to_json_c14n.bytesize
      if delta_size > Sidetree::Params::MAX_DELTA_SIZE
        raise Error,
              "#{delta_size} bytes of 'delta' exceeded limit of #{Sidetree::Params::MAX_DELTA_SIZE} bytes."
      end

      if delta.instance_of?(Array)
        raise Error, 'Delta object cannot be an array.'
      end
      delta.keys.each do |k|
        unless %w[patches updateCommitment].include?(k.to_s)
          raise Error, "Property '#{k}' is not allowed in delta object."
        end
      end

      unless delta[:patches].instance_of?(Array)
        raise Error, 'Patches object in delta must be an array.'
      end
      delta[:patches].each { |p| validate_patch!(p) }

      validate_encoded_multi_hash!(delta[:updateCommitment], 'updateCommitment')
    end

    # @param [Hash] patch patch object.
    # @raise [Sidetree::Error]
    def validate_patch!(patch)
      case patch[:action]
      when OP::PatchAction::REPLACE
        validate_document!(patch[:document])
      when OP::PatchAction::ADD_PUBLIC_KEYS
        validate_add_public_keys_patch!(patch)
      when OP::PatchAction::REMOVE_PUBLIC_KEYS
        validate_remove_public_keys_patch!(patch)
      when OP::PatchAction::ADD_SERVICES
        validate_add_services_patch!(patch)
      when OP::PatchAction::REMOVE_SERVICES
        validate_remove_services_patch!(patch)
      else
        raise Error, "#{patch[:action]} is unknown patch action."
      end
    end

    def validate_document!(document)
      raise Error, 'Document object missing in patch object' unless document
      document.keys.each do |k|
        unless %w[publicKeys services].include?(k.to_s)
          raise Error, "Property '#{k}' is not allowed in document object."
        end
      end
      validate_public_keys!(document[:publicKeys]) if document[:publicKeys]
      validate_services!(document[:services]) if document[:services]
    end

    def validate_add_public_keys_patch!(patch)
      unless patch.keys.length == 2
        raise Error, 'Patch missing or unknown property.'
      end
      validate_public_keys!(patch[:publicKeys])
    end

    def validate_remove_public_keys_patch!(patch)
      patch.keys.each do |k|
        unless %w[action ids].include?(k.to_s)
          raise Error, "Unexpected property '#{k}' in remove-public-keys patch."
        end
      end
      unless patch[:ids].instance_of?(Array)
        raise Error, 'Patch public key ids not an array.'
      end

      patch[:ids].each { |id| validate_id!(id) }
    end

    def validate_add_services_patch!(patch)
      unless patch.keys.length == 2
        raise Error, 'Patch missing or unknown property.'
      end
      unless patch[:services].instance_of?(Array)
        raise Error, 'Patch services not an array.'
      end
      validate_services!(patch[:services])
    end

    def validate_remove_services_patch!(patch)
      patch.keys.each do |k|
        unless %w[action ids].include?(k.to_s)
          raise Error, "Unexpected property '#{k}' in remove-services patch."
        end
      end
      unless patch[:ids].instance_of?(Array)
        raise Error, 'Patch service ids not an array.'
      end

      patch[:ids].each { |id| validate_id!(id) }
    end

    def validate_public_keys!(public_keys)
      unless public_keys.instance_of?(Array)
        raise Error, 'publicKeys must be an array.'
      end
      pubkey_ids = []
      public_keys.each do |public_key|
        public_key.keys.each do |k|
          unless %w[id type purposes publicKeyJwk].include?(k.to_s)
            raise Error, "Property '#{k}' is not allowed in publicKeys object."
          end
        end
        if public_key[:publicKeyJwk].instance_of?(Array)
          raise Error, 'publicKeyJwk object cannot be an array.'
        end
        if public_key[:type] && !public_key[:type].is_a?(String)
          raise Error, "Public key type #{public_key[:type]} is incorrect."
        end

        validate_id!(public_key[:id])

        if pubkey_ids.include?(public_key[:id])
          raise Error, 'Public key id is duplicated.'
        end
        pubkey_ids << public_key[:id]

        if public_key[:purposes]
          unless public_key[:purposes].instance_of?(Array)
            raise Error, 'purposes must be an array.'
          end
          unless public_key[:purposes].count == public_key[:purposes].uniq.count
            raise Error, 'purpose is duplicated.'
          end
          public_key[:purposes].each do |purpose|
            unless OP::PublicKeyPurpose.values.include?(purpose)
              raise Error, "purpose #{} is invalid."
            end
          end
        end
      end
    end

    def validate_services!(services)
      unless services.instance_of?(Array)
        raise Error, 'services must be an array.'
      end

      service_ids = []
      services.each do |service|
        unless service.keys.length == 3
          raise Error, 'Service has missing or unknown property.'
        end

        validate_id!(service[:id])

        if service_ids.include?(service[:id])
          raise Error, 'Service id has to be unique.'
        end
        service_ids << service[:id]

        unless service[:type].is_a?(String)
          raise Error, "Service type #{service[:type]} is incorrect."
        end
        raise Error, 'Service type too long.' if service[:type].length > 30

        endpoint = service[:serviceEndpoint]
        if endpoint.instance_of?(String)
          validate_uri!(endpoint)
        elsif endpoint.instance_of?(Hash)

        else
          raise Error, 'ServiceEndpoint must be string or object.'
        end
      end
    end

    def valid_base64_encoding?(base64)
      /^[A-Za-z0-9_-]+$/.match?(base64)
    end

    # Validate uri
    # @param [String] uri uri
    # @return [Sidetree::Error] Occurs if it is an incorrect URI
    def validate_uri!(uri)
      begin
        URI.parse(uri)
        unless uri =~ /\A#{URI.regexp(%w[http https])}\z/
          raise Error, "URI string '#{uri}' is not a valid URI."
        end
      rescue StandardError
        raise Error, "URI string '#{uri}' is not a valid URI."
      end
    end

    def validate_id!(id)
      raise Error, 'id does not string.' unless id.instance_of?(String)
      raise Error, 'id is too long.' if id.length > 50
      unless valid_base64_encoding?(id)
        raise Error, 'id does not use base64url character set.'
      end
    end

    def validate_encoded_multi_hash!(multi_hash, target)
      begin
        decoded = Multihashes.decode(Base64.urlsafe_decode64(multi_hash))
        unless Params::HASH_ALGORITHM.include?(decoded[:code])
          raise Error,
                "Given #{target} uses unsupported multihash algorithm with code #{decoded[:code]}."
        end
      rescue StandardError
        raise Error,
              "Given #{target} string '#{multi_hash}' is not a multihash."
      end
    end

    def validate_did_type!(type)
      return unless type
      raise Error, 'DID type must be a string.' unless type.instance_of?(String)
      if type.length > 4
        raise Error,
              "DID type string '#{type}' cannot be longer than 4 characters."
      end
      unless valid_base64_encoding?(type)
        raise Error,
              "DID type string '#{type}' contains a non-Base64URL character."
      end
    end

    def validate_suffix_data!(suffix)
      if suffix.instance_of?(Array)
        raise Error, 'Suffix data can not be an array.'
      end
      suffix.keys.each do |k|
        unless %w[deltaHash recoveryCommitment type].include?(k.to_s)
          raise Error, "Property '#{k}' is not allowed in publicKeys object."
        end
      end
      validate_encoded_multi_hash!(suffix[:deltaHash], 'delta hash')
      validate_encoded_multi_hash!(
        suffix[:recoveryCommitment],
        'recovery commitment'
      )
      validate_encoded_multi_hash!(suffix[:deltaHash], 'delta hash')
      validate_did_type!(suffix[:type])
    end
  end
end
