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
      # @param [String] chunk_file compressed chunk file data.
      # @param [Boolean] compressed Whether the chunk_file is compressed or not, default: true.
      # @return [Sidetree::Model::ChunkFile]
      # @raise [Sidetree::Error]
      def self.parse(chunk_file, compressed: true)
        max_bytes =
          Sidetree::Params::MAX_CHUNK_FILE_SIZE *
            Sidetree::Util::Compressor::ESTIMATE_DECOMPRESSION_MULTIPLIER
        decompressed =
          (
            if compressed
              Sidetree::Util::Compressor.decompress(
                chunk_file,
                max_bytes: max_bytes
              )
            else
              chunk_file
            end
          )
        json = JSON.parse(decompressed, symbolize_names: true)
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

      # Compress this chunk file
      # @return [String] compressed data.
      def to_compress
        params = { deltas: deltas.map(&:to_h) }
        Sidetree::Util::Compressor.compress(params.to_json)
      end

      # Check if the +other+ object have the same chunk data.
      # @return [Boolean]
      def ==(other)
        return false unless other.is_a?(ChunkFile)
        deltas == other.deltas
      end
    end
  end
end
