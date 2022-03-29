module Sidetree
  module OP
    class Base

      # Return operation type.
      # @return [String] see Sidetree::OP::Type
      def type
        raise NotImplementedError
      end

    end
  end
end