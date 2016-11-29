module Blocks
  class InvalidPermissionsHandler
    LOG = :log
    RAISE = :raise

    def self.build(method_name, block_name)
      message = "Cannot #{method_name} #{block_name}; #{block_name} is not in the permitted_blocks list"
      new(message)
      nil
    end

    def initialize(message)
      send("handle_#{Blocks.invalid_permissions_approach}", message)
    end

    private

    def handle_log(message)
      Rails.logger.info message
    end

    def handle_raise(message)
      raise message
    end
  end
end