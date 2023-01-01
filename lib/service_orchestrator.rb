# frozen_string_literal: true

require 'active_support/core_ext/class/attribute'

require_relative 'service_orchestrator/version'
require_relative 'service_orchestrator/container'
require_relative 'service_orchestrator/service'

module ServiceOrchestrator
  class Error < StandardError; end
end
