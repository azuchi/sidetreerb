require 'uri'
require 'multihashes'

module Sidetree
  module OP
    module Validator

      module_function

      # @param [Hash] delta delta object.
      # @return [Sidetree::Error]
      def validate_delta!(delta)
        raise Error, 'Delta does not defined.' unless delta
        delta_size = delta.to_json_c14n.bytesize
        if delta_size > Sidetree::Params::MAX_DELTA_SIZE
          raise Error, "#{delta_size} bytes of 'delta' exceeded limit of #{Sidetree::Params::MAX_DELTA_SIZE} bytes."
        end

        raise Error, 'Delta object cannot be an array.' if delta.instance_of?(Array)
        delta.keys.each do |k|
          raise Error, "Property '#{k}' is not allowed in delta object." unless %w[patches updateCommitment].include?(k.to_s)
        end

        raise Error, 'Patches object in delta must be an array.' unless delta[:patches].instance_of?(Array)
        delta[:patches].each { |p| validate_patch!(p) }

        validate_encoded_multi_hash!(delta[:updateCommitment], 'updateCommitment')
      end

      # @param [Hash] patch patch object.
      # @raise [Sidetree::Error]
      def validate_patch!(patch)
        case patch[:action]
        when PatchAction::REPLACE
          validate_document!(patch[:document])
        when PatchAction::ADD_PUBLIC_KEYS
          validate_add_public_keys_patch!(patch)
        when PatchAction::REMOVE_PUBLIC_KEYS
          validate_remove_public_keys_patch!(patch)
        when PatchAction::ADD_SERVICES
          validate_add_services_patch!(patch)
        when PatchAction::REMOVE_SERVICES
          validate_remove_services_patch!(patch)
        else
          raise Error, "#{patch[:action]} is unknown patch action."
        end
      end

      def validate_document!(document)
        raise Error, 'Document object missing in patch object' unless document
        document.keys.each do |k|
          raise Error, "Property '#{k}' is not allowed in document object." unless %w[publicKeys services].include?(k.to_s)
        end
        validate_public_keys!(document[:publicKeys]) if document[:publicKeys]
        validate_services!(document[:services]) if document[:services]
      end

      def validate_add_public_keys_patch!(patch)
        raise Error, 'Patch missing or unknown property.' unless patch.keys.length == 2
        validate_public_keys!(patch[:publicKeys])
      end

      def validate_remove_public_keys_patch!(patch)
        patch.keys.each do |k|
          raise Error, "Unexpected property '#{k}' in remove-public-keys patch." unless %w[action ids].include?(k.to_s)
        end
        raise Error, 'Patch public key ids not an array.' unless patch[:ids].instance_of?(Array)

        patch[:ids].each { |id| validate_id!(id) }
      end

      def validate_add_services_patch!(patch)
        raise Error, 'Patch missing or unknown property.' unless patch.keys.length == 2
        raise Error, 'Patch services not an array.' unless patch[:services].instance_of?(Array)
        validate_services!(patch[:services])
      end

      def validate_remove_services_patch!(patch)
        patch.keys.each do |k|
          raise Error, "Unexpected property '#{k}' in remove-services patch." unless %w[action ids].include?(k.to_s)
        end
        raise Error, 'Patch service ids not an array.' unless patch[:ids].instance_of?(Array)

        patch[:ids].each { |id| validate_id!(id) }
      end

      def validate_public_keys!(public_keys)
        raise Error, 'publicKeys must be an array.' unless public_keys.instance_of?(Array)
        pubkey_ids = []
        public_keys.each do |public_key|
          public_key.keys.each do |k|
            raise Error, "Property '#{k}' is not allowed in publicKeys object." unless %w[id type purposes publicKeyJwk].include?(k.to_s)
          end
          raise Error, 'publicKeyJwk object cannot be an array.' if public_key[:publicKeyJwk].instance_of?(Array)
          raise Error, "Public key type #{public_key[:type]} is incorrect." unless public_key[:type] == 'string'

          validate_id!(public_key[:id])

          raise Error, 'Public key id is duplicated.' if pubkey_ids.include?(id)
          pubkey_ids << id

          if public_key[:purposes]
            raise Error, 'purposes must be an array.' unless public_key[:purposes].instance_of?(Array)
            raise Error, 'purpose is duplicated.' unless public_key[:purposes].count == public_key[:purposes].uniq.count
            public_key[:purposes].each do |purpose|
              raise Error, "purpose #{} is invalid." unless PublicKeyPurpose.values.include?(purpose)
            end
          end
        end
      end

      def validate_services!(services)
        raise Error, 'services must be an array.' unless services.instance_of?(Array)

        service_ids = []
        services.each do |service|
          raise Error, 'Service has missing or unknown property.' unless service.keys.length == 3

          validate_id!(service[:id])

          raise Error, 'Service id has to be unique.' if service_ids.include?(service[:id])
          service_ids << service[:id]

          raise Error, "Service type #{service[:type]} is incorrect." unless service[:type] == 'string'
          raise Error, 'Service type too long.' if service[:type].length > 30

          endpoint = service[:serviceEndpoint]
          if endpoint.instance_of?(String)
            begin
              URI.parse(endpoint)
            rescue
              raise Error, "Service endpoint string '#{endpoint}' is not a valid URI."
            end
          elsif endpoint.instance_of?(Hash)
          else
            raise Error, 'ServiceEndpoint must be string or object.'
          end
        end
      end

      def valid_base64_encoding?(base64)
        /^[A-Za-z0-9_-]+$/.match?(base64)
      end

      def validate_id!(id)
        raise Error, 'id does not string.' unless id.instance_of?(String)
        raise Error, 'id is too long.' if id.length > 50
        raise Error, 'id does not use base64url character set.' unless valid_base64_encoding?(id)
      end

      def validate_encoded_multi_hash!(multi_hash, target)
        begin
          decoded =  Multihashes.decode(Base64.urlsafe_decode64(multi_hash))
          unless Params::HASH_ALGORITHM.include?(decoded[:code])
            raise Error, "Given #{target} uses unsupported multihash algorithm with code #{decoded[:code]}."
          end
        rescue
          raise Error, "Given #{target} string '#{multi_hash}' is not a multihash."
        end
      end

      def validate_did_type!(type)
        return unless type
        raise Error, 'DID type must be a string.' unless type.instance_of?(String)
        raise Error, "DID type string '#{type}' cannot be longer than 4 characters." if type.length > 4
        raise Error, "DID type string '#{type}' contains a non-Base64URL character." unless valid_base64_encoding?(type)
      end

      def validate_suffix_data!(suffix)
        raise Error, 'Suffix data can not be an array.' if suffix.instance_of?(Array)
        suffix.keys.each do |k|
          raise Error, "Property '#{k}' is not allowed in publicKeys object." unless %w[deltaHash recoveryCommitment type].include?(k.to_s)
        end
        validate_encoded_multi_hash!(suffix[:deltaHash], 'delta hash')
        validate_encoded_multi_hash!(suffix[:recoveryCommitment], 'recovery commitment')
        validate_encoded_multi_hash!(suffix[:deltaHash], 'delta hash')
        validate_did_type!(suffix[:type])
      end
    end
  end
end