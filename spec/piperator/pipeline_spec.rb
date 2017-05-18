require 'spec_helper'

RSpec.describe Piperator::Pipeline do
  let(:add1) { ->(input) { input.lazy.map { |i| i + 1 } } }
  let(:square) { ->(input) { input.lazy.map { |i| i * i } } }

  describe 'calling' do
    it 'calls through all chain pipes in order' do
      chain = Piperator::Pipeline.new([add1, square])
      expect(chain.call([1, 2, 3]).to_a).to eq([4, 9, 16])
    end

    it 'returns original enumerable when chain is empty' do
      input = [1, 2, 3]
      chain = Piperator::Pipeline.new([])
      expect(chain.call(input).to_a).to be(input)
    end
  end

  describe 'composition' do
    it 'runs runs through all input pipes' do
      first = Piperator::Pipeline.new([square])
      second = Piperator::Pipeline.new([add1])
      expect((first + second).call([1, 2, 3]).to_a).to eq([2, 5, 10])
    end

    it 'can compose callables' do
      pipeline = Piperator::Pipeline.new
      expect((pipeline + add1 + square).call([1, 2, 3]).to_a).to eq([4, 9, 16])
    end

    it 'aliases + to pipe' do
      pipeline = Piperator::Pipeline.pipe([1])
      expect(pipeline.pipe(add1).to_a).to eq([2])
    end

    it 'can start composition from empty Pipeline class' do
      expect(Piperator::Pipeline.pipe(add1).call([3]).to_a).to eq([4])
    end

    it 'treats pipeline pipe as an identity transformation' do
      pipeline = Piperator::Pipeline.pipe(add1).pipe(Piperator::Pipeline)
      expect(pipeline.call([1, 2]).to_a).to eq([2, 3])
    end

    it 'can start pipeline from an enumerable' do
      pipeline = Piperator::Pipeline.pipe([1, 2, 3]).pipe(add1)
      expect(pipeline.to_a).to eq([2, 3, 4])
    end
  end
end
