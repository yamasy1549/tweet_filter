require 'dotenv'
require './twitter_search'

Dotenv.load

def collect_tweets
  twitter_search = TwitterSearch.new

  screen_names = %w(nhk_news nikkei asahi mainichi Yomiuri_Online)
  screen_names.each do |screen_name|
    tweets = twitter_search.search_loop(:user_tweet, { screen_name: screen_name })

    puts screen_name

    File.open("#{ENV['TWEETS_DIR']}/#{screen_name}.txt", 'w') do |file|
      file.puts tweets.map { |tweet| tweet.delete("\n") }
    end
  end
end
