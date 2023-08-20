# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
RSpec.describe ServiceOrchestrator::Container do
  let(:container_class) do
    Class.new(ServiceOrchestrator::Container)
  end
  let(:container) { container_class.new }

  describe '.register' do
    context 'Given we pass a block' do
      before do
        container_class.register(:service) { 'hello world!' }
      end

      it 'yields block to instantiate dependency' do
        expect(container.service).to eq 'hello world!'
      end

      it 'memoizes result' do
        expect(container.service.object_id).to eq container.service.object_id
      end

      it 'defines writer method to change service' do
        container.service = 'good bye'
        expect(container.service).to eq 'good bye'
      end

      it 'passes arguments through to the block' do
        container_class.register(:pass_through) { |argument| argument }
        expect(container.pass_through(:a)).to eq :a
      end
    end

    context 'Given we pass a class' do
      before do
        container_class.register(:service, 'SimpleService')
      end

      it 'calls the wire class method to instantiate the service' do
        expect(container.service.call).to eq 42
      end

      it 'raises an exception if the class doesn\'t implement the wire class method' do
        container_class.register(:wrong, 'String')
        expect do
          container.wrong
        end.to raise_error('String should implement the wire class method')
      end
    end

    context 'Given we pass a class inheriting from Service' do
      before do
        container_class.register(:registration, 'RegistrationService')
        container_class.register(:logger) { SimpleLogger.new }
      end

      it 'wires the dependencies' do
        expect(container.registration.logger).to be_an(SimpleLogger)
      end

      it 'uses the dependencies' do
        container.registration.call(username: 'johndoe')
        expect(container.logger.logs).to eq([:user_created])
      end
    end
  end
  # rubocop:enable Metrics/BlockLength
end
class SimpleService
  def call
    42
  end

  def self.wire(_name, _container)
    new
  end
end

class RegistrationService < ServiceOrchestrator::Service
  dependency :logger
  def call(username:)
    logger.call(event_name: :user_created)
    username
  end
end

class SimpleLogger
  attr_reader :logs

  def initialize
    @logs = []
  end

  def call(event_name:)
    @logs.push(event_name)
  end
end
