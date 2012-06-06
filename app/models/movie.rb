class Movie < ActiveRecord::Base
  def self.all_ratings
    Movie.select("distinct rating").map(&:rating)
  end
end
