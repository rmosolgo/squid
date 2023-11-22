require 'squid/format'
require 'active_support/core_ext/enumerable' # for Array#sum

module Squid
  # @private
  class Axis
    include Format
    attr_reader :data

    def initialize(data, steps:, stack:, format:, min: nil, max: nil, &block)
      @data, @steps, @stack, @format, @min, @max = data, steps, stack, format, min, max
      @steps_count = case steps
      when Integer
        steps
      when Array
        steps.size
      else
        0
      end
      @width_proc = block if block_given?
    end

    def minmax
      @minmax ||= if @data.any? && @steps.is_a?(Array)
        [@steps.last, @steps.first]
      else
        [min, max].compact.map do |number|
          approximate number
        end
      end
    end

    def labels
      min, max = minmax
      values = if min.nil? || max.nil? || @steps_count.zero?
        []
      elsif @steps.is_a?(Array)
        @steps
      else
        max.step(by: (min - max)/@steps_count.to_f, to: min)
      end
      @labels ||= values.map{|value| format_for value, @format}
    end

    def width
      @width ||= labels.map{|label| label_width label}.max || 0
    end

  private

    def label_width(label)
      @width_proc.call label if @width_proc
    end

    def min
      if @data.any?
        if @steps.is_a?(Array)
          @steps.last
        elsif values.first && values.first.any?
          @min || [values.first.min, 0].min
        end
      end
    end

    def max
      if @data.any?
        if @steps.is_a?(Array)
          @steps.first
        elsif values.last && values.last.any?
          closest_step_to(@max || values.last.max)
        end
      end
    end

    def closest_step_to(value)
      if @steps.is_a?(Array)
        @steps.sort_by { |s| (s - value).abs }.first
      elsif @format == :integer
        ((value - min) / @steps_count + 1) * @steps_count + min
      else
        [value, @steps_count].max
      end
    end

    def values
      @values ||= if @stack
        @data.map(&:values).transpose.map{|a| a.compact.partition{|n| n < 0}.map(&:sum)}.transpose
      else
        [@data.map(&:values).flatten.compact]
      end
    end

    def approximate(number)
      number_to_rounded(number, significant: true, precision: 2).to_f
    end
  end
end
