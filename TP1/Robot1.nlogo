;; globals
globals[cor_chao posto_carregamento depositos tick_bug_fix]
breed[cleaners cleaner]
breed[polluters polluter]
cleaners-own[battery capacity recharge_time last_cleaning_location]
polluters-own[prob_sujar]

;setup, cujo programa permita: limpar o ambiente; criar e introduzir no mundo os agentes e fazer o reset do tempo.
to setup
  clear-all
  reset-ticks
  set tick_bug_fix 10000 ; de 10000 em 10000 ticks reset da last_cleaning location senao ele pode ficar preso num loop de ir de ponta a ponta

  set cor_chao 39
  ask patches[
    set pcolor cor_chao
  ]
  set posto_carregamento [-16 -16]
  ask patch item 0 posto_carregamento item 1 posto_carregamento[;; caso mude tamanho do world
    set pcolor black
  ]

  ;;criacao de depositos
  let i 1
  set depositos []
  ask patches [
    set i count patches with [pcolor = blue]
    if pcolor = cor_chao and i < num_depositos and one-of [pcolor] of neighbors4 != blue[;; nao há depositos juntos (fica confuso)
      show [pcolor] of neighbors4
      set pcolor blue
      set depositos fput (list pxcor pycor) depositos
    ]
  ]


  ;;padrões do dicionário do netlogo
  create-cleaners 1;
  create-polluters 3;

  ask cleaners[
    set shape "vaccum"
    set size 3.5
    ;;origem do cleaner (posto de carregamento)
    setxy -16 -16
    set battery cleaner_max_battery
    set capacity 0
    set last_cleaning_location [0 0]
  ]

  ask polluters[
    set shape "square"
    set size 1.5
    set color pink
    set label-color black
    set label who
    setxy random-pxcor random-pycor
  ]
end

;go_once, cujo programa permita: que os agentes circulem no mundo de forma aleatória (um só tick);
to go_once
  ;;atualizar probabilidades dos sliders
  ask polluter 1 [set prob_sujar polluter_1_prob_sujar]
  ask polluter 2 [set prob_sujar polluter_2_prob_sujar]
  ask polluter 3 [set prob_sujar polluter_3_prob_sujar]

  ;;ask polluters [show prob_sujar];; (debug)

  ;;atualizar depositos
  let i 1
  ask patches [
    set i count patches with [pcolor = blue]
    if pcolor = cor_chao and i < num_depositos[
      set pcolor blue
      set depositos fput (list pxcor pycor) depositos
    ]
    if i > num_depositos and pcolor = blue[
      set pcolor cor_chao
      set depositos remove (list pxcor pycor) depositos
    ]
  ]


  ;;ações do cleaner
  ask cleaners[
    ;ask neighbors [set pcolor 39];; pinta area vizinha da cor do chao (debug)
    ;ask patch-here [set pcolor 39]; pinta area vizinha vermelho (debug)
    let cleaner_atual who ;; para permitir mais cleaners e usar o codigo abaixo

    ;;modo carregar
    if battery > cleaner_max_battery [ set battery cleaner_max_battery]
    ask patch-here[
      ifelse pcolor = black and ([battery] of cleaner cleaner_atual < cleaner_max_battery) [; "já chegamos" método, verifica se já está no ponto de carregamento
        ask cleaners[
          let battery_a_cargar battery + (cleaner_max_battery / cleaner_tempo_carregamento);; battery_a_cargar é o cálculo de quanto a bateria vai carregar em um tick
          ifelse battery_a_cargar > cleaner_max_battery [ ; este if previne a bateria de atingir valores maiores à capacidade da bateria
            set battery cleaner_max_battery
          ][ ; se ainda faltar carregar
            set battery battery + (cleaner_max_battery / cleaner_tempo_carregamento) ;por cada tick para 100 max é tipo: 100/10 = 10% a cada tick
          ]
        ]
      ][
        ;;1º verificar a bateria (modelo Robot1 dirige-se ao posto quando chega a uma certa percentagem)
        ask cleaners[
          ifelse battery <= 50 * battery_loss[;; dirigir ao posto de carregamento quando so faltarem 50 movimentos
            if last_cleaning_location = [0 0][;; aspirador guarda sitio onde estava a aspirar até ter de ir carregar bateria
              set last_cleaning_location (list round xcor round ycor)
              if ticks > tick_bug_fix [set last_cleaning_location [-15 -15] set tick_bug_fix tick_bug_fix + 10000]; senao ele fica la em cima e nao volta.... porque nao tem movimentos random suficiente para voltar para baixo
            ]
            facexy item 0 posto_carregamento item 1 posto_carregamento
            fd 1
            set battery battery - battery_loss
          ][
            ifelse capacity >= cleaner_max_capacity[
              ;; modo ir depositar
              ifelse [pcolor] of patch-here = blue[
                set capacity 0 ;; esvazia capacidade toda (ia melhorar mas melhor guardar para fase 2
              ][
                let target-patch min-one-of (patches in-radius 40 with [pcolor = blue]) [distance myself] ;;(apenas esta linha é)solucao stackoverflow :"https://stackoverflow.com/questions/36019543/turtles-move-to-nearest-patch-of-a-certain-color-how-can-this-process-be-sped"
                if target-patch != nobody[
                  ask cleaner cleaner_atual[
                    face target-patch ;;; direcionar para o
                  ]
                ]
              ]
            ][
              ;;movimento modo aspirar
              ifelse last_cleaning_location != [0 0][ ;; voltar ao local anterior
                facexy item 0 last_cleaning_location item 1 last_cleaning_location ;;;TO UPGRADE: virar caso bata enquanto vai para sitio dele
              ][ ;aspirar área desconhecida:
                 ;; logica de virar quando bate em algo para cobrir terreno desconhecido (retirado de: https://youtu.be/O7ozptNs1FY?si=MSywmYDwbmLPsnCb )
                if patch-ahead 1 = nobody[set heading random 360]
              ]
            ]
            fd 1
            set battery battery - battery_loss
            if last_cleaning_location = (list round xcor round ycor) or last_cleaning_location = [-15 -15] [ set last_cleaning_location [0 0]];; -15 -15 por causa dos ticks
            if capacity < cleaner_max_capacity[
              ask patch-here[
                ;;encontrar residuo
                if pcolor != cor_chao and pcolor != black and pcolor != blue[ ;se estiver em cima de lixo
                  set pcolor cor_chao ; limpa
                  ask cleaners[
                    set capacity capacity + 1 ; armazena (if de segurança)
                  ]
                ]
              ]
            ];;fim encontrar residuo

          ]
        ;ask patch-here [set pcolor red]; pinta area vizinha vermelho (debug)
        ;ask neighbors [ set pcolor red ];; pinta area vizinha vermelho (debug)
      ]
    ]
  ]
]
  ;;ações dos polluters
  ask polluters[
    ;;movimento
    set heading random 360
    fd 1
    ;;sujar ou não sujar, eis a questão
    ask polluters[
      if (random 100 < prob_sujar * 100) [;; suja caso o nº atoa for menor que o da prob_sujar
        let tipo_lixo [32.5 42.5 52.5];tipos de lixo
        ask patch-here[
          if pcolor = cor_chao[ ; se estiver em chao
            set pcolor ( item (random 3) tipo_lixo) ;random para as cores/tipos de lixo (random 3; 0 1 2)
          ]
        ]
      ]
    ]
  ]
  tick
end

to go_n
  repeat n [
    go_once
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
12
10
449
448
-1
-1
13.0
1
10
1
1
1
0
0
0
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
472
24
536
57
Setup
setup\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
472
80
554
113
Go_Once
go_once
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
471
133
686
166
cleaner_max_battery
cleaner_max_battery
0
1000
1000.0
1
1
NIL
HORIZONTAL

MONITOR
11
462
156
507
Cleaner - Bateria Restante 
[battery] of cleaner 0
2
1
11

SLIDER
471
177
687
210
cleaner_max_capacity
cleaner_max_capacity
0
1000
60.0
1
1
NIL
HORIZONTAL

SLIDER
472
221
688
254
cleaner_tempo_carregamento
cleaner_tempo_carregamento
1
100
9.0
1
1
ticks
HORIZONTAL

SLIDER
471
268
690
301
polluter_1_prob_sujar
polluter_1_prob_sujar
0
1
0.16
0.01
1
NIL
HORIZONTAL

SLIDER
472
316
689
349
polluter_2_prob_sujar
polluter_2_prob_sujar
0
1
0.18
0.01
1
NIL
HORIZONTAL

SLIDER
472
368
690
401
polluter_3_prob_sujar
polluter_3_prob_sujar
0
1
0.18
0.01
1
NIL
HORIZONTAL

TEXTBOX
697
225
821
267
tempo carregamento:\ndo min ao max de bateria\n
11
0.0
1

TEXTBOX
694
135
972
191
Mudar \"cleaner_max_battery\" enquanto o aspirador trabalha pode prender o aspirador numa rota específica 
11
0.0
1

BUTTON
658
81
741
114
Go
go_once
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
564
80
646
113
Go_N
go_n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
564
17
647
77
n
100.0
1
0
Number

INPUTBOX
167
452
243
512
battery_loss
1.0
1
0
Number

MONITOR
261
460
399
505
Cleaner - Capacidade
[capacity] of cleaner 0
17
1
11

PLOT
742
285
1089
561
Contaminação Vs Limpeza
Limpo
Sujo
0.0
1024.0
0.0
1024.0
true
false
"" ""
PENS
"Sujo" 1.0 1 -14333415 true "" "plot count patches with [pcolor = 32.5 ]"
"Limpo" 1.0 1 -2570826 true "" "plot count patches with [pcolor = 38]"

SLIDER
429
466
536
499
num_depositos
num_depositos
2
10
3.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

vaccum
true
1
Rectangle -7500403 true false 105 105 120 135
Rectangle -7500403 true false 135 105 135 105
Rectangle -7500403 true false 120 105 135 120
Circle -2674135 true true 83 83 134
Circle -16777216 false false 75 75 150

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
