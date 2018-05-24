require 'mecab'

module EmoMeCab
  include MeCab

  class Tagger < MeCab::Tagger
    #
    # @override
    #
    def parse(*args)
      parsed = super(*args)
      parsed.split("\n").map do |line|
        surface, feature = line.scan(/(?<surface>.+?)\t(?<feature>.*$)/)
        Node.new(*surface, *feature) if surface
      end
    end
  end
end

class Node
  attr_accessor :surface, :pos, :pos1, :pos2, :pos3,
    :cform, :ctype, :base, :read, :pron

  def initialize(surface, feature = nil)
    set_surface(surface)
    set_features(feature.split(',')) if feature
  end

  private

  #
  # surfaceを設定
  #
  def set_surface(surface)
    @surface = surface # 表層形
  end

  #
  # featuresの中身を設定
  #
  def set_features(features)
    @pos  = features[0]    # 品詞
    @pos1 = features[1]    # 品詞細分類1

    if features.size == 9
      @pos2  = features[2] # 品詞細分類2
      @pos3  = features[3] # 品詞細分類3
      @cform = features[4] # 活用形
      @ctype = features[5] # 活用型
      @base  = features[6] # 原形
      @read  = features[7] # 読み
      @pron  = features[8] # 発音
    else
      @cform = features[2]
      @ctype = features[3]
      @base  = features[4]
      @read  = features[5]
      @pron  = features[6]
    end
  end
end
