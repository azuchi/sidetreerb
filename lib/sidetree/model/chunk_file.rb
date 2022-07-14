module Sidetree
  module Model
    # https://identity.foundation/sidetree/spec/#chunk-files
    class ChunkFile
      attr_reader :deltas # Array of Sidetree::Model::Delta

      def initialize(deltas = [])
        deltas.each do |delta|
          unless delta.is_a?(Sidetree::Model::Delta)
            raise Sidetree::Error,
                  "deltas contains data that is not Sidetree::Model::Delta object."
          end
        end
        @deltas = deltas
      end

      # Generate chunk file from operations.
      # @param [Array[Sidetree::OP::Create]] create_ops
      # @param [Array[Sidetree::OP::Recover]] recover_ops
      # @param [Array[Sidetree::OP::Update]] update_ops
      def self.create_from_ops(create_ops: [], recover_ops: [], update_ops: [])
        deltas = create_ops.map(&:delta)
        # TODO add update and recover operation delta
        ChunkFile.new(deltas)
      end

      # Parse chunk file from compressed data.
      # @param [String] compressed compressed chunk file data.
      # @return [Sidetree::Model::ChunkFile]
      # @raise [Sidetree::Error]
      def self.parse(compressed)
        uncompressed =
          Sidetree::Util::Compressor.decompress(
            compressed,
            max_bytes: Sidetree::Params::MAX_CHUNK_FILE_SIZE
          )
        json = JSON.parse(uncompressed, symbolize_names: true)
        json.keys.each do |k|
          unless k == :deltas
            raise Sidetree::Error,
                  "Unexpected property #{k.to_s} in chunk file."
          end
        end
        unless json[:deltas].is_a?(Array)
          raise Sidetree::Error,
                "Invalid chunk file, deltas property is not an array."
        end
        ChunkFile.new(
          json[:deltas].map { |delta| Sidetree::Model::Delta.parse(delta) }
        )
      end
    end
  end
end
