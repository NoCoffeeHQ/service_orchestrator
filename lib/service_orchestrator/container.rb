# frozen_string_literal: true

module ServiceOrchestrator
  # Strongly inspired by https://github.com/bkeepers/morphine (MIT).
  # Copying/pasting/modifying the code from Morphine seemed the cleaner solution.
  class Container
    def dependencies
      @dependencies ||= {}
    end

    def self.register(name, class_name = nil, &block)
      klass = ActiveSupport::Inflector.constantize(class_name) if class_name

      if klass && !klass.respond_to?(:wire)
        raise ServiceOrchestrator::Error, "#{class_name} should implement the wire class method"
      end

      define_method name do |*args|
        dependencies[name] ||= klass ? klass.wire(self) : instance_exec(*args, &block)
      end

      define_method "#{name}=" do |service|
        dependencies[name] = service
      end
    end
  end
end
