# frozen_string_literal: true

module Opal
  module Rails
    class Error < StandardError; end

    class MissingEntrypointError < Error; end
    class DuplicateEntrypointError < Error; end
    class InvalidEntrypointsConfigError < Error; end
  end
end
