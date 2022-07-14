module Sidetree
  module OP
    module Type
      CREATE = "create"
      UPDATE = "update"
      RECOVER = "recover"
      DEACTIVATE = "deactivate"
    end

    # Sidetree patch actions. These are the valid values in the action property of a patch.
    module PatchAction
      REPLACE = "replace"
      ADD_PUBLIC_KEYS = "add-public-keys"
      REMOVE_PUBLIC_KEYS = "remove-public-keys"
      ADD_SERVICES = "add-services"
      REMOVE_SERVICES = "remove-services"
    end

    # DID Document public key purpose.
    module PublicKeyPurpose
      AUTHENTICATION = "authentication"
      ASSERTION_METHOD = "assertionMethod"
      CAPABILITY_INVOCATION = "capabilityInvocation"
      CAPABILITY_DELEGATION = "capabilityDelegation"
      KEY_AGREEMENT = "keyAgreement"

      module_function

      def values
        PublicKeyPurpose.constants.map { |c| PublicKeyPurpose.const_get(c) }
      end
    end

    autoload :Base, "sidetree/op/base"
    autoload :Create, "sidetree/op/create"
    autoload :Recover, "sidetree/op/recover"
    autoload :Update, "sidetree/op/update"
    autoload :Deactivate, "sidetree/op/deactivate"
  end
end
