class Page < ApplicationRecord
  # Assume that the Page model has a keywords attribute that stores the page's keywords as a string
  # separated by commas (e.g. "Ford, Car, Review")

  def self.search(query)
    # Split the query into an array of keywords
    query_keywords = query.split(",").map(&:strip)

    # Calculate the weight for each keyword in the query
    query_weights = query_keywords.each_with_index.map { |keyword, i| [(query_keywords.length - i), keyword] }.to_h

    # Find all pages that contain at least one of the query keywords
    pages = Page.where("keywords ILIKE ?", "%#{query_keywords.join('%')}%")

    # Calculate the strength for each page
    results = {}
    pages.each do |page|
      strength = 0
      page.keywords.split(",").map(&:strip).each do |page_keyword|
        if query_weights[page_keyword]
          strength += query_weights[page_keyword]
        end
      end
      results[page.id] = strength
    end

    # Sort the results by strength in descending order
    sorted_results = results.sort_by { |_, v| -v }

    # Return the top 5 pages
    sorted_results[0..4].map { |result| result[0] }
  end
end
