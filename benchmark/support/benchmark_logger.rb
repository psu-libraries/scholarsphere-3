# frozen_string_literal: true

module BenchmarkLogger
  def logger
    @logger ||= Logger.new('benchmark_info.log')
  end
end
