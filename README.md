# readability-pt

[![CI](https://github.com/lari-pellini/readability-pt/actions/workflows/ci.yml/badge.svg)](https://github.com/lari-pellini/readability-pt/actions/workflows/ci.yml)
![Ruby](https://img.shields.io/badge/ruby-2.6%2B-cc342d)
![License: MIT](https://img.shields.io/badge/license-MIT-green)

Índice de legibilidade **Flesch adaptado para o português brasileiro** — para checar se o texto do seu blog, landing page ou e-mail está fácil de ler antes de publicar. Também funciona em inglês.

> 🇺🇸 [English below](#-english)

## Por que isso importa para SEO e conversão

Texto difícil de ler aumenta a taxa de rejeição e diminui o tempo na página. Ferramentas como o Yoast usam o índice Flesch, mas a fórmula original é calibrada para o inglês — palavras em português têm, em média, mais sílabas, então a nota fica injustamente baixa. Aqui usamos a **adaptação de Martins et al. (1996)**:

```
Flesch PT = 248,835 − 1,015 × (palavras / frases) − 84,6 × (sílabas / palavras)
```

| Pontuação | Nível |
| --- | --- |
| 75 – 100 | muito fácil |
| 50 – 75 | fácil |
| 25 – 50 | difícil |
| 0 – 25 | muito difícil |

## Uso

```bash
bin/readability post.txt
echo "A fotografia de produto vende mais quando o fundo é limpo. Use luz natural." | bin/readability
bin/readability --lang en --json article.txt
```

```
Índice Flesch: 78.9 (muito fácil)
Frases: 3 · Palavras: 17 · Sílabas: 33
Média de palavras por frase: 5.7
```

Frases com mais de 25 palavras são listadas para você considerar dividi-las.

Como biblioteca:

```ruby
require_relative "lib/readability_pt"

ReadabilityPT.analyze("Fotografe seus produtos com luz natural. Evite sombras duras e fundos poluídos.").score # => 52.4 ("fácil")
```

## Contagem de sílabas

A separação silábica é **heurística**: conta grupos de vogais e separa hiatos comuns (`sa-ú-de`, `pa-ís`, `le-ão`, `co-e-lho`), mantendo ditongos juntos (`ão`, `ai`, `ou`). Ela erra em alguns casos (por exemplo `ra-i-nha`, `fi-a`) — melhorar isso é uma ótima primeira contribuição! Veja [CONTRIBUTING.md](CONTRIBUTING.md).

## Testes

```bash
ruby -Ilib test/test_readability.rb
```

---

## 🇺🇸 English

A small Ruby CLI and library that computes the **Flesch Reading Ease** score for **Brazilian Portuguese** (Martins et al., 1996 adaptation) and English, counts sentences/words/syllables and flags sentences longer than 25 words. Useful for checking blog posts, landing pages and emails before publishing.

```bash
bin/readability --lang en article.txt
```

## License

MIT © Larissa Pellini
