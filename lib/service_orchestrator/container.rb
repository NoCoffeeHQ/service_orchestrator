# frozen_string_literal: true

module ServiceOrchestrator
  # Strongly inspired by https://github.com/bkeepers/morphine (MIT).
  # Copying/pasting/modifying the code from Morphine seemed
  # the cleaner solution.
  class Container
    def dependencies
      @dependencies ||= {}
    end

    def self.register(name, klass = nil, &block)
      if klass && !klass.respond_to?(:build_and_wire)
        raise ServiceOrchestrator::Error, "#{klass} should implement the build_and_wire class method"
      end

      define_method name do |*args|
        dependencies[name] ||= klass ? klass.build_and_wire(self) : instance_exec(*args, &block)
      end

      define_method "#{name}=" do |service|
        dependencies[name] = service
      end
    end
  end
end
