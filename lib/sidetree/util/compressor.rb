require "zlib"

module Sidetree
  module Util
    module Compressor
      module_function

      # Compresses teh data in gzip and return it as buffer.
      # @param [String] data Data to be compressed.
      # @return [String] compressed data.
      def compress(data)
        io = StringIO.new("w")
        Zlib::GzipWriter.wrap(io) do |w|
          w.mtime = 0
          w.write data
        end
        io.string
      end

      # Decompresses +compressed+.
      # @param [String] compressed compressed data.
      # @return [String] decompressed data.
      # @raise [Sidetree::Error] raise if data exceeds max_bytes size.
      def decompress(compressed, max_bytes: nil)
        if max_bytes && compressed.bytesize > max_bytes
          raise Sidetree::Error, "Exceed maximum compressed chunk file size."
        end
        io = StringIO.new(compressed)
        result = StringIO.new
        Zlib::GzipReader.wrap(io) { |gz| result << gz.read }
        result.string
      end
    end
  end
end
