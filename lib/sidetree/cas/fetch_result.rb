module Sidetree
  module CAS
    class FetchResult
      CODE_CAS_NOT_REACHABLE = "cas_not_reachable"
      CODE_INVALID_HASH = "content_hash_invalid"
      CODE_MAX_SIZE_EXCEEDED = "content_exceeds_maximum_allowed_size"
      CODE_NOT_FILE = "content_not_a_file"
      CODE_NOT_FOUND = "content_not_found"
      CODE_SUCCESS = "success"

      attr_reader :code
      attr_reader :content

      def initialize(code, content = nil)
        @code = code
        @content = content
      end
    end
  end
end
