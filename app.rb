require 'dotenv'
require 'sinatra'
require './twitter_search'
require './preprocessor'

Dotenv.load

set :environment, :production

get '/' do
  "pong"
end

get '/ng_words.json' do
  create_ng_words.to_json
end

def create_ng_words
  #=== ツイート準備
  tweets = []
  media_list = %w(nhk_news nikkei asahi mainichi Yomiuri_Online)
  media_list.each do |media|
    tweets << File.readlines("#{ENV['TWEETS_DIR']}/#{media}.txt")
  end
  tweets.flatten!

  #=== 単語抽出
  pre = Preprocessor.new(ENV['MECAB_DIC'])

  words = []
  tweets.each do |tweet|
    words << pre.run(tweet).map(&:surface)
  end
  words.flatten!

  #=== NGワード決定
  counts =
    words
    .group_by(&:itself)
    .map{ |word, words| [word, words.count] }.to_h
    .sort_by { |_, count| -count }.to_h

  ng_words = counts.keys[0..counts.size*0.01]
end
