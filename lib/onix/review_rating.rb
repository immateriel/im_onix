module ONIX
  class ReviewRating < SubsetDSL
    element "Rating", :text, :cardinality => 1
    element "RatingLimit", :integer, :cardinality => 0..1
    elements "RatingUnits", :text, :cardinality => 0..n
  end
end