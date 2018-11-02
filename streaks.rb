module PercentageHelper
  def safe_divide(numerator, denominator)
    if denominator == 0
      numerator = 0
      denominator = 1
    end

    numerator.to_f / denominator.to_f
  end

  def pp_percentage(numerator, denominator=nil, format="%.2f%")
    if numerator.nil?
      return "N/A"
    end

    if !denominator
      denominator = 1
    end

    ratio = safe_divide(numerator, denominator) * 100

    if ratio.nan? || ratio.infinite?
      "N/A"
    else
      format % ratio
    end
  end

  def pp_percentage_round(numerator, denominator=nil)
    pp_percentage(numerator, denominator, "%i%")
  end
end

extend PercentageHelper

win_rate=0.50
number_of_trades=10
number_of_simulations=1_000
simulation_results = []

def run_simulation(number_of_trades, win_rate)
  wins = 0
  win_streak = 0
  largest_win_streak = 0
  last_result = nil

  1.upto(number_of_trades) do |trade_num|
    is_win = rand() < win_rate

    if is_win
      wins += 1
    end

    if is_win == last_result
      win_streak += 1
      if win_streak > largest_win_streak
        largest_win_streak = win_streak
      end
    else
      win_streak = 0
    end

    last_result = is_win
  end

  {
    wins: wins.to_f,
    win_streak: largest_win_streak.to_f,
    number_of_trades: number_of_trades.to_f,
    win_streak_percentage: largest_win_streak / number_of_trades.to_f,
  }
end

class Array
  def sum
    inject(&:+)
  end
end

1.upto(number_of_simulations) do |sim_number|
  simulation_results << run_simulation(number_of_trades, win_rate)
end

require 'pry'
wins = simulation_results.map { |x| x[:wins] }.sum
total = simulation_results.map { |x| x[:number_of_trades] }.sum
max_win_streak = simulation_results.map { |x| x[:win_streak] }.max

puts "samples: #{simulation_results.length}"
puts "average across all samples: #{pp_percentage(wins, total)}"

puts "Probability of a streak:"
1.upto(50) do |num|
  count = simulation_results.select { |res| res[:win_streak] > num }.count
  res = count / simulation_results.length.to_f
  puts "#{num}: #{pp_percentage(res)}"
end
