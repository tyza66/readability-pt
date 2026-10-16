# frozen_string_literal: true

# Flesch Reading Ease for Brazilian Portuguese (Martins et al., 1996) and English.
module ReadabilityPT
  VERSION = "1.0.0"

  VOWELS = "aeiouáéíóúâêôãõàüy"
  STRONG = "aeoáéóâêôãõà"
  HIATUS_MARKERS = "íú"
  NASAL = "ãõ"

  # Martins et al. (1996) bands for Portuguese.
  BANDS_PT = [[75, "muito fácil"], [50, "fácil"], [25, "difícil"], [0, "muito difícil"]].freeze
  # Flesch (1948) bands for English.
  BANDS_EN = [
    [90, "very easy"], [80, "easy"], [70, "fairly easy"], [60, "standard"],
    [50, "fairly difficult"], [30, "difficult"], [0, "very difficult"]
  ].freeze

  Result = Struct.new(:score, :level, :sentences, :words, :syllables, :avg_words_per_sentence,
                      :avg_syllables_per_word, :long_sentences, keyword_init: true)

  WORD_REGEX = /[[:alpha:]]+(?:[-'’][[:alpha:]]+)*/.freeze
  LONG_SENTENCE = 25

  module_function

  def sentences(text)
    parts = text.split(/(?<=[.!?…])\s+|\n{2,}/).map(&:strip).reject(&:empty?)
    parts.select { |s| s.match?(WORD_REGEX) }
  end

  def words(text)
    text.scan(WORD_REGEX)
  end

  # Heuristic syllable counter for Portuguese: one syllable per vowel group,
  # plus a break inside the group for common hiatus patterns
  # ("sa-ú-de", "pa-ís", "le-ão", "co-e-lho"). Diphthongs like "ão", "ai", "ou" stay together.
  def syllables_pt(word)
    groups = word.downcase.scan(/[#{VOWELS}]+/o)
    count = groups.sum do |group|
      breaks = group.chars.each_cons(2).count do |a, b|
        HIATUS_MARKERS.include?(b) || (STRONG.include?(a) && STRONG.include?(b) && !NASAL.include?(a))
      end
      1 + breaks
    end
    [count, 1].max
  end

  # Classic English heuristic: vowel groups, minus a silent final "e".
  def syllables_en(word)
    w = word.downcase.gsub(/[^a-z]/, "")
    return 1 if w.length <= 3

    w = w.sub(/(?:[^laeiouy]es|[^laeiouy]ed|[^laeiouy]e)$/, "").sub(/^y/, "")
    [w.scan(/[aeiouy]+/).size, 1].max
  end

  def analyze(text, lang: :pt)
    lang = lang.to_sym
    raise ArgumentError, "lang must be :pt or :en" unless %i[pt en].include?(lang)

    sentence_list = sentences(text)
    word_list = words(text)
    return nil if word_list.empty?

    syllables = word_list.sum { |w| lang == :pt ? syllables_pt(w) : syllables_en(w) }
    asl = word_list.size.to_f / [sentence_list.size, 1].max
    asw = syllables.to_f / word_list.size
    base = lang == :pt ? 248.835 : 206.835
    score = (base - 1.015 * asl - 84.6 * asw).clamp(0.0, 100.0).round(1)
    level = (lang == :pt ? BANDS_PT : BANDS_EN).find { |min, _label| score >= min }.last

    Result.new(
      score: score,
      level: level,
      sentences: sentence_list.size,
      words: word_list.size,
      syllables: syllables,
      avg_words_per_sentence: asl.round(1),
      avg_syllables_per_word: asw.round(2),
      long_sentences: sentence_list.select { |s| words(s).size > LONG_SENTENCE }
    )
  end
end
