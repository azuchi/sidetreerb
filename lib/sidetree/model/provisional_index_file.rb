module Sidetree
  module Model
    # https://identity.foundation/sidetree/spec/#provisional-index-file
    class ProvisionalIndexFile
      attr_reader :provisional_proof_file_uri
      attr_reader :chunks
      attr_reader :operations

      def initialize(proof_file_uri: nil, chunks: [], operations: [])
        @provisional_proof_file_uri = proof_file_uri
        @chunks = chunks
        @operations = operations
      end

      # Create ProvisionalIndexFile
      # @param [String]
      # @return [Sidetree::Model::ProvisionalIndexFile]
      def self.create(chunk_file_uri, proof_file_uri: nil, update_ops: [])
        update_refs =
          update_ops.map do |update|
            # TODO
          end
        ProvisionalIndexFile.new(
          chunks: [chunk_file_uri],
          operations: update_refs,
          proof_file_uri: proof_file_uri
        )
      end

      # Parse provisional index file.
      # @param [String] index_data provisional index file data.
      # @param [Boolean] compressed Whether the chunk_file is compressed or not, default: true.
      # @return [Sidetree::Model::ProvisionalIndexFile]
      def self.parse(index_data, compressed: true)
        decompressed =
          (
            if compressed
              Sidetree::Util::Compressor.decompress(
                index_data,
                max_bytes: Sidetree::Params::MAX_PROVISIONAL_INDEX_FILE_SIZE
              )
            else
              index_data
            end
          )
        json = JSON.parse(decompressed, symbolize_names: true)
      end
    end
  end
end
