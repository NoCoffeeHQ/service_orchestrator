# frozen_string_literal: true

module ServiceOrchestrator
  # In order to wire automatically dependencies in the services
  # registered within a Container, the services has to inherit
  # from this class.
  class Service
    class_attribute :registered_deps

    def self.dependencies(*names)
      names.each do |name|
        dependency(name)
      end
    end

    def self.dependency(name)
      self.registered_deps ||= []
      self.registered_deps += [name]
      attr_accessor name
    end

    def self.wire(container)
      args = {}
      (self.registered_deps || []).each do |name|
        args[name] = container.send(name)
      end
      new(args)
    end

    def initialize(args)
      args.each do |name, value|
        instance_variable_set(:"@#{name}", value)
      end
    end
  end
end
