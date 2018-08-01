extensions [ rnd ]
globals
[
  oilPrice
  road
  numberOfRows
  numberOfColumns
  spaceBetweenRows
  spaceBetweenColumns
]


breed[cars car]
breed[gasstations gasstation]

cars-own
[
  maxCapacity
  currentFuel
  consumptionRate
  preference
  fuelThreshold
  movingToStation
  surroundingGasStations
  lastKnownPrice
  target-station
  priceSensitivity
  distanceSensitivity
]

gasstations-own
[
  price
  brand
  demand
  visited
  earnings
  name
]

;;;;;;;;;;;;;;;;;;;;;;
;; Setup Procedures ;;
;;;;;;;;;;;;;;;;;;;;;;

to setup
  clear-all
  setup-globals
  setup-streets
  let i 0
  create-cars number-of-cars
  [
    setup-cars
  ]
  create-gasstations 5
  [
    ask gasstations [

    if i = 0 [
      setxy 34 39
      set name "Total"
      set color red
      set brand 0
    ]
    if i = 1 [
      setxy -34 -37
      set name "Aral"
      set color red
      set brand 0
    ]
    if i = 2 [
      setxy 34 -37
      set name "Jet"
      set color green
      set brand 1
    ]
    if i = 3 [
      setxy 0 1
      set name "Star"
      set color green
      set brand 1
    ]
    if i = 4 [
      setxy -34 39
      set name "BFT"
      set color green
      set brand 1
    ]

    set i i + 1
  ]
    setup-gasstations
  ]

  reset-ticks
end

;; Initialize the global variables to appropriate values
to setup-globals
  set oilPrice 1.35
  set numberOfRows 3
  set numberOfColumns 4
  set spaceBetweenRows world-width / numberOfRows
  set spaceBetweenColumns world-height / numberOfColumns
end

to setup-streets
  ask patches
  [
    set pcolor brown

    set road patches with
       [(floor((pxcor + max-pxcor - floor(spaceBetweenRows - 1)) mod spaceBetweenRows) = 0) or
       (floor((pycor + max-pycor) mod spaceBetweenColumns) = 0)]
  ]
  ask road [ set pcolor grey ]

end

to setup-cars
  set shape "car"
  set size 1.5
  set color blue
  move-to one-of road

  set movingToStation false
  set maxCapacity 100
  set currentFuel (100 - random 20)
  set consumptionRate (2 - random 1)
  set preference random 2
  set fuelThreshold 35
  set surroundingGasStations []
  set lastKnownPrice oilPrice
  set target-station nobody
  set priceSensitivity random 100
  set distanceSensitivity random 100
end

to setup-gasstations
  set shape "house"
  set size 2
  set price oilPrice
  ;; move-to one-of road with [abs pxcor < floor (world-width / 2) and abs pycor < floor (world-height / 2)]
  set demand 0
  set earnings 0
  let priceDecimals (precision price 2)
  set label (word name "," precision price 2)
end

;;;;;;;;;;;;;;;;;;;;;;;
;; Action Procedures ;;
;;;;;;;;;;;;;;;;;;;;;;;

to go
  ask cars [
    set currentFuel currentFuel - consumptionRate
    repeat 3 [move]
  ]

  ifelse ticks = 0 or ticks mod 24 = 0 [
    setDailyPrice
  ][
    setHourlyPrice
  ]

  display-labels
  tick
end

to move  ; turtle procedure
  let movingOptions neighbors4 with [pcolor = 5]

  if movingToStation = false [
    ifelse count movingOptions = 4 [
      move-to one-of movingOptions
    ][
      ifelse [pxcor] of self = floor (world-width / 2) or [pycor] of self = floor (world-height / 2) [
        move-to one-of movingOptions with [pxcor < [pxcor] of myself or pycor < [pycor] of myself ]
      ][
        let moveTo one-of movingOptions with [pxcor > [pxcor] of myself or pycor > [pycor] of myself ]
        ifelse moveTo = nobody [
          move-to one-of movingOptions
        ][
          move-to moveTo
        ]
      ]
    ]
  ]

  if currentFuel <= fuelThreshold [
    search
    decide
  ]
  death
end

to display-labels
  ask cars [ set label round currentFuel ]
end

to setDailyPrice

  if oilPrice > 1 and oilPrice < 1.6 [ set oilPrice (oilPrice + random-float 0.1 - random-float 0.1) ]
  if oilPrice >= 1.6 [ set oilPrice oilPrice - random 0.1 ]
  if oilPrice <= 1 [ set oilPrice oilPrice + random 0.1 ]
  let leadingPrice oilPrice + abs (random-float 0.1 - random-float 0.06)
  ask gasstations [
    ifelse brand = 0 [
      set price leadingPrice
    ][
      set price leadingPrice - random-float 0.02
      if price < oilPrice [
        set price leadingPrice
      ]
    ]
    set visited 0
    set demand 0
    set label (word name "," precision price 2)
  ]

end

to setHourlyPrice

  let cheapestGasStation min-one-of gasstations [price]
  let tmpRandom random-float 0.02
  ask gasstations [

    ifelse demand <= (mean [demand] of gasstations) [
      ifelse [price] of cheapestGasStation - tmpRandom > oilPrice [
        set price [price] of cheapestGasStation - tmpRandom
      ][
        set price [price] of cheapestGasStation
      ]
    ][
      if price + tmpRandom < oilPrice [
        set price price + tmpRandom
      ]
    ]
    set label (word name "," precision price 2)
  ]

end

to search
  set surroundingGasStations (gasstations in-radius 25)
end

to decide
  let tx 0
  let ty 0


  if any? surroundingGasStations and target-station = nobody and movingToStation = false [
    let bestStationValue 999999999
    let takeSecondBest false
    let chosenStation nobody

    ask surroundingGasStations [
      let maxRange ([currentFuel] of myself / [consumptionRate] of myself)
      let stationValue ([priceSensitivity] of myself * price) + ([distanceSensitivity] of myself * ([distance myself] of self / maxRange))
      if stationValue < bestStationValue [
        set bestStationValue stationValue
        ifelse takeSecondBest = true [
          set chosenStation self
        ][
          ;; biased - if i prefer highprice gasstations i will not choose cheap ones at all
          ;; if i prefer cheap stations, i will only refuel if the price is low, compared to my reference point
          ;; preference 0 = high price, preference 1 = cheap price
          ;; random aspect because sometimes people refuel at the stations they usually dont prefer
          let randomAspect random 100
          ifelse (([preference] of myself) = 0 and brand = 1) or (([preference] of myself) = 1 and brand = 0) [
            ifelse randomAspect < 75 [
              set takeSecondBest true
            ][
              set chosenStation self
            ]
          ][
            set chosenStation self
          ]
        ]
      ]
    ]
    set target-station chosenStation
    ;set target-station min-one-of surroundingGasStations [distance myself]
  ]


  if target-station != nobody  [
    face target-station

    set movingToStation true
    set tx [pxcor] of target-station
    set ty [pycor] of target-station
    ifelse distance target-station < 1 [
      move-to target-station
      refuel
    ][
      forward 1
      ;move-to min-one-of neighbors with [pcolor = 5] [distancexy tx ty]
    ]
  ]
end

to refuel
  move-to target-station
  set movingToStation false
  let stationPrice 0
  ask target-station [
    set earnings earnings + ([maxCapacity] of myself - [currentFuel] of myself) * (price - oilPrice)
    set visited visited + 1
    set demand visited / ticks
    set stationPrice price
  ]
  set lastKnownPrice stationPrice
  set currentFuel maxCapacity
end

to death
  if currentFuel < 1 [
    set currentFuel 100
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
10
10
739
740
-1
-1
14.14
1
12
1
1
1
0
1
1
1
-25
25
-25
25
1
1
1
ticks
60.0

BUTTON
762
12
846
49
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
853
12
932
49
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
766
110
904
155
Oil Price
precision oilPrice 3
17
1
11

SLIDER
765
64
937
97
number-of-cars
number-of-cars
5
50
48.0
1
1
NIL
HORIZONTAL

PLOT
987
14
1248
187
Demand of gasstations
Ticks
Demand
0.0
5.0
0.0
0.3
true
false
"" ""
PENS
"pen-0" 1.0 1 -13840069 true "" "plot-pen-reset\nforeach sort gasstations [ [t] -> ask t [ plot demand ] ]"

PLOT
1349
10
1604
191
Fuel of cars
Car
Fuel
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "plot-pen-reset\nforeach sort cars [ [t] -> ask t [ plot currentFuel ] ]"

PLOT
987
191
1247
341
Earnings of gasstations
Ticks
Earnings
0.0
5.0
0.0
1.0
true
false
"" ""
PENS
"pen-0" 1.0 1 -16777216 true "" "plot-pen-reset\nforeach sort gasstations [ [t] -> ask t [ plot demand ] ]"

PLOT
1349
193
1605
343
Marge of gasstation
Ticks
Marge
0.0
5.0
0.0
0.1
false
false
"" ""
PENS
"default" 1.0 1 -11085214 true "" "plot-pen-reset\nforeach sort gasstations [ [t] -> ask t [ plot (price - oilPrice) ] ]"

PLOT
745
345
1363
584
Earning over Time
Ticks
Earnings
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Aral" 1.0 0 -14070903 true "" "ask gasstations [\n  if name = \"Aral\" [\n    plot earnings\n  ]\n]\n"
"Total" 1.0 0 -2674135 true "" "ask gasstations [\n  if name = \"Total\" [\n    plot earnings\n  ]\n]\n"
"Jet" 1.0 0 -1184463 true "" "ask gasstations [\n  if name = \"Jet\" [\n    plot earnings\n  ]\n]\n"
"BFT" 1.0 0 -15040220 true "" "ask gasstations [\n  if name = \"BFT\" [\n    plot earnings\n  ]\n]\n"
"Star" 1.0 0 -3844592 true "" "ask gasstations [\n  if name = \"Star\" [\n    plot earnings\n  ]\n]\n"

PLOT
746
590
1364
820
Prices over Time
Ticks
Price
0.0
10.0
1.3
1.5
true
true
"" ""
PENS
"Aral" 1.0 0 -13345367 true "" "ask gasstations [\n  if name = \"Aral\" [\n    plot price\n  ]\n]\n"
"Total" 1.0 0 -2674135 true "" "ask gasstations [\n  if name = \"Total\" [\n    plot price\n  ]\n]"
"Jet" 1.0 0 -1184463 true "" "ask gasstations [\n  if name = \"Jet\" [\n    plot price\n  ]\n]\n"
"BFT" 1.0 0 -12087248 true "" "ask gasstations [\n  if name = \"BFT\" [\n    plot price\n  ]\n]\n"
"Star" 1.0 0 -3844592 true "" "ask gasstations [\n  if name = \"Star\" [\n    plot price\n  ]\n]\n"

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
NetLogo 6.0.3
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="2" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>count cars</metric>
    <metric>mean [price] of gasstations</metric>
    <enumeratedValueSet variable="number-of-cars">
      <value value="10"/>
      <value value="20"/>
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="following-gas-stations">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="leading-gas-stations">
      <value value="2"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
