# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
RSpec.describe ServiceOrchestrator::Service do
  let(:service_class) do
    Class.new(ServiceOrchestrator::Service) do
      dependency :logger
      dependencies :push_notifier, :other_service
      def call
        [logger, push_notifier, other_service]
      end
    end
  end

  describe '.new' do
    subject { service_class.new(logger: 1, push_notifier: 2, other_service: 3) }

    it 'can be instantiate without passing by a container' do
      expect(subject.logger).to eq 1
      expect(subject.push_notifier).to eq 2
      expect(subject.other_service).to eq 3
    end
  end

  describe '.wire' do
    let(:container_class) { Struct.new(:logger, :push_notifier, :other_service) }
    let(:container) { container_class.new(1, 2, 3) }

    subject { service_class.wire(container) }

    it 'instantiates a new service and wire the dependencies together' do
      expect(subject.logger).to eq 1
      expect(subject.push_notifier).to eq 2
      expect(subject.other_service).to eq 3
    end
  end
end
# rubocop:enable Metrics/BlockLength
