module Squid
  class Gridline
    def self.for(steps:, skip_baseline:, height:)
      if steps.is_a?(Integer)
        count = steps
        step_heights = height.step(0, -height/count.to_f)
      else
        count = steps.size
        range = (steps.first - steps.last).to_f
        step_heights = steps.map do |s|
          ((s - steps.last) / range) * height
        end
      end

      return [] if count.zero?

      step_heights.map do |y|
        new(y: y) unless skip_baseline && y.zero?
      end.compact
    end

    attr_reader :y

    def initialize(y:)
      @y = y
    end
  end
end
