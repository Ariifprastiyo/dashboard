# frozen_string_literal: true

# This service is used to analyze the account
# It will analyze based on the account's informations and recents social media publications
# Based on that we will make a conclusion about the account such as :
#    - Account performance metrics (engagement, reach, impressions, etc)
#    - Comments and interactions analysis
#    - Account's followers analysis
#    - Account's content analysis
#    - Comments word cloud

class SocialMediaAccountAnalyzerService < ApplicationService
  def initialize(account)
    @account = account
  end

  def perform
    # TODO: Implement the analysis
  end
end
