# frozen_string_literal: true

require_relative "sidetree/version"
require 'ecdsa'
require 'json/jwt'
require 'base64'
require 'json'
require 'json/canonicalization'

module Sidetree
  class Error < StandardError; end

  autoload :Key, 'sidetree/key'
  autoload :DID, 'sidetree/did'
  autoload :Model, 'sidetree/model'
  autoload :OP, 'sidetree/op'

  module Params
    # Algorithm for generating hashes of protocol-related values. 0x12 = sha2-256
    HASH_ALGORITHM = [0x12]
    # Maximum canonicalized operation delta buffer size.
    MAX_DELTA_SIZE = 1000
  end
end
