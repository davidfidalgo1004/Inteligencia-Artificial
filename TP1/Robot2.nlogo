;; globals
globals[cor_chao cor_objetos posto_carregamento depositos lista_objetos tick_bug_fix tipo_lixo num_polluters cleaner_max_battery eco med turbo]
breed[cleaners cleaner]
breed[polluters polluter]
breed[containers container]
breed[obstacles obstacle]
cleaners-own[battery capacity recharge_time last_cleaning_location cleaner_consumption_battery cleaner_potencia_battery cleaner_stop]
polluters-own[prob_sujar]

to Config_Battery
  set eco "Eco Mode"
  set med "Medium Mode"
  set turbo "Full Mode"

  ask cleaners[
    if Cleaner_Modo = eco [
      ;; comportamento para o modo Eco
      set cleaner_potencia_battery 10
    ]
    if Cleaner_Modo = med [
      ;; comportamento para o modo Médio
      set cleaner_potencia_battery 30
    ]
    if Cleaner_Modo = turbo [
      ;; comportamento para o modo Full
      set cleaner_potencia_battery 50
    ]
    let cleaner_corrente_battery (cleaner_potencia_battery / cleaner_tensao_battery) * 1000;; isto é a corrente em mA
    let cleaner_ma_segundo_battery cleaner_corrente_battery / 3600 ;; aqui o gasto de mA por segundo
    set cleaner_consumption_battery (cleaner_ma_segundo_battery / cleaner_capacity_battery) * 100
  ]

end



;setup, cujo programa permita: limpar o ambiente; criar e introduzir no mundo os agentes e fazer o reset do tempo.
to setup
  clear-all
  reset-ticks
  set tick_bug_fix 10000 ; de 10000 em 10000 ticks reset da last_cleaning location senao ele pode ficar preso num loop de ir de ponta a ponta
  set tipo_lixo (list (range 2.5 7.5 0.5)(range 32.5 37.5 0.5)(range 52.5 57.5 0.5))
  set cor_chao 8.5
  set cor_objetos magenta
  set cleaner_max_battery 100
  ask patches[
    set pcolor cor_chao
  ]
  set posto_carregamento [-16 -16]
  ask patch item 0 posto_carregamento item 1 posto_carregamento[;; caso mude tamanho do world
    set pcolor black
  ]

  ;;padrões do dicionário do netlogo
  create-cleaners 1
  create-polluters 3

  ask cleaners[
    set shape "vaccum"
    set size 2.5
    let canto_inferior_esquerdo (list min-pxcor min-pycor) ; origem do cleaner (posto de carregamento)
    setxy (item 0 canto_inferior_esquerdo ) (item 1 canto_inferior_esquerdo) ;; criado no canto inferior esquerdo
    set battery 100
    set capacity 0
    set last_cleaning_location [0 0]
    set cleaner_stop 0
  ]
  Config_Battery

  ask polluters[
    set shape "cow"
    set size 2
    set color white
    set label-color black
    set label who
    setxy random-pxcor random-pycor
  ]
  ask polluter 1 [ set color 5 ]
  ask polluter 2 [ set color 35 ]
  ask polluter 3 [ set color 55 ]

  ;;criacao de depositos
  let i 1
  set depositos []
  ask patches [
    set i count patches with [pcolor = blue]
    if pcolor = cor_chao and i < num_depositos[;; evitar depositos juntos (fica confuso)
      if all? neighbors4 [pcolor = cor_chao] [
        set pcolor blue
        sprout-containers 1
        set depositos fput (list pxcor pycor) depositos
      ]
    ]
  ]
  ask containers[
    set shape "garbage can"
    set size 2
    set color grey
  ]

  ;;criacao obstaculos
  set i 0
  set lista_objetos []
  ask patches[
    set i count patches with [pcolor = cor_objetos]
    if pcolor = cor_chao and i < num_obstaculos * 4 and pxcor < 16 and pycor > -16[
      let object1 (list (list pxcor pycor) (list (pxcor + 1) pycor) (list pxcor (pycor - 1)) (list (pxcor + 1) (pycor - 1)))
      let pode_gerar true
      foreach object1 [ coord ->
        let x item 0 coord
        let y item 1 coord
        if [pcolor] of patch x y != cor_chao [
          set pode_gerar false
        ]
      ]
      if pode_gerar [
        foreach object1 [coord ->
          let x first coord
          let y last coord
          ask patch x y [
            set pcolor cor_objetos  ;; Replace cor_objetos with the desired color
          ]
        ]
        set lista_objetos fput object1 lista_objetos
      ]
    ]
  ]
end

;go_once, cujo programa permita: que os agentes circulem no mundo de forma aleatória (um só tick);
to go_once
  ;;atualizar probabilidades dos sliders
  ask polluters[
    if color = 5  [set prob_sujar polluter_1_prob_sujar]
    if color = 35 [set prob_sujar polluter_2_prob_sujar]
    if color = 55 [set prob_sujar polluter_3_prob_sujar]
  ]
  Config_Battery
  ;;ask polluters [show prob_sujar];; (debug)

  ;;atualizar depositos
  let i 1
  ask patches [
    set i count patches with [pcolor = blue]
    if pcolor = cor_chao and i < num_depositos[
      set pcolor blue
      set depositos lput (list pxcor pycor) depositos
      sprout-containers 1 [
        set shape "garbage can"
        set size 2
        set color grey
      ]
    ]
    if i > num_depositos and pcolor = blue[
      set pcolor cor_chao
      ask containers-here[die]
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
        ;; HEADINGS E AS SUAS CONDICOES
        ;;1º verificar a bateria (modelo Robot1 dirige-se ao posto quando chega a uma certa percentagem)
        ask cleaners[
          ifelse battery <= 100 * cleaner_consumption_battery[;; dirigir ao posto de carregamento quando so faltarem 50 movimentos
            if last_cleaning_location = [0 0][;; aspirador guarda sitio onde estava a aspirar até ter de ir carregar bateria
              set last_cleaning_location (list round xcor round ycor)
              if ticks > tick_bug_fix [set last_cleaning_location [-15 -15] set tick_bug_fix tick_bug_fix + 10000]; senao ele fica la em cima e nao volta.... porque nao tem movimentos random suficiente para voltar para baixo
            ]
            facexy item 0 posto_carregamento item 1 posto_carregamento ;; código direcçao à bateria
          ][
            ifelse capacity >= cleaner_max_capacity[
              ;; modo ir depositar
              ifelse [pcolor] of patch-here = blue[
                set capacity 0 ;; esvazia capacidade toda (ia melhorar mas melhor guardar para fase 2
              ][
                let target-patch min-one-of (patches in-radius 40 with [pcolor = blue]) [distance myself] ;;(apenas esta linha é)solucao stackoverflow :"https://stackoverflow.com/questions/36019543/turtles-move-to-nearest-patch-of-a-certain-color-how-can-this-process-be-sped"
                if target-patch != nobody[
                  ask cleaner cleaner_atual[
                    face target-patch ;;; direcionar para o deposito
                  ]
                ]
              ]
            ][
              ;;movimento modo aspirar
              ifelse last_cleaning_location != [0 0][ ;; voltar ao local anterior
                facexy item 0 last_cleaning_location item 1 last_cleaning_location ;;;TO UPGRADE: virar caso bata enquanto vai para sitio dele
              ][ ;aspirar área desconhecida:
                 ;; logica de virar quando bate em algo para cobrir terreno desconhecido (retirado de: https://youtu.be/O7ozptNs1FY?si=MSywmYDwbmLPsnCb )
                if patch-ahead 1 = nobody or ([pcolor] of patch-ahead 1 = cor_objetos) [set heading random 360]
              ]
            ]
          ]
          ;; MOVER (EM FUNCAO DOS HEADINGS)
          if cleaner_stop = 0[
            if patch-ahead 1 != nobody [
              if [pcolor] of patch-at-heading-and-distance heading 1 = cor_objetos [
                right 180
                right random 90 - random 90
              ]
              if battery > 0 [fd 1]
            ]
            ifelse battery <= 0 [
              set battery 0
            ][
              set battery battery - cleaner_consumption_battery
            ]
          ]
          if cleaner_stop = 1 [
            set battery battery - (cleaner_consumption_battery / 10)
          ]
          if last_cleaning_location = (list round xcor round ycor) or last_cleaning_location = [-15 -15] [ set last_cleaning_location [0 0]];; -15 -15 por causa dos ticks
          if capacity < cleaner_max_capacity[
            ask patch-here [
              if pcolor != cor_chao and pcolor != black and pcolor != blue and pcolor != cor_objetos or [cleaner_stop] of cleaner 0 = 1[
                let cor_lixo pcolor
                let cod_cor (cor_lixo mod 10)
                ask cleaners [
                  if cod_cor >= 2.5 and cod_cor <= 3.5 and cleaner_max_capacity >= capacity + 3[
                    if Cleaner_Modo = eco or Cleaner_Modo = med[
                      set pcolor pcolor + 1.5
                      set capacity capacity + 1
                      set cleaner_stop 1
                    ]
                    if Cleaner_Modo = turbo [
                      set capacity capacity + 3
                      set pcolor cor_chao
                      set cleaner_stop 0
                    ]
                  ]
                  if cod_cor >= 4 and cod_cor <= 6 and cleaner_max_capacity >= capacity + 2[
                    if Cleaner_Modo = eco[
                      set pcolor pcolor + 2.5
                      set capacity capacity + 1
                      set cleaner_stop 1
                    ]
                    if Cleaner_Modo = med or Cleaner_Modo = turbo [
                      set capacity capacity + 2
                      set pcolor cor_chao
                      set cleaner_stop 0
                    ]
                  ]
                  if cod_cor >= 6.5 and cleaner_max_capacity >= capacity + 1[
                    set capacity capacity + 1
                    set pcolor cor_chao
                    set cleaner_stop 0
                  ]
                ]
              ]
            ]
          ]
        ];;fim encontrar residuo
      ]
      ;ask patch-here [set pcolor red]; pinta area vizinha vermelho (debug)
      ;ask neighbors [ set pcolor red ];; pinta area vizinha vermelho (debug)
    ]
  ]

  ;;ações dos polluters
  ask polluters[
    ;;movimento
    ifelse patch-ahead 1 = nobody [set heading random 360][
      if [pcolor] of patch-at-heading-and-distance heading 1 = cor_objetos [
        right 180
        right random 90 - random 90
      ]
      fd 1
    ]
;    move-to patch-here
;    if ([pcolor] of patch-here = cor_objetos) [
;      let target-patch min-one-of (patches in-radius 5 with [pcolor = cor_chao]) [distance myself]
;      move-to target-patch
;    ]

    let rand_num random 100
    if (rand_num < prob_sujar * 100) [;; suja caso o nº atoa for menor que o da prob_sujar
      let conjunto_cor [0]
      if color = 5  [set conjunto_cor item 0 tipo_lixo]
      if color = 35 [set conjunto_cor item 1 tipo_lixo]
      if color = 55 [set conjunto_cor item 2 tipo_lixo]
      ask patch-here[
        if pcolor = cor_chao[ ; se estiver em chao
          let tom_de_cor_rand item (random (length conjunto_cor)) conjunto_cor
          set pcolor tom_de_cor_rand

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
468
34
532
67
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
556
34
638
67
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

MONITOR
472
303
694
348
Cleaner - Bateria Restante 
[battery] of cleaner 0
2
1
11

SLIDER
472
108
694
141
cleaner_max_capacity
cleaner_max_capacity
100
500
115.0
5
1
ml
HORIZONTAL

SLIDER
714
193
933
226
cleaner_tempo_carregamento
cleaner_tempo_carregamento
1
100
20.0
1
1
ticks
HORIZONTAL

SLIDER
473
193
692
226
polluter_1_prob_sujar
polluter_1_prob_sujar
0
1
0.28
0.01
1
NIL
HORIZONTAL

SLIDER
473
229
693
262
polluter_2_prob_sujar
polluter_2_prob_sujar
0
1
0.59
0.01
1
NIL
HORIZONTAL

SLIDER
473
265
692
298
polluter_3_prob_sujar
polluter_3_prob_sujar
0
1
0.31
0.01
1
NIL
HORIZONTAL

BUTTON
842
33
925
66
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
648
34
730
67
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
733
10
816
70
n
100.0
1
0
Number

MONITOR
472
144
694
189
Cleaner - Capacidade
[capacity] of cleaner 0
17
1
11

PLOT
472
360
937
549
Contaminação Vs Limpeza
Limpo
Sujo
0.0
1024.0
0.0
1024.0
true
true
"" ""
PENS
"Sujo" 1.0 2 -5298144 true "" "plot count patches with [pcolor != cor_chao ] - num_depositos - 1"
"Limpo" 1.0 2 -14439633 true "" "plot count patches with [pcolor = cor_chao]"

SLIDER
12
465
124
498
num_depositos
num_depositos
2
10
6.0
1
1
NIL
HORIZONTAL

SLIDER
714
230
933
263
cleaner_capacity_battery
cleaner_capacity_battery
90
5500
2740.0
10
1
mAh
HORIZONTAL

MONITOR
714
303
935
348
Consumo Cleaner (% ao segundo)
[cleaner_consumption_battery] of cleaner 0
10
1
11

SLIDER
714
266
932
299
cleaner_tensao_battery
cleaner_tensao_battery
14
18
14.8
0.1
1
V
HORIZONTAL

CHOOSER
712
96
932
141
Cleaner_Modo
Cleaner_Modo
"Eco Mode" "Medium Mode" "Full Mode"
0

MONITOR
713
144
933
189
Potencia Cleaner (em watts)
[cleaner_potencia_battery] of cleaner 0
2
1
11

SLIDER
144
467
262
500
num_obstaculos
num_obstaculos
0
30
17.0
1
1
NIL
HORIZONTAL

MONITOR
288
463
428
508
Minutes Passed
ticks / 60
0
1
11

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

garbage can
false
0
Polygon -16777216 false false 60 240 66 257 90 285 134 299 164 299 209 284 234 259 240 240
Rectangle -7500403 true true 60 75 240 240
Polygon -7500403 true true 60 238 66 256 90 283 135 298 165 298 210 283 235 256 240 238
Polygon -7500403 true true 60 75 66 57 90 30 135 15 165 15 210 30 235 57 240 75
Polygon -7500403 true true 60 75 66 93 90 120 135 135 165 135 210 120 235 93 240 75
Polygon -16777216 false false 59 75 66 57 89 30 134 15 164 15 209 30 234 56 239 75 235 91 209 120 164 135 134 135 89 120 64 90
Line -16777216 false 210 120 210 285
Line -16777216 false 90 120 90 285
Line -16777216 false 125 131 125 296
Line -16777216 false 65 93 65 258
Line -16777216 false 175 131 175 296
Line -16777216 false 235 93 235 258
Polygon -16777216 false false 112 52 112 66 127 51 162 64 170 87 185 85 192 71 180 54 155 39 127 36

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
