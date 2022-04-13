module Sidetree
  module Model
    # DID document class.
    class Document
      attr_reader :public_keys
      attr_reader :services

      # @param [Array[Sidetree::Key]] public_keys The array of public keys.
      # @param [Array[Sidetree::Model::Service]] services The array of service.
      def initialize(public_keys: [], services: [])
        public_keys.each do |public_key|
          raise Error, 'public_keys should be array of Sidetree::Key objects.' unless public_key.is_a?(Sidetree::Key)
        end
        id_set = public_keys.map(&:id)
        raise Error 'Public key id has to be unique.' if (id_set.count - id_set.uniq.count) > 0
        services.each do |service|
          raise Error, 'services should be array of Sidetree::Model::Service objects.' unless service.is_a?(Sidetree::Model::Service)
        end
        id_set = services.map(&:id)
        raise Error 'Service id has to be unique.' if (id_set.count - id_set.uniq.count) > 0

        @public_keys = public_keys
        @services = services
      end

      def to_h
        {
          publicKeys: public_keys.map(&:to_h),
          services: services.map(&:to_h)
        }
      end

    end
  end
end
