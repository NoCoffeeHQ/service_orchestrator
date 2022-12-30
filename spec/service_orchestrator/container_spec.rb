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
        container_class.register(:service, SimpleService)
      end

      it 'calls the build_and_wire method of the class passed in argument' do
        expect(container.service.call).to eq 42
      end

      it 'raises an exception if the class doesn\'t implement the build_and_wire class method' do
        expect do
          container_class.register(:wrong, String)
        end.to raise_error('String should implement the build_and_wire class method')
      end
    end
  end
  # rubocop:enable Metrics/BlockLength
end
class SimpleService
  def call
    42
  end

  def self.build_and_wire(_container)
    new
  end
end
