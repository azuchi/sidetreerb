require "securerandom"
require "uri"
require "net/http"

module Sidetree
  module CAS
    class IPFS
      attr_reader :base_url
      attr_reader :fetch_timeout

      # @raise [Sidetree::Error]
      def initialize(
        schema: "http",
        host: "localhost",
        port: 5001,
        base_path: "/api/v0",
        fetch_timeout: nil
      )
        @base_url = "#{schema}://#{host}:#{port}#{base_path}"
        @fetch_timeout = fetch_timeout
        raise Sidetree::Error, "Failed to connect to IPFS endpoint." unless up?
      end

      # Writes the given content to CAS.
      # @return [String] SHA256 hash in base64url encoding which represents the address of the content.
      # @raise [Sidetree::Error] If IPFS write fails
      def write(content)
        multipart_boundary = SecureRandom.hex(32)
        uri = URI("#{base_url}/add")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == "https"
        req = Net::HTTP::Post.new(uri)
        req[
          "Content-Type"
        ] = "multipart/form-data; boundary=#{multipart_boundary}"
        req.body = build_body(multipart_boundary, content)
        res = http.request(req)
        if res.is_a?(Net::HTTPSuccess)
          results = JSON.parse(res.body)
          results["Hash"]
        else
          raise Sidetree::Error, "Failed writing content. #{res.body}"
        end
      end

      # Get content from IPFS.
      # @param [String] addr cas uri.
      # @param [Integer] max_bytesize The maximum allowed size limit of the content.
      # @return [Sidetree::CAS::FetchResult] Fetch result containing the content if found.
      # The result code is set to FetchResultCode.MaxSizeExceeded if the content exceeds the +max_bytesize+.
      def read(addr, max_bytesize: nil)
        fetch_url = "#{base_url}/cat?arg=#{addr}"
        fetch_url += "&length=#{max_bytesize + 1}" if max_bytesize
        res = Net::HTTP.post_form(URI(fetch_url), {})
        if res.is_a?(Net::HTTPSuccess)
          FetchResult.new(FetchResult::CODE_SUCCESS, res.body)
        else
          FetchResult.new(FetchResult::CODE_INVALID_HASH, res.body)
        end
      end

      # Get node information from IPFS endpoint.
      # @return [String] node information.
      def id
        res = Net::HTTP.post_form(URI("#{base_url}/id"), {})
        res.body if res.is_a?(Net::HTTPSuccess)
      end

      # Check IPFS endpoint are up and running.
      # @return [Boolean]
      def up?
        begin
          id
          true
        rescue Errno::ECONNREFUSED
          false
        end
      end

      private

      # Fetch content from IPFS.
      def fetch(uri, max_bytesize: nil)
      end

      def build_body(boundary, content)
        begin_boundary = "--#{boundary}\n"
        field_name = "file"
        first_part_content_type =
          "Content-Disposition: form-data; name=\"#{field_name}\"; filename=\"\"\n"
        first_part_content_type += "Content-Type: application/octet-stream\n\n"
        end_boundary = "\n--#{boundary}--\n"
        begin_boundary + first_part_content_type + content + "\n" + end_boundary
      end
    end
  end
end
