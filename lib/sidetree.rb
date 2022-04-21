# frozen_string_literal: true

require_relative 'sidetree/version'
require 'ecdsa'
require 'json/jwt'
require 'base64'
require 'json'
require 'json/canonicalization'
require 'uri'
require 'multihashes'

module Sidetree
  class Error < StandardError
  end

  autoload :Key, 'sidetree/key'
  autoload :DID, 'sidetree/did'
  autoload :Model, 'sidetree/model'
  autoload :OP, 'sidetree/op'
  autoload :Validator, 'sidetree/validator'

  module Params
    # Algorithm for generating hashes of protocol-related values. 0x12 = sha2-256
    HASH_ALGORITHM = [0x12]
    HASH_ALGORITH_STRING = 'sha2-256'

    # Maximum canonicalized operation delta buffer size.
    MAX_DELTA_SIZE = 1000

    # Default DID method
    DEFAULT_METHOD = 'sidetree'

    @network = nil

    def self.network=(network)
      @network = network
    end

    def self.network
      @network
    end

    module Network
      MAINNET = 'mainnet'
      TESTNET = 'test'
    end
  end

  module_function

  # Calculate Base64 encoded hash of hash object.
  # @param [Hash] data
  # @return [String] Base64 encoded hash value
  def to_hash(data)
    digest = Digest::SHA256.digest(data.is_a?(Hash) ? data.to_json_c14n : data)
    hash = Multihashes.encode(digest, Params::HASH_ALGORITH_STRING)

    # TODO Need to decide on what hash algorithm to use when hashing suffix data
    # - https://github.com/decentralized-identity/sidetree/issues/965
    Base64.urlsafe_encode64(hash, padding: false)
  end
end
