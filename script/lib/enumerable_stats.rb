module Enumerable

  def sum
    inject(0){ |accum, i| accum + i }
  end

  def mean
    sum/length.to_f
  end

  def sample_variance
    m = mean
    sum = inject(0){ |accum, i| accum +(i-m) ** 2 }
    (1 / length.to_f * sum)
  end

  def standard_deviation
    Math.sqrt(sample_variance)
  end

  def outliers(deviation)
    m = mean
    sd = standard_deviation
    select { |n| (m-n).abs > (deviation * sd) }
  end

end
