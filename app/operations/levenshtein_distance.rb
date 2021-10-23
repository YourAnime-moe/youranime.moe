require "rubygems/text"

class LevenshteinDistance < ApplicationOperation
  include Gem::Text

  property! :s1, accepts: String
  property! :s2, accepts: String

  def perform
    longer = s1
    shorter = s2

    if s1.length < s2.length
      longer = s2
      shorter = s1
    end

    longer_length = longer.length
    return 1 if longer_length.zero?

    (longer_length - edit_distance(longer, shorter)) / longer_length.to_f
  end

  private

  def edit_distance(s1, s2)
    levenshtein_distance(s1, s2)
  end
end
