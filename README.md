# Bardo

CLI para guitarristas e violonistas que querem dominar teoria musical e improvisacao.

Se voce toca ha anos mas ainda depende de cola para improvisar, o Bardo e pra voce. Ele te mostra campo harmonico, escalas, voicings de acorde pelo braco inteiro, e ainda te ensina teoria musical do zero com um sistema de progressao tipo RPG.

## Instalacao

Requer Ruby >= 3.0.

```bash
git clone https://github.com/matheusbarbosa/bardo.git
cd bardo
bundle install
```

## Uso rapido

```bash
bundle exec ruby bin/bardo <comando>
```

Para ver todos os comandos:

```bash
bundle exec ruby bin/bardo help
```

---

## Comandos

### `bardo improv` - Guia de improvisacao

O comando principal. Voce diz o tom e ele te da **tudo** que precisa para improvisar: campo harmonico, escala por acorde, safe choices, progressoes comuns, pentatonica no braco e voicings CAGED.

```bash
bardo improv C          # Cheat sheet completo de C Maior
bardo improv Am         # Cheat sheet de A menor
bardo improv G -i       # Modo interativo (menu de navegacao)
```

Exemplo de saida (`bardo improv C`):

```
========================================================
  GUIA DE IMPROVISACAO - C Maior
========================================================

  CAMPO HARMONICO
     I       ii     iii      IV      V       vi     vii°
     C       Dm      Em      F       G       Am     Bdim
   Cmaj7    Dm7     Em7    Fmaj7     G7     Am7    Bm7b5

  ESCALAS POR ACORDE

  C / Cmaj7      Ionian (C D E F G A B)
  Dm / Dm7       Dorian (D E F G A B C)
  Em / Em7       Phrygian (E F G A B C D)
  F / Fmaj7      Lydian (F G A B C D E)
  G / G7         Mixolydian (G A B C D E F)
  Am / Am7       Aeolian (A B C D E F G)
  Bdim / Bm7b5   Locrian (B C D E F G A)

  Dica: todas as escalas acima tem as MESMAS notas!
  A diferenca eh a nota que voce ENFATIZA (centro de gravidade).

  SAFE CHOICES (funciona sobre tudo)

  * C Pentatonica maior:  C D E G A
  * A Pentatonica menor:  A C D E G  (relativa)

  PROGRESSOES COMUNS

  I - IV - V           C - F - G              rock, folk, blues
  I - V - vi - IV      C - G - Am - F         pop (a mais usada no mundo)
  ii - V - I           Dm - G - C             jazz (a mais importante do jazz)
  I - vi - IV - V      C - Am - F - G         anos 50, doo-wop
```

Com `--interactive` (`-i`) abre um menu onde voce explora acorde por acorde, vendo a escala recomendada no braco + voicings + notas-alvo.

---

### `bardo field` - Campo harmonico

Mostra todos os acordes que pertencem a um tom, com graus, funcoes harmonicas e notas.

```bash
bardo field C           # Campo harmonico de C Maior
bardo field Am          # Campo harmonico de A menor
bardo field G --tetrads # Com tetrades (acordes com 7a)
```

Exemplo (`bardo field C --tetrads`):

```
Campo Harmonico de C Maior

┌──────┬────────┬─────────┬───────────┬───────────────────┐
│ Grau │ Acorde │ Tetrade │ Notas     │ Funcao            │
├──────┼────────┼─────────┼───────────┼───────────────────┤
│ I    │ C      │ Cmaj7   │ C - E - G │ Tonica            │
│ ii   │ Dm     │ Dm7     │ D - F - A │ Subdominante      │
│ iii  │ Em     │ Em7     │ E - G - B │ Tonica (mediante) │
│ IV   │ F      │ Fmaj7   │ F - A - C │ Subdominante      │
│ V    │ G      │ G7      │ G - B - D │ Dominante         │
│ vi   │ Am     │ Am7     │ A - C - E │ Tonica relativa   │
│ vii° │ Bdim   │ Bm7b5   │ B - D - F │ Dominante         │
└──────┴────────┴─────────┴───────────┴───────────────────┘

Escala: C - D - E - F - G - A - B
Formula: T T ST T T T ST
```

Como ler: os numeros romanos (I, ii, IV, V...) sao os **graus**. Maiusculo = acorde maior, minusculo = acorde menor. A **funcao** diz o papel de cada acorde: Tonica (repouso), Subdominante (movimento), Dominante (tensao que quer resolver).

---

### `bardo scale` - Escalas

Mostra qualquer escala com notas, intervalos e formula.

```bash
bardo scale C major              # Escala maior de C
bardo scale A pentatonic_minor   # Pentatonica menor de A
bardo scale D dorian             # D Dorico
bardo scale E mixolydian         # E Mixolidio
bardo scale A blues --fretboard  # Escala blues com visualizacao no braco
```

Exemplo (`bardo scale A pentatonic_minor`):

```
A Pentatonica Menor - rock, blues, a queridinha da improvisacao

┌───────────┬───┬────┬───┬───┬────┐
│ Grau      │ 1 │ 2  │ 3 │ 4 │ 5  │
├───────────┼───┼────┼───┼───┼────┤
│ Nota      │ A │ C  │ D │ E │ G  │
│ Intervalo │ 1 │ b3 │ 4 │ 5 │ b7 │
└───────────┴───┴────┴───┴───┴────┘

Formula: 1½T T T 1½T T
```

Use `--fretboard` (`-f`) para ver no braco da guitarra. Use `--tuning drop_d` para afinacoes alternativas.

---

### `bardo chord` - Acordes

Mostra as notas de um acorde, intervalos, e opcionalmente sugere escalas para solar e voicings CAGED.

```bash
bardo chord Am7              # Notas e intervalos de Am7
bardo chord G7 --scales      # Sugere escalas para solar sobre G7
bardo chord C --voicings     # Mostra voicings CAGED de C
bardo chord Dm7 -s -v -f    # Tudo: escalas + voicings + braco
```

Exemplo (`bardo chord Am7 --scales`):

```
Am7 - Menor com 7a menor - suave, jazz

  Notas:      A - C - E - G
  Intervalos:  1 - b3 - 5 - b7

Escalas sugeridas para solar:
  * A Escala Menor Natural (Eolia) - triste, melancolica
    A - B - C - D - E - F - G
  * A Dorico - menor com 6a maior, som de Santana/jazz funk
    A - B - C - D - E - F# - G
  * A Pentatonica Menor - rock, blues, a queridinha da improvisacao
    A - C - D - E - G
  * A Blues - pentatonica menor + blue note (b5)
    A - C - D - D# - E - G
```

Acordes suportados: `C`, `Am`, `G7`, `Cmaj7`, `Dm7`, `Bdim`, `Bm7b5`, `Fsus4`, `Asus2`, `Caug`, entre outros.

---

### `bardo suggest` - Sugestao de escalas para progressao

Dada uma progressao de acordes, identifica o tom provavel e sugere escalas para improvisar sobre cada acorde.

```bash
bardo suggest Am F C G          # Progressao pop
bardo suggest Dm7 G7 Cmaj7     # ii-V-I (jazz)
bardo suggest E A B             # I-IV-V (rock)
```

Exemplo (`bardo suggest Dm7 G7 Cmaj7`):

```
Progressao: Dm7 -> G7 -> Cmaj7

Tom provavel:
  >>> C Maior (3/3 acordes encaixam)

Escalas sugeridas por acorde:

  Dm7 (D - F - A - C):
    * D dorian - D E F G A B C
    * D pentatonic_minor - D F G A C

  G7 (G - B - D - F):
    * G mixolydian - G A B C D E F
    * G blues - G A# C C# D F

  Cmaj7 (C - E - G - B):
    * C major - C D E F G A B
    * C lydian - C D E F# G A B

Safe choices para toda a progressao:
  * A Pentatonica menor - A C D E G
```

---

### `bardo voicings` - Diagramas de acorde CAGED

Mostra os 5 shapes CAGED de qualquer acorde em diagramas verticais classicos. Use `--near` para filtrar por regiao do braco.

```bash
bardo voicings C              # Todos os 5 shapes de C
bardo voicings Am             # Todos os shapes de Am
bardo voicings Am --near 5    # Shapes de Am perto da casa 5
bardo voicings G --near 8     # Shapes de G perto da casa 8
```

Exemplo (`bardo voicings Am --near 5`):

```
Voicings CAGED de Am

  Am (G shape)         Am (E shape)         Am (D shape)

  2fr                  5fr                  X  X
  │─│─●─◉─│─│          ◉─│─│─●─●─◉          7fr
  ├─┼─┼─┼─┼─┤          ├─┼─┼─┼─┼─┤          │─│─◉─│─│─│
  │─●─│─│─│─│          │─│─│─│─│─│          ├─┼─┼─┼─┼─┤
  ├─┼─┼─┼─┼─┤          ├─┼─┼─┼─┼─┤          │─│─│─│─│─●
  │─│─│─│─│─│          │─●─◉─│─│─│          ├─┼─┼─┼─┼─┤
  ├─┼─┼─┼─┼─┤          ├─┼─┼─┼─┼─┤          │─│─│─●─│─│
  ◉─│─│─│─●─◉          │─│─│─│─│─│          ├─┼─┼─┼─┼─┤
  └─┴─┴─┴─┴─┘          └─┴─┴─┴─┴─┘          │─│─│─│─◉─│
  E A D G B e          E A D G B e          └─┴─┴─┴─┴─┘
                                             E A D G B e
```

Isso e util quando voce esta improvisando em uma regiao do braco e quer saber qual shape de acorde fica perto.

---

### `bardo fretboard` - Escala no braco da guitarra

Visualizacao completa de qualquer escala no braco, com destaque para a tonica.

```bash
bardo fretboard A pentatonic_minor        # Pentatonica menor de A
bardo fretboard E blues                   # Blues de E
bardo fretboard C major                   # C maior no braco
bardo fretboard D dorian --tuning drop_d  # D dorico em drop D
bardo fretboard G mixolydian --frets 12   # Ate a casa 12
```

Exemplo (`bardo fretboard E blues`):

```
E Blues - pentatonica menor + blue note (b5)

     0   1   2   3   4   5   6   7   8   9   10  11  12
E  | E  -------- G  ---- A   A#  B  -------- D  ---- E  |
B  | B  -------- D  ---- E  -------- G  ---- A   A#  B  |
G  | G  ---- A   A#  B  -------- D  ---- E  -------- G  |
D  | D  ---- E  -------- G  ---- A   A#  B  -------- D  |
A  | A   A#  B  -------- D  ---- E  -------- G  ---- A  |
E  | E  -------- G  ---- A   A#  B  -------- D  ---- E  |

E = Tonica   Notas: E G A A# B D
```

---

### `bardo journey` - Jornada do Bardo

Sistema interativo de aprendizado com niveis, XP e licoes progressivas. Aprenda teoria musical do zero, no seu ritmo.

```bash
bardo journey
```

**5 niveis, 14 licoes:**

| Nivel | Nome | XP | O que aprende |
|-------|------|----|---------------|
| 1 | Aprendiz | 0 | As 12 notas, tom/semitom, escala maior |
| 2 | Trovador | 100 | Escala menor, graus, pentatonica, blues |
| 3 | Menestrel | 300 | Intervalos, formacao de acordes, campo harmonico |
| 4 | Bardo | 600 | Tetrades, funcoes harmonicas, modos gregos, improvisacao |
| 5 | Mestre Bardo | 1000 | Dominio completo |

Cada licao tem conteudo teorico explicado de forma pratica, seguido de exercicios. Voce precisa de 70% de acerto para completar uma licao. Ganha XP por acerto (+10), streak bonus a cada 5 acertos (+25), bonus por licao (+50) e bonus por level up (+100).

Voce pode sair de qualquer licao ou exercicio a qualquer momento digitando `q` ou selecionando "Voltar ao menu".

---

### `bardo scales` - Lista de escalas

Lista todas as escalas disponiveis com descricao e intervalos.

```bash
bardo scales
```

Escalas disponiveis:

| Tipo | Descricao |
|------|-----------|
| `major` | Escala Maior (Jonica) - alegre, brilhante |
| `minor` | Escala Menor Natural (Eolia) - triste, melancolica |
| `harmonic_minor` | Menor Harmonica - som arabe/classico |
| `melodic_minor` | Menor Melodica - jazz, suave |
| `pentatonic_major` | Pentatonica Maior - country, pop, safe choice |
| `pentatonic_minor` | Pentatonica Menor - rock, blues, a queridinha |
| `blues` | Blues - pentatonica menor + blue note (b5) |
| `ionian` | Jonio (= Maior) |
| `dorian` | Dorico - som de Santana/jazz funk |
| `phrygian` | Frigio - som espanhol/flamenco |
| `lydian` | Lidio - som sonhador/etereo |
| `mixolydian` | Mixolidio - blues/rock/dominante |
| `aeolian` | Eolio (= Menor Natural) |
| `locrian` | Locrio - instavel, usado sobre m7b5 |

---

## Flags

| Flag | Onde funciona | O que faz |
|------|---------------|-----------|
| `--tetrads` / `-t` | `field` | Mostra acordes com 7a (tetrades) |
| `--fretboard` / `-f` | `scale`, `chord` | Mostra no braco da guitarra |
| `--scales` / `-s` | `chord` | Sugere escalas para solar |
| `--voicings` / `-v` | `chord` | Mostra diagramas de acorde CAGED |
| `--interactive` / `-i` | `improv` | Modo interativo com menu |
| `--near N` / `-n N` | `voicings` | Filtra voicings perto da casa N |
| `--tuning NOME` | `scale`, `chord`, `fretboard` | Afinacao alternativa |
| `--frets N` | `fretboard` | Numero de casas a mostrar |

Afinacoes disponiveis: `standard`, `drop_d`, `open_g`, `open_d`, `dadgad`, `half_down`.

---

## Conceitos basicos

Para quem esta comecando, aqui vai um mini-glossario:

**Tom e Semitom**: No braco da guitarra, cada casa = 1 semitom. Duas casas = 1 tom.

**Escala**: Conjunto de notas que "combinam" entre si. A escala maior tem 7 notas com a formula T T ST T T T ST (Tom, Tom, Semitom, Tom, Tom, Tom, Semitom).

**Campo harmonico**: Todos os acordes que pertencem a um tom. Em C maior: C, Dm, Em, F, G, Am, Bdim. Se a musica usa esses acordes, esta "em C".

**Graus (I, ii, III...)**: A posicao do acorde no campo harmonico. O padrao eh sempre o mesmo, independente do tom: Maior, menor, menor, Maior, Maior, menor, diminuto.

**Pentatonica**: Escala de 5 notas. A pentatonica menor eh a escala mais usada para improvisacao no rock e blues. Se voce nao sabe o que tocar, pentatonica menor na tonica da musica eh a safe choice.

**Modos gregos**: 7 "sabores" diferentes de escala. Cada modo tem uma sonoridade unica. Dorico = Santana, Frigio = flamenco, Mixolidio = rock/blues, Lidio = sonhador.

**CAGED**: Sistema que divide o braco da guitarra em 5 regioes, cada uma baseada em um formato de acorde aberto (C, A, G, E, D). Permite tocar o mesmo acorde em 5 posicoes diferentes.

---

## Desenvolvimento

```bash
bundle exec rspec          # Rodar testes (245 specs)
bundle exec rake           # Rodar testes via rake
```

## Licenca

MIT
