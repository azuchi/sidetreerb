module Sidetree
  module OP
    # Update operation class. TODO implementation
    class Update < Base
      def type
        Sidetree::OP::Type::UPDATE
      end
    end
  end
end
