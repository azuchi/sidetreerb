# frozen_string_literal: true

require_relative "sidetree/version"
require 'ecdsa'
require 'json/jwt'
require 'base64'

module Sidetree
  class Error < StandardError; end

  autoload :Key, 'sidetree/key'

end
