# frozen_string_literal: true

module Bardo
  module Journey
    class Lesson
      attr_reader :id, :title, :level_index, :content, :exercises

      def initialize(id:, title:, level_index:, content:, exercises:)
        @id = id
        @title = title
        @level_index = level_index
        @content = content
        @exercises = exercises
      end

      def level
        Level.new(level_index)
      end

      def exercise_count
        exercises.length
      end

      # All lessons in the Bardo journey
      def self.all
        @all ||= build_curriculum
      end

      def self.for_level(level_index)
        all.select { |l| l.level_index == level_index }
      end

      def self.find(id)
        all.find { |l| l.id == id }
      end

      def self.build_curriculum # rubocop:disable Metrics/MethodLength
        [
          # === NIVEL 1: APRENDIZ ===
          new(
            id: '1.1',
            title: 'As 12 notas musicais',
            level_index: 0,
            content: <<~CONTENT,
              A musica ocidental usa 12 notas que se repetem em oitavas.
              Sao 7 notas naturais e 5 acidentes (sustenidos/bemois):

              Notas naturais: C  D  E  F  G  A  B
                              Do Re Mi Fa Sol La Si

              Com acidentes:  C  C#  D  D#  E  F  F#  G  G#  A  A#  B
                              1  2   3  4   5  6  7   8  9  10  11  12

              Repare: entre E-F e B-C NAO tem sustenido!
              Sao os dois semitons naturais da escala.

              No braco da guitarra, cada CASA = 1 semitom.
              Entao da casa 0 ate a casa 12, voce percorre todas as 12 notas.
            CONTENT
            exercises: [
              { type: :multiple_choice, question: 'Quantas notas tem a musica ocidental?', options: %w[7 10 12 14],
                answer: '12' },
              { type: :multiple_choice, question: 'Qual nota vem depois de E?', options: %w[E# F F# Fb], answer: 'F' },
              { type: :multiple_choice, question: 'Qual nota vem depois de B?', options: %w[B# C C# Cb], answer: 'C' },
              { type: :multiple_choice, question: 'Entre quais notas NAO existe sustenido?',
                options: %w[C-D E-F A-B F-G], answer: 'E-F' },
              { type: :fill_in, question: 'Complete: C, C#, D, D#, ?, F', answer: 'E' }
            ]
          ),

          new(
            id: '1.2',
            title: 'Tom e Semitom',
            level_index: 0,
            content: <<~CONTENT,
              No braco da guitarra/violao:
              - 1 casa  = 1 SEMITOM (a menor distancia entre duas notas)
              - 2 casas = 1 TOM

              Exemplos de SEMITOM (1 casa):
                C -> C#    E -> F    B -> C    G# -> A

              Exemplos de TOM (2 casas):
                C -> D     E -> F#   A -> B    G -> A

              Macete: se voce pula uma nota cromatica, eh um tom.
                      se nao pula nenhuma, eh um semitom.
            CONTENT
            exercises: [
              { type: :tom_semitom, question: 'De C para D?', from: 'C', to: 'D', answer: 'Tom' },
              { type: :tom_semitom, question: 'De E para F?', from: 'E', to: 'F', answer: 'Semitom' },
              { type: :tom_semitom, question: 'De A para B?', from: 'A', to: 'B', answer: 'Tom' },
              { type: :tom_semitom, question: 'De B para C?', from: 'B', to: 'C', answer: 'Semitom' },
              { type: :tom_semitom, question: 'De F para G?', from: 'F', to: 'G', answer: 'Tom' },
              { type: :tom_semitom, question: 'De G para G#?', from: 'G', to: 'G#', answer: 'Semitom' }
            ]
          ),

          new(
            id: '1.3',
            title: 'A Escala Maior',
            level_index: 0,
            content: <<~CONTENT,
              A escala maior eh a BASE de toda a teoria musical.
              Sua formula eh:  T  T  ST  T  T  T  ST
              (Tom, Tom, Semitom, Tom, Tom, Tom, Semitom)

              Aplicando a partir de C:
              C -T-> D -T-> E -ST-> F -T-> G -T-> A -T-> B -ST-> C

              Essa formula funciona pra QUALQUER nota!
              A partir de G:
              G -T-> A -T-> B -ST-> C -T-> D -T-> E -T-> F# -ST-> G

              Repare que o F virou F# para manter a formula T T ST T T T ST.
            CONTENT
            exercises: [
              { type: :multiple_choice, question: 'Qual a formula da escala maior?',
                options: ['T T ST T T T ST', 'T ST T T ST T T', 'T T T ST T T ST', 'ST T T T ST T T'], answer: 'T T ST T T T ST' },
              { type: :scale_build, question: 'Monte a escala de C maior', root: 'C', scale_type: :major },
              { type: :scale_build, question: 'Monte a escala de G maior', root: 'G', scale_type: :major },
              { type: :multiple_choice, question: 'Qual nota eh diferente entre C maior e G maior?',
                options: %w[C F# Bb D#], answer: 'F#' }
            ]
          ),

          # === NIVEL 2: TROVADOR ===
          new(
            id: '2.1',
            title: 'Escala Menor Natural',
            level_index: 1,
            content: <<~CONTENT,
              A escala menor natural tem um som mais triste/melancolico.
              Sua formula eh:  T  ST  T  T  ST  T  T

              Compare com a maior: T T ST T T T ST
              Menor natural:       T ST T T ST T T

              A partir de A:
              A -T-> B -ST-> C -T-> D -T-> E -ST-> F -T-> G -T-> A

              Macete: A menor natural tem as MESMAS notas que C maior!
              Isso se chama RELATIVA MENOR.
              Toda escala maior tem uma menor relativa (6o grau).
            CONTENT
            exercises: [
              { type: :multiple_choice, question: 'Qual a formula da escala menor?',
                options: ['T T ST T T T ST', 'T ST T T ST T T', 'T ST T T T ST T', 'ST T T ST T T T'], answer: 'T ST T T ST T T' },
              { type: :scale_build, question: 'Monte a escala de A menor', root: 'A', scale_type: :minor },
              { type: :multiple_choice, question: 'A menor natural eh relativa de qual escala maior?',
                options: %w[C D G F], answer: 'C' },
              { type: :multiple_choice, question: 'A relativa menor comeca em qual grau da maior?',
                options: %w[3o 4o 5o 6o], answer: '6o' }
            ]
          ),

          new(
            id: '2.2',
            title: 'Graus da escala',
            level_index: 1,
            content: <<~CONTENT,
              Cada nota da escala tem um NUMERO (grau):

              Em C maior:  C   D   E   F   G   A   B
              Grau:        I  II  III  IV   V  VI  VII

              Isso eh util porque a relacao entre graus eh SEMPRE a mesma,
              nao importa o tom. O V sempre "quer resolver" no I.

              Em G maior:  G   A   B   C   D   E   F#
              Grau:        I  II  III  IV   V  VI  VII

              Quando alguem diz "faz um I-IV-V", em C eh: C, F, G.
              Em G seria: G, C, D. A logica eh a mesma!
            CONTENT
            exercises: [
              { type: :fill_in, question: 'Qual o 5o grau de C maior?', answer: 'G' },
              { type: :fill_in, question: 'Qual o 4o grau de G maior?', answer: 'C' },
              { type: :fill_in, question: 'Qual o 3o grau de D maior?', answer: 'F#' },
              { type: :multiple_choice, question: 'I-IV-V em A maior seria:',
                options: ['A-D-E', 'A-C-D', 'A-C#-E', 'A-D-F'], answer: 'A-D-E' }
            ]
          ),

          new(
            id: '2.3',
            title: 'Pentatonica - a escala da improvisacao',
            level_index: 1,
            content: <<~CONTENT,
              A pentatonica tem apenas 5 notas (penta = cinco).
              Eh a escala mais usada para improvisacao no rock e blues.

              Pentatonica MENOR: 1  b3  4  5  b7
              Em A:              A   C  D  E   G

              Pentatonica MAIOR: 1  2  3  5  6
              Em C:              C  D  E  G  A

              Macete: A pentatonica menor de A tem as MESMAS notas
              que a pentatonica maior de C! (mesma logica da relativa)

              Por que ela eh tao boa pra improvisar?
              Porque ela evita as notas "perigosas" (4a e 7a) que podem
              soar estranhas sobre certos acordes. Eh a safe choice!
            CONTENT
            exercises: [
              { type: :scale_build, question: 'Monte a pentatonica menor de A', root: 'A',
                scale_type: :pentatonic_minor },
              { type: :scale_build, question: 'Monte a pentatonica maior de C', root: 'C',
                scale_type: :pentatonic_major },
              { type: :multiple_choice, question: 'Quantas notas tem a pentatonica?', options: %w[4 5 6 7],
                answer: '5' },
              { type: :multiple_choice,
                question: 'A pentatonica menor de E tem as mesmas notas da pentatonica maior de:', options: %w[C D G A], answer: 'G' }
            ]
          ),

          new(
            id: '2.4',
            title: 'Escala Blues',
            level_index: 1,
            content: <<~CONTENT,
              A escala blues eh a pentatonica menor com UMA nota extra:
              a famosa BLUE NOTE (b5 ou #4).

              Pentatonica menor: 1  b3  4     5  b7
              Blues:             1  b3  4  b5  5  b7

              Em A: A  C  D  Eb  E  G

              Essa nota extra (Eb em A) eh o que da aquele "tempero"
              do blues. Use ela de PASSAGEM, nao pare nela!

              Dica pratica: no shape 1 da pentatonica menor,
              a blue note fica entre o 4o e 5o grau.
            CONTENT
            exercises: [
              { type: :scale_build, question: 'Monte a escala blues de A', root: 'A', scale_type: :blues },
              { type: :multiple_choice, question: 'O que diferencia a blues da pentatonica menor?',
                options: ['A blue note (b5)', 'A setima maior', 'A terca maior', 'A nona'], answer: 'A blue note (b5)' },
              { type: :fill_in, question: 'Qual a blue note na escala blues de E?', answer: 'Bb' }
            ]
          ),

          # === NIVEL 3: MENESTREL ===
          new(
            id: '3.1',
            title: 'Intervalos - a distancia entre notas',
            level_index: 2,
            content: <<~CONTENT,
              Intervalo eh a DISTANCIA entre duas notas.
              Em vez de decorar nomes, pense em SEMITONS:

              1 semitom  = Segunda menor (b2)  - som tenso, Tubarao
              2 semitons = Segunda maior (2)   - som de "Parabens"
              3 semitons = Terca menor (b3)    - Smoke on the Water
              4 semitons = Terca maior (3)     - som alegre
              5 semitons = Quarta justa (4)    - Marcha Nupcial
              6 semitons = Tritono (b5)        - Os Simpsons
              7 semitons = Quinta justa (5)    - Star Wars
              10 semitons = Setima menor (b7)  - tema Star Trek
              11 semitons = Setima maior (7)   - Take On Me

              Macete: associe cada intervalo a uma musica que voce conhece!
            CONTENT
            exercises: [
              { type: :interval, question: 'Quantos semitons de C ate E?', from: 'C', to: 'E', answer: 4 },
              { type: :interval, question: 'Quantos semitons de A ate C?', from: 'A', to: 'C', answer: 3 },
              { type: :interval, question: 'Quantos semitons de G ate D?', from: 'G', to: 'D', answer: 7 },
              { type: :multiple_choice, question: '3 semitons formam qual intervalo?',
                options: ['Terca maior', 'Terca menor', 'Quarta justa', 'Segunda maior'], answer: 'Terca menor' },
              { type: :multiple_choice, question: 'Qual musica ajuda a lembrar da quinta justa?',
                options: ['Tubarao', 'Parabens', 'Star Wars', 'Smoke on the Water'], answer: 'Star Wars' }
            ]
          ),

          new(
            id: '3.2',
            title: 'Como acordes sao formados',
            level_index: 2,
            content: <<~CONTENT,
              Um acorde eh um conjunto de 3 ou mais notas tocadas juntas.
              O acorde mais simples eh a TRIADE (3 notas):

              Triade = 1a + 3a + 5a (graus da escala)

              Acorde MAIOR: 1 + 3 + 5  (terca maior + quinta justa)
              C maior: C + E + G  (0 + 4 + 7 semitons)

              Acorde MENOR: 1 + b3 + 5  (terca menor + quinta justa)
              Cm: C + Eb + G  (0 + 3 + 7 semitons)

              A UNICA diferenca entre maior e menor eh a TERCA!
              Maior = terca maior (4 semitons) = som alegre
              Menor = terca menor (3 semitons) = som triste

              Acorde DIMINUTO: 1 + b3 + b5  (terca menor + quinta diminuta)
              Cdim: C + Eb + Gb  (0 + 3 + 6 semitons) = som tenso
            CONTENT
            exercises: [
              { type: :multiple_choice, question: 'Quantas notas tem uma triade?', options: %w[2 3 4 5], answer: '3' },
              { type: :multiple_choice, question: 'A diferenca entre acorde maior e menor eh:',
                options: ['A quinta', 'A terca', 'A fundamental', 'A setima'], answer: 'A terca' },
              { type: :chord_notes, question: 'Quais notas formam C maior?', chord: 'C', expected: %w[C E G] },
              { type: :chord_notes, question: 'Quais notas formam Am?', chord: 'Am', expected: %w[A C E] },
              { type: :chord_notes, question: 'Quais notas formam G?', chord: 'G', expected: %w[G B D] }
            ]
          ),

          new(
            id: '3.3',
            title: 'Campo harmonico',
            level_index: 2,
            content: <<~CONTENT,
              O campo harmonico mostra TODOS os acordes que pertencem
              a um tom. Se uma musica esta em C maior, estes sao os
              acordes que "combinam":

              I    II   III   IV    V    VI   VII
              C    Dm   Em    F     G    Am   Bdim

              Repare no padrao: Maior, menor, menor, Maior, Maior, menor, dim
              Esse padrao eh SEMPRE o mesmo em qualquer tom maior!

              Em G maior:
              I    II   III   IV    V    VI   VII
              G    Am   Bm    C     D    Em   F#dim

              Agora voce entende por que Am, F, C, G soam bem juntos:
              todos pertencem ao campo harmonico de C maior!

              Funcoes:
              - I, III, VI = TONICA (repouso)
              - IV, II = SUBDOMINANTE (movimento)
              - V, VII = DOMINANTE (tensao que quer resolver no I)
            CONTENT
            exercises: [
              { type: :multiple_choice, question: 'O padrao do campo harmonico maior eh:',
                options: ['M m m M M m dim', 'm M M m m M dim', 'M M m M m m dim', 'M m M m M m dim'], answer: 'M m m M M m dim' },
              { type: :fill_in, question: 'Qual o IV grau de C maior?', answer: 'F' },
              { type: :fill_in, question: 'Qual o V grau de G maior?', answer: 'D' },
              { type: :multiple_choice, question: 'Am, F, C, G pertencem ao campo de:',
                options: ['G maior', 'C maior', 'D maior', 'A maior'], answer: 'C maior' },
              { type: :multiple_choice, question: 'O V grau tem funcao de:',
                options: %w[Tonica Subdominante Dominante Mediante], answer: 'Dominante' }
            ]
          ),

          # === NIVEL 4: BARDO ===
          new(
            id: '4.1',
            title: 'Tetrades - acordes com setima',
            level_index: 3,
            content: <<~CONTENT,
              Tetrades sao acordes com 4 notas: a triade + a setima.

              Tipos principais:
              maj7  = 1 + 3 + 5 + 7   (setima maior) - Cmaj7: C E G B
              m7    = 1 + b3 + 5 + b7  (menor com 7a) - Cm7: C Eb G Bb
              7     = 1 + 3 + 5 + b7   (dominante)    - C7: C E G Bb
              m7b5  = 1 + b3 + b5 + b7 (meio-dim)     - Cm7b5: C Eb Gb Bb

              Campo harmonico com tetrades (C maior):
              I      II    III    IV      V     VI    VII
              Cmaj7  Dm7   Em7   Fmaj7   G7    Am7   Bm7b5

              O V grau eh o unico DOMINANTE (7)!
              Isso eh importante: o som do acorde dominante (3+b7)
              cria tensao que quer resolver no I.
            CONTENT
            exercises: [
              { type: :chord_notes, question: 'Quais notas formam Cmaj7?', chord: 'Cmaj7', expected: %w[C E G B] },
              { type: :chord_notes, question: 'Quais notas formam G7?', chord: 'G7', expected: %w[G B D F] },
              { type: :multiple_choice, question: 'Qual grau do campo harmonico maior eh dominante (7)?',
                options: %w[I III V VII], answer: 'V' },
              { type: :multiple_choice, question: 'A diferenca entre maj7 e 7 (dominante) eh:',
                options: ['A setima (maior vs menor)', 'A terca', 'A quinta', 'A fundamental'], answer: 'A setima (maior vs menor)' }
            ]
          ),

          new(
            id: '4.2',
            title: 'Funcoes harmonicas na pratica',
            level_index: 3,
            content: <<~CONTENT,
              As funcoes harmonicas explicam o PAPEL de cada acorde:

              TONICA (I, iii, vi) - Repouso, resolucao, "casa"
                Soa estavel. Musicas geralmente comecam e terminam aqui.

              SUBDOMINANTE (IV, ii) - Movimento, preparacao
                Cria sensacao de "saindo de casa". Prepara a dominante.

              DOMINANTE (V, vii) - Tensao, necessidade de resolver
                O ouvido PEDE para voltar a tonica. O V7 -> I eh a
                resolucao mais forte da musica.

              Progressoes classicas:
              I - IV - V - I       (basica, rock, folk)
              I - V - vi - IV      (pop, a progressao mais usada no mundo)
              ii - V - I           (jazz, a mais importante do jazz)
              I - vi - IV - V      (anos 50, doo-wop)
            CONTENT
            exercises: [
              { type: :multiple_choice, question: 'Qual funcao cria tensao e quer resolver?',
                options: %w[Tonica Subdominante Dominante Mediante], answer: 'Dominante' },
              { type: :multiple_choice, question: 'I-V-vi-IV em C maior seria:',
                options: ['C-G-Am-F', 'C-F-Am-G', 'C-G-Em-F', 'C-F-Dm-G'], answer: 'C-G-Am-F' },
              { type: :multiple_choice, question: 'ii-V-I em C maior seria:',
                options: ['Dm-G-C', 'Em-A-D', 'Am-D-G', 'Dm-F-C'], answer: 'Dm-G-C' },
              { type: :multiple_choice, question: 'Em qual funcao uma musica geralmente termina?',
                options: %w[Tonica Subdominante Dominante], answer: 'Tonica' }
            ]
          ),

          new(
            id: '4.3',
            title: 'Modos gregos',
            level_index: 3,
            content: <<~CONTENT,
              Os modos gregos sao 7 "sabores" diferentes de escala.
              Cada um tem uma SONORIDADE unica.

              Pense assim: os modos NAO sao "a escala maior comecando
              de outra nota". Eles sao SONORIDADES independentes.

              Modos MAIORES (tem terca maior):
              Jonio (I)     = Escala maior normal. Alegre.
              Lidio (IV)    = Maior com #4. Sonhador, etéreo. (Simpsons!)
              Mixolidio (V) = Maior com b7. Rock, blues, dominante.

              Modos MENORES (tem terca menor):
              Dorico (II)   = Menor com 6a maior. Santana, funk, jazz.
              Frigio (III)  = Menor com b2. Espanhol, flamenco, metal.
              Eolio (VI)    = Escala menor natural. Triste.
              Locrio (VII)  = Menor com b2 e b5. Instavel, raro.

              Dica pratica: sobre Dm7 no campo de C, voce pode usar
              D dorico (que tem as mesmas notas de C maior, mas com
              "centro de gravidade" em D).
            CONTENT
            exercises: [
              { type: :multiple_choice, question: 'Qual modo tem som espanhol/flamenco?',
                options: %w[Dorico Frigio Lidio Mixolidio], answer: 'Frigio' },
              { type: :multiple_choice, question: 'Qual modo eh bom sobre acordes dominantes (7)?',
                options: %w[Jonio Dorico Lidio Mixolidio], answer: 'Mixolidio' },
              { type: :multiple_choice, question: 'Qual modo eh associado ao som do Santana?',
                options: %w[Frigio Dorico Eolio Locrio], answer: 'Dorico' },
              { type: :scale_build, question: 'Monte D dorico (mesmas notas de C maior, comecando em D)', root: 'D',
                scale_type: :dorian },
              { type: :multiple_choice, question: 'A diferenca entre lidio e jonio (maior) eh:',
                options: ['b3', '#4', 'b7', '#2'], answer: '#4' }
            ]
          ),

          new(
            id: '4.4',
            title: 'Improvisacao consciente',
            level_index: 3,
            content: <<~CONTENT,
              Agora que voce sabe escalas, campo harmonico e modos,
              vamos juntar tudo para IMPROVISAR COM CONSCIENCIA.

              Regras praticas:

              1. SAFE CHOICE: Pentatonica menor na tonica da musica.
                 Musica em Am? Use A pentatonica menor. Sempre funciona.

              2. POR ACORDE: Escolha a escala baseado no acorde atual:
                 - Acorde maior -> Jonio ou Lidio
                 - Acorde menor -> Dorico ou Eolio
                 - Acorde dominante (7) -> Mixolidio
                 - Acorde m7b5 -> Locrio

              3. NOTAS-ALVO: Mire nas notas DO ACORDE nos tempos fortes.
                 Sobre Am7 (A C E G), toque A, C, E ou G nos tempos 1 e 3.

              4. CROMATISMO: Use notas fora da escala como PASSAGEM.
                 Chegue numa nota do acorde por um semitom acima ou abaixo.

              Use o comando 'bardo suggest' para ver sugestoes por acorde!
            CONTENT
            exercises: [
              { type: :multiple_choice, question: 'Safe choice para improvisar em qualquer tom menor:',
                options: ['Escala maior', 'Pentatonica menor', 'Modo locrio', 'Escala cromatica'], answer: 'Pentatonica menor' },
              { type: :multiple_choice, question: 'Sobre Dm7, qual modo funciona melhor?',
                options: %w[Jonio Dorico Mixolidio Locrio], answer: 'Dorico' },
              { type: :multiple_choice, question: 'Sobre G7, qual modo funciona melhor?',
                options: %w[Jonio Dorico Mixolidio Locrio], answer: 'Mixolidio' },
              { type: :multiple_choice, question: 'Notas-alvo sobre Am7 (A C E G) nos tempos fortes sao:',
                options: ['Qualquer nota', 'Notas do acorde', 'So a tonica', 'Notas cromaticas'], answer: 'Notas do acorde' }
            ]
          )
        ]
      end

      private_class_method :build_curriculum
    end
  end
end
