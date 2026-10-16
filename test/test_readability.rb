# frozen_string_literal: true

require "minitest/autorun"
require "open3"
require_relative "../lib/readability_pt"

class ReadabilityPTTest < Minitest::Test
  def test_portuguese_syllables
    {
      "casa" => 2, "computador" => 4, "saúde" => 3, "país" => 2, "leão" => 2,
      "coração" => 3, "coelho" => 3, "Paulo" => 2, "quero" => 2, "fotógrafo" => 4, "é" => 1
    }.each do |word, expected|
      assert_equal expected, ReadabilityPT.syllables_pt(word), word
    end
  end

  def test_english_syllables
    { "the" => 1, "make" => 1, "marketing" => 3, "photography" => 4, "readable" => 3 }.each do |word, expected|
      assert_equal expected, ReadabilityPT.syllables_en(word), word
    end
  end

  def test_counts_sentences_and_words
    result = ReadabilityPT.analyze("O gato dorme. A casa é azul! Você viu?")
    assert_equal 3, result.sentences
    assert_equal 9, result.words
  end

  def test_short_text_is_easier_than_long_text
    easy = ReadabilityPT.analyze("O sol saiu. A praia está cheia. Leve água e protetor.")
    hard = ReadabilityPT.analyze(
      "A implementação de metodologias interdisciplinares fundamentadas em evidências científicas " \
      "proporciona significativas oportunidades de aprimoramento organizacional, " \
      "particularmente considerando-se as características socioeconômicas regionais."
    )
    assert_operator easy.score, :>, hard.score
    assert_equal "muito fácil", easy.level
    assert_equal "muito difícil", hard.level
    assert_equal 1, hard.sentences
  end

  def test_flags_long_sentences
    long = (["palavra"] * 30).join(" ") + "."
    result = ReadabilityPT.analyze("Frase curta. #{long}")
    assert_equal 1, result.long_sentences.size
  end

  def test_english_mode_uses_english_labels
    result = ReadabilityPT.analyze("The cat sat on the mat. It was happy.", lang: :en)
    assert_equal "very easy", result.level
  end

  def test_empty_text
    assert_nil ReadabilityPT.analyze("  ... ")
  end

  def test_cli
    bin = File.expand_path("../bin/readability", __dir__)
    out, status = Open3.capture2("ruby", bin, stdin_data: "O sol saiu. A praia está cheia.")
    assert status.success?
    assert_match(/Índice Flesch: [\d.]+ \(muito fácil\)/, out.force_encoding(Encoding::UTF_8))
  end
end
