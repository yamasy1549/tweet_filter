require 'dotenv'
require 'twitter'

class TwitterSearch
  def initialize
   Dotenv.load

   @client = Twitter::REST::Client.new(
    consumer_key:    ENV['CONSUMER_KEY'],
    consumer_secret: ENV['CONSUMER_SECRET']
  )
  end

  def search_loop(type = :tweet, options = {})
    tweets = []
    max_id = nil

    case type
    when :tweet
      method = :tweet_search
    when :user_tweet
      method = :user_tweet_search
    end

    while (result_tweets = self.send(method, options, max_id)) && result_tweets.first
      result_tweets.each.with_index do |tweet, i|
        max_id = tweet.id
        tweets << tweet.full_text
      end
    end

    tweets
  end

  private

  def tweet_search(options = {}, max_id = nil)
    options = {
      q: '',
      result_type: :'recent',
      count: 100,
      include_entities: false
    }.merge(options)
    options = options.merge({max_id: max_id - 1}) if max_id

    @client.search(options[:q], options)
  end

  def user_tweet_search(options = {}, max_id = nil)
    options = {
      screen_name: '',
      count: 200,
      trim_user: true,
      exclude_replies: true,
      include_rts: false
    }.merge(options)
    options = options.merge({max_id: max_id - 1}) if max_id

    @client.user_timeline(options)
  end
end
