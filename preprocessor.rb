require './emo_mecab'

class Preprocessor
  def initialize(dicpath = nil)
    dic_option = ''
    dic_option = "-d #{dicpath}" if dicpath
    @tagger = EmoMeCab::Tagger.new(dic_option)
  end

  def run(text)
    text
      .yield_self { |text| remove_hashtag(text) }
      .yield_self { |text| remove_url(text) }
      .yield_self { |text| remove_number(text) }
      .yield_self { |text| remove_brackets(text) }
      .yield_self { |text| split_to_words(text) }
      .select { |node| is_propernoun?(node) && !is_area?(node) }
  end

  private

  def remove_hashtag(text)
    text.gsub(/#[\S]+/, '')
  end

  def remove_url(text)
    text.gsub(/https?:\/\/[\S]+/, '')
  end

  def remove_number(text)
    text.tr('０-９0-9', '')
  end

  def remove_brackets(text)
    text.tr('()[]（）「」『』【】', '')
  end

  def split_to_words(text)
    @tagger.parse(text)
  end

  def is_propernoun?(node)
    node&.pos1 == '固有名詞'
  end

  def is_area?(node)
    node&.pos2 == '地域'
  end
end
