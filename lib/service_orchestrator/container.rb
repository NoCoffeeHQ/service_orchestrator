# frozen_string_literal: true

module ServiceOrchestrator
  # Strongly inspired by https://github.com/bkeepers/morphine (MIT).
  # Copying/pasting/modifying the code from Morphine seemed the cleaner solution.
  class Container
    def dependencies
      @dependencies ||= {}
    end

    def klasses
      @klasses ||= {}
    end

    def self.register(name, class_name = nil, &block)
      define_method name do |*args|
        dependencies[name] ||= class_name ? service_class(class_name).wire(self) : instance_exec(*args, &block)
      end

      define_method "#{name}=" do |service|
        dependencies[name] = service
      end
    end

    private

    def service_class(class_name)
      return klasses[class_name] if klasses[class_name]

      klass = ActiveSupport::Inflector.constantize(class_name)

      unless klass.respond_to?(:wire)
        raise ServiceOrchestrator::Error, "#{class_name} should implement the wire class method"
      end

      klasses[class_name] ||= klass
    end
  end
end
