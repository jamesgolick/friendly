require 'friendly/attribute'
require 'friendly/config'
require 'friendly/document'
require 'friendly/repository'

module Friendly
  class << self
    def configure
    end

    def config
      @config ||= Config.new
    end
  end
end
