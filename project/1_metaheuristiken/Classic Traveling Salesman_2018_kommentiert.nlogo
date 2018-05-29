;;The number of solutions possible in the traveling salesman problem is equal to: (n - 1)!. Where n equals the number of cities.
;;With only 11 cities you have 3,628,800 solutions (10!).

extensions [ rnd ]

;;Jeder Turtle entspricht einer potenziellen Lösung des TSP (mit entsprechenden Zusatzinformationen) und damit einem Individuum im Evolutionärem Algorithmus (EA)
turtles-own [
  string        ;;speichert Reihenfolge der Städte
  pdistance     ;;Distanz der Rundreise; in der aktuellen Implementierung gilt: The fitness and the pdistance are the same. Pdistance is put in to keep things from getting too confusing
  fitness       ;;Fitnessbewertung einer Lösung, >>>> es könnte auch eine ausgefeiltere Berechnung der Fitness erfolgen, so dass die Fitness nicht mehr nur die Distanz wiedergibt <<<<<
  last-patch-x  ;;wird zur Berechnung der Routendistanz verwendet (letzte betrachtete Koordinate auf der x-Achse)
  last-patch-y  ;;wird zur Berechnung der Routendistanz verwendet (letzte betrachtete Koordinate auf der y-Achse)
  edge-table    ;;wird beim Edge Recombination Crossover eingesetzt
  rouletteWheel ;;Prozentuale Platzierung des Turtles abhängig des Ranges
  ]

;;Um die einzelnen Städte (von 0-20) und ihre Koordinaten (x,y) in der NetLogo-Welt zu hinterlegen:
patches-own [
  name
  p-0-x
  p-0-y
  p-1-x
  p-1-y
  p-2-x
  p-2-y
  p-3-x
  p-3-y
  p-4-x
  p-4-y
  p-5-x
  p-5-y
  p-6-x
  p-6-y
  p-7-x
  p-7-y
  p-8-x
  p-8-y
  p-9-x
  p-9-y
  p-10-x
  p-10-y
  p-11-x
  p-11-y
  p-12-x
  p-12-y
  p-13-x
  p-13-y
  p-14-x
  p-14-y
  p-15-x
  p-15-y
  p-16-x
  p-16-y
  p-17-x
  p-17-y
  p-18-x
  p-18-y
  p-19-x
  p-19-y
  p-20-x
  p-20-y
]

;globale Variablen auf die jederzeit zugegriffen werden kann
globals [
  min-fitness        ;;----kann z.B. zur Speicherung der aktuell kürzesten Distanz oder besten Fitness genommen werden
  global-min-fitness ;;bester bekannter Fitnesswert (hier: kürzeste Rundreise), wird auch im Interface angezeigt
  global-min-string  ;;beste Rundreise (hier: die kürzeste), wird auch im Interface angezeigt
  winner             ;;the turtle with the best fitness
  looser             ;;turtle with worst fitness
  string-drawn;;     ;;welche Rundreise zuvor auf der Map gezeichnet wurde (wird benötigt, um die Zeichnung zu aktualisieren und die alte Rundreise auszuradieren)
  start-time;;       ;;speichert die Uhrzeit und das Datum, wenn Algorithmus gestartet wird, wird auch im Interface angezeigt
  end-time;;         ;;speichert die Uhrzeit und das Datum, wenn Algorithmus terminiert (hier: die ticks haben die vorgegebene Anzahl Generationen erreicht), im Interface zu sehen
]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;MAPS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;wenn Button "Load Map" geklickt wird, wird folgende Prozedur ausgeführt
to tsp2018Map
  ;; (for this model to work with NetLogo's new plotting features,
  ;; __clear-all-and-reset-ticks should be replaced with clear-all at
  ;; the beginning of your setup procedure and reset-ticks at the end
  ;; of the procedure.)
  __clear-all-and-reset-ticks

 ;; die zu lösende Problemstellung wird festgelegt, d.h. die 21 Städte mit den entsprechenden Koordinaten in der NetLogo-Welt;
 ;; der Start- und Endort Berlin entspricht dabei der Stadt 0
 ask patches[
    ;; x und y Koordinaten
    set p-0-x 39 set p-0-y 59
    set p-1-x 42 set p-1-y 50
    set p-2-x 48 set p-2-y 44
    set p-3-x 57 set p-3-y 41
    set p-4-x 63 set p-4-y 56
    set p-5-x 72 set p-5-y 71
    set p-6-x 75 set p-6-y 65
    set p-7-x 84 set p-7-y 62
    set p-8-x 93 set p-8-y 50
    set p-9-x 114 set p-9-y 68
    set p-10-x 183 set p-10-y 71
    set p-11-x 120 set p-11-y 41
    set p-12-x 135 set p-12-y 62
    set p-13-x 120 set p-13-y 29
    set p-14-x 90 set p-14-y 80
    set p-15-x 135 set p-15-y 47
    set p-16-x 150 set p-16-y 59
    set p-17-x 132 set p-17-y 68
    set p-18-x 147 set p-18-y 68
    set p-19-x 63 set p-19-y 65
    set p-20-x 87 set p-20-y 41

   ;;Benennung und Darstellung der einzelnen Städte
   ask patch p-0-x p-0-y [(set pcolor green) (set name "'0'_Berlin") set plabel name            ask neighbors [set pcolor green]]
   ask patch p-1-x p-1-y [(set pcolor blue) (set name "'1'_Prag") set plabel name               ask neighbors4 [set pcolor blue]]
   ask patch p-2-x p-2-y [(set pcolor blue) (set name "'2'_Wien") set plabel name               ask neighbors4 [set pcolor blue]]
   ask patch p-3-x p-3-y [(set pcolor blue) (set name "'3'_Budapest") set plabel name           ask neighbors4 [set pcolor blue]]
   ask patch p-4-x p-4-y [(set pcolor blue) (set name "'4'_Warschau") set plabel name           ask neighbors4 [set pcolor blue]]
   ask patch p-5-x p-5-y [(set pcolor blue) (set name "'5'_Riga") set plabel name               ask neighbors4 [set pcolor blue]]
   ask patch p-6-x p-6-y [(set pcolor blue) (set name "'6'_Vilnius") set plabel name            ask neighbors4 [set pcolor blue]]
   ask patch p-7-x p-7-y [(set pcolor blue) (set name "'7'_Mins") set plabel name               ask neighbors4 [set pcolor blue]]
   ask patch p-8-x p-8-y [(set pcolor blue) (set name "'8'_Kiew") set plabel name               ask neighbors4 [set pcolor blue]]
   ask patch p-9-x p-9-y [(set pcolor red) (set name "'9'_Moskau") set plabel name              ask neighbors4 [set pcolor red]]
   ask patch p-10-x p-10-y [(set pcolor red) (set name "'10'_Jekaterinenburg") set plabel name  ask neighbors4 [set pcolor red]]
   ask patch p-11-x p-11-y [(set pcolor red) (set name "'11'_Rostow") set plabel name           ask neighbors4 [set pcolor red]]
   ask patch p-12-x p-12-y [(set pcolor red) (set name "'12'_Saransk") set plabel name          ask neighbors4 [set pcolor red]]
   ask patch p-13-x p-13-y [(set pcolor red) (set name "'13'_Sotschi") set plabel name          ask neighbors4 [set pcolor red]]
   ask patch p-14-x p-14-y [(set pcolor red) (set name "'14'_StPetersburg") set plabel name     ask neighbors4 [set pcolor red]]
   ask patch p-15-x p-15-y [(set pcolor red) (set name "'15'_Wolgograd") set plabel name        ask neighbors4 [set pcolor red]]
   ask patch p-16-x p-16-y [(set pcolor red) (set name "'16'_Samara") set plabel name           ask neighbors4 [set pcolor red]]
   ask patch p-17-x p-17-y [(set pcolor red) (set name "'17'_Nowgorod") set plabel name         ask neighbors4 [set pcolor red]]
   ask patch p-18-x p-18-y [(set pcolor red) (set name "'18'_Kasan") set plabel name            ask neighbors4 [set pcolor red]]
   ask patch p-19-x p-19-y [(set pcolor red) (set name "'19'_Kaliningrad") set plabel name      ask neighbors4 [set pcolor red]]
   ask patch p-20-x p-20-y [(set pcolor blue) (set name "'20'_Kischinau") set plabel name       ask neighbors4 [set pcolor blue]]
  ]
end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;SETUP PROCEDURE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;wenn Button "setup" geklickt wird, wird folgende Prozedur ausgeführt
to setup
 ;;Erstellen von Initiallösungen und zwar so viele wie über den Parameter "population-size" festgelegt sind
 create-turtles population-size [
   ;; eine Liste mit 600 Einträgen wird erstellt, jeder Eintrag repräsentiert eine besuchte Stadt, die zufällig aus 1-20 gezogen wird
   ;; die hohe Anzahl von Einträgen soll garantieren, dass jede Stadt mindestens einmal zufällig ausgewählt wird
   set string n-values 600 [one-of [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20]]
   ;; um in der Liste jede Stadt nur einmal aufzuführen und eine gültige Rundreise zu bekommen, werden doppelte Einträge entfernt
   set string remove-duplicates string
   ;; es verbleibt nur das erste Vorkommen einer Stadt
   ;;>>>>>>
   ;;um absolut sicher zu gehen, dass auch alle Städte auf der Tour enthalten sind, könnte noch Folgendes eingefügt werden:
   ;;if not (length string = (20)) [ while [ not (length string = (20))] [set string n-values 600 [one-of [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20]]
   ;;set string remove-duplicates string ] ]
   ;;<<<<<<

   ;; um eine vollständig gültige Rundreise zu bekommen wird an den Anfang und an das Ende der Liste jeweils die Stadt 0 hinzugefügt
   ;;>>>> das muss nicht zwangsläufig hier geschehen, sondern wäre (!!je nach Implementierung der Prozedur "calculate-distance"!!) ein paar Zeilen weiter unten besser aufgehoben <<<<<<
   ;;set string fput 0 string;;dies könnte auch erst nach calculate-distance geschehen
   ;;set string lput 0 string;;dies könnte auch erst nach calculate-distance geschehen
 ]

  set string-drawn ""

  ;;für die erstellten Lösungen bzw. Individueen wird ...
  ask turtles [
    calculate-distance  ;;...die zurückzulegende Distanz berechnet
    calculate-fitness   ;;...die entsprechende Fitness des Individuums berechnet (hier: entspricht der Distanz der Rundreise)
    set rouletteWheel 0
    ;;>>>>>>>>
    ;;hier wäre eine Modifizierung der ursprünglichen Implementierung möglich, da die Prozedur "calculate-distance" in der aktuellen Implementierung davon ausgeht,
    ;;dass Start/Endort NICHT in der Liste aufgeführt sind; so dass es sinnvoll wäre, erst hier die Stadt 0 in der Tourliste zu ergänzen (und nicht bereits oben)
    set string fput 0 string
    set string lput 0 string
    ;;<<<<<<<<
   ]
  calculate-winner-looser-fintess
  do-plotting  ;;Aufruf der Plot-Funktion zur Darstellung der Fitness-Werte im Interface (fitness-plot bzw. best-fitness-plot)
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;GO PROCEDURE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;wenn Button "Go" geklickt wird, wird folgende Prozedur ausgeführt
to go

  ;;Vor dem Start des Lösungsverfahrens (d.h. in Iteration 0):
  if ticks = 0
   [set global-min-fitness 1000         ;;als initialer Wert wird die Fitness der besten Lösung (hier: gleich der Distanz) sehr hoch gesetzt
  set start-time date-and-time]         ;;die Startzeit wird festgehalten


  ;;Am Ende des Lösungsverfahrens, d.h. falls die maximale Anzahl Iteration erreicht wurde (hier gleichbedeutend mit erstellten Generationen an Lösungen)
  ;;wird die beste Lösung dargestellt
  ;;und der Fitness-Wert dieser Lösung (hier: gleich der Distanz ihrer Rundreise) zusätzlich zur möglichen weiteren Verwendung in 'min-fitness' gespeichert
  if ticks >= number-of-cycles [draw-shortest-path
                               set min-fitness global-min-fitness
                               STOP]

  ;;in jeder Iteration wird durch die Prozedur "create-new-generation" eine neue Generation von Lösungen erstellt
  ;;dies beinhaltet aktuell eine Paarungsselektion sowie Mutation
  create-new-generation

  ;;es wird geprüft, ob der Lösungswert der besten Lösung aus der neuen Generation die bisher beste bekannte Lösung übertrifft
  ;;ist dies der Fall, wird die beste bekannte Lösung mit der aktuellen Lösung überschrieben
  if ticks > 0
  [if [fitness] of winner < global-min-fitness [set global-min-fitness [fitness] of winner
                                                set global-min-string [string] of winner]]

  ;;um zwischendurch die beste gefundene Lösung zu zeichnen:
  if ticks mod show-best-solution-at-each-x-iteration = 1 [draw-shortest-path-during-runtime] ;;mindestens eine Iteration muss komplett durchlaufen werden

  ;;erhöhe den Iterationszähler um 1 und zeichne die Fitness-Plots
  tick
  do-plotting

  ;; Am Ende des Lösungsverfahrens wird zusätzlich auch Uhrzeit und Datum festgehalten, um die Gesamtdauer, die zum Lösen benötigt wurde, berechnen zu können
  if ticks = number-of-cycles
  [set end-time date-and-time]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;DISTANCE PROCEDURE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;berechnet für jede einzelne Lösung, d.h. jeden Turtle, die zurückzulegende Distanz auf der Rundreise
;;!! ZU BEACHTEN: die betrachtete Tourliste in string sollte dafür jeweils NICHT die Stadt 0 beinhalten,
;;    andernfalls ist die Implementierung der while-Schleife und Indexvariable "item#" anzupassen        !!
to calculate-distance
    set pdistance 0
    set last-patch-x 0
    set last-patch-y 0

    ;;The following commands may seem like a lot, but really they repeat over and over. Shown here is how the algorithm interprets the list of numbers

    setxy 0 0 set pdistance 0 set last-patch-x p-0-x set last-patch-y p-0-y  ;; es wird immer bei Stadt 0 angefangen

      ;;Erstelle eine Indexvariable, die angibt welche Stelle der Tourliste betrachtet wird
      ;;Listen sind nullbasiert, d.h. das erste Element befindet sich an Position 0 und das letzte an Position Listenlänge-1
      let item# 0

      while [item# < 20] [ ;; für eine Liste mit 20 Städten (ohne die Startstadt/Endstadt der Rundreise) darf item# nur bis 19 gehen

    ;;Gehe die Tourliste durch und prüfe für jedes Element in der Tourliste, ob es Stadt 1-20 repräsentiert
    ;;abhängig davon wird die Distanz zur letzten besuchten x-y Koordinate berechnet
    ;;Distancexy-nowrap bedeutet, dass bei der Berechnung nur die aus der NetLogo-Welt (d.h. der Karte) sichtbaren Distanzen genommen werden
    ;;d.h. die Karte ist kein Globus, den man auf einer Seite verlassen und auf der anderen wieder hereinkommen kann

    if item item# string = 1 [setxy p-1-x p-1-y set pdistance (pdistance) + distancexy-nowrap last-patch-x last-patch-y set last-patch-x p-1-x set last-patch-y p-1-y] ;;Distancexy-nowrap is used so the
    if item item# string = 2 [setxy p-2-x p-2-y set pdistance (pdistance) + distancexy-nowrap last-patch-x last-patch-y set last-patch-x p-2-x set last-patch-y p-2-y] ;;cannot take distances wrapped around
    if item item# string = 3 [setxy p-3-x p-3-y set pdistance (pdistance) + distancexy-nowrap last-patch-x last-patch-y set last-patch-x p-3-x set last-patch-y p-3-y] ;;the world
    if item item# string = 4 [setxy p-4-x p-4-y set pdistance (pdistance) + distancexy-nowrap last-patch-x last-patch-y set last-patch-x p-4-x set last-patch-y p-4-y]
    if item item# string = 5 [setxy p-5-x p-5-y set pdistance (pdistance) + distancexy-nowrap last-patch-x last-patch-y set last-patch-x p-5-x set last-patch-y p-5-y]
    if item item# string = 6 [setxy p-6-x p-6-y set pdistance (pdistance) + distancexy-nowrap last-patch-x last-patch-y set last-patch-x p-6-x set last-patch-y p-6-y]
    if item item# string = 7 [setxy p-7-x p-7-y set pdistance (pdistance) + distancexy-nowrap last-patch-x last-patch-y set last-patch-x p-7-x set last-patch-y p-7-y]
    if item item# string = 8 [setxy p-8-x p-8-y set pdistance (pdistance) + distancexy-nowrap last-patch-x last-patch-y set last-patch-x p-8-x set last-patch-y p-8-y]
    if item item# string = 9 [setxy p-9-x p-9-y set pdistance (pdistance) + distancexy-nowrap last-patch-x last-patch-y set last-patch-x p-9-x set last-patch-y p-9-y]
    if item item# string = 10 [setxy p-10-x p-10-y set pdistance (pdistance) + distancexy-nowrap last-patch-x last-patch-y set last-patch-x p-10-x set last-patch-y p-10-y]
    if item item# string = 11 [setxy p-11-x p-11-y set pdistance (pdistance) + distancexy-nowrap last-patch-x last-patch-y set last-patch-x p-11-x set last-patch-y p-11-y]
    if item item# string = 12 [setxy p-12-x p-12-y set pdistance (pdistance) + distancexy-nowrap last-patch-x last-patch-y set last-patch-x p-12-x set last-patch-y p-12-y]
    if item item# string = 13 [setxy p-13-x p-13-y set pdistance (pdistance) + distancexy-nowrap last-patch-x last-patch-y set last-patch-x p-13-x set last-patch-y p-13-y]
    if item item# string = 14 [setxy p-14-x p-14-y set pdistance (pdistance) + distancexy-nowrap last-patch-x last-patch-y set last-patch-x p-14-x set last-patch-y p-14-y]
    if item item# string = 15 [setxy p-15-x p-15-y set pdistance (pdistance) + distancexy-nowrap last-patch-x last-patch-y set last-patch-x p-15-x set last-patch-y p-15-y]
    if item item# string = 16 [setxy p-16-x p-16-y set pdistance (pdistance) + distancexy-nowrap last-patch-x last-patch-y set last-patch-x p-16-x set last-patch-y p-16-y]
    if item item# string = 17 [setxy p-17-x p-17-y set pdistance (pdistance) + distancexy-nowrap last-patch-x last-patch-y set last-patch-x p-17-x set last-patch-y p-17-y]
    if item item# string = 18 [setxy p-18-x p-18-y set pdistance (pdistance) + distancexy-nowrap last-patch-x last-patch-y set last-patch-x p-18-x set last-patch-y p-18-y]
    if item item# string = 19 [setxy p-19-x p-19-y set pdistance (pdistance) + distancexy-nowrap last-patch-x last-patch-y set last-patch-x p-19-x set last-patch-y p-19-y]
    if item item# string = 20 [setxy p-20-x p-20-y set pdistance (pdistance) + distancexy-nowrap last-patch-x last-patch-y set last-patch-x p-20-x set last-patch-y p-20-y]
    ;;last-patch-y equals the last 'y' cordnate that the turtle was at
    ;;last-patch-x equals the last 'x' cordnate that the turtle was at

    set item# item# + 1

      ]

    setxy p-0-x p-0-y set pdistance (pdistance) + (distancexy-nowrap last-patch-x last-patch-y) ;;sets the turtle back at the starting location


end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;FITNESS PROCEDURE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;berechnet für jede einzelne Lösung (Turtle) die Fitness (hier: gleich der Routenlänge)
;;>>>>>>>>>
;;wenn gelten sollte, desto größer der Fitnesswert, desto besser das Individuum, müsste eigentlich mit 1/Routenlänge gearbeitet werden
;;darauf basierend könnte dann später leichter z.B. eine Fitnessproportionale Selektion durchgeführt werden
;;zu beachten ist allerdings auch, dass dann z.B. "winner" als "max-one-of" auszuwählen ist
;;<<<<<<<<<
to calculate-fitness
  set fitness pdistance
end

to calculate-winner-looser-fintess
  set winner min-one-of turtles [fitness] ;;in this case the winner is the turtle traveling the least distance
  set looser max-one-of turtles [fitness] ;;  hier wird auch das schlechteste Individuum gespeichert (im weiteren Verlauf bisher aber nicht wirklich verwendet)
end

;;>>>>>>>>
;;hier erfolgt das Setzen von "winner" und "looser" mit jeder Fitnessberechnung eines Turtles
;;aus Performanzgründen (für größere Problemstellungen) könnte das Setzen von "winner" und "looser" auch in einer eigenständigen Prozedur durchgeführt werden
;;diese müsste dann immer nachträglich aufgerufen werden, nachdem für alle Turtles die Fitness berechnet wurde
;;<<<<<<<<

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;NEW GENERATION PROCEDURE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;hier findet die Erstellung der neuen Generation an Individuen statt
;; in der vorliegenden Implementierung beinhaltet dies Paarungsselektion und den anschließenden Aufruf einer Prozedur zur Mutation der Individueen
;; >>>>>> eine Umweltselektion ist hier bisher nicht implementiert <<<<<<<
to create-new-generation

 ;;da Start-und Endort der Rundreise durch die Stadt 0 fest vorgegeben sind, werden diese vor den Crossover-Operationen aus den einzelnen Lösungen entfernt
 ;;(und später wieder hinzugefügt)

  ask turtles [set string remove-item 21 string  ;;
               set string remove-item 0 string]

  ;;Da der Edge Rekombination Crossover eingesetzt wird, bei dem aus zwei Elternteilen jeweils ein Kind erzeugt wird,
  ;;wird im Folgenden im Rahmen der vorhandenen Implementierung einfach für jede aktuelle Lösung eine neue erstellt oder die alte Lösung beibehalten
  ;;>>>>>>>>
  ;;Hier wären Änderungen nötig, wenn z.B. Umweltselektion bzw. Elitismus hinzugefügt wird:
  ;;ein mögliches Vorgehen zur Erstellung einer neuen Generation, das nicht allein darauf basiert die vorhandenen Lösungen durchzugehen
  ;;und gegebenenfalls zu überschreiben, wird in der Implementierung des Beispiel-Models "Simple Genetic Algorithm" aus der NetLogo-Library deutlich
  ;;(siehe unter File -> Models Library -> Computer Science -> Simple Genetic Algorithm)
  ;;<<<<<<<<<

  if selection? = "roulette" [
    let sumFitness sum [fitness] of turtles
    let previous 0

    foreach sort-on [(fitness)] turtles
    [ the-turtle -> ask the-turtle [set rouletteWheel previous + 1 - (fitness / sumFitness)
                                    set previous rouletteWheel] ]

    let maxRouletteWheel max [rouletteWheel] of turtles
    foreach sort-on [(fitness)] turtles
    [ the-turtle -> ask the-turtle [set rouletteWheel maxRouletteWheel - rouletteWheel] ]
  ]

  ask turtles [
  ifelse elitism? and self = winner
    [
      ;; do nothing as we do not want to replace the best solution
    ]
    [
  if random-float 100.0 < crossover-rate [
  ;; falls eine zufällig gezogene Zahl bis 100 unterhalb der voreingestellten Crossover-Rate liegt, dann soll die bestehende Lösung durch eine neue ersetzt werden

  ; if we simply wrote "LET OLD-GENERATION TURTLES",
  ; then OLD-GENERATION would mean the set of all turtles, and when
  ; new solutions were created, they would be added to the breed, and
  ; OLD-GENERATION would also grow.  Since we don't want it to grow,
  ; we instead write "TURTLES WITH [TRUE]", which makes OLD-GENERATION
  ; an agentset, which doesn't get updated when new solutions are created.
  let old-generation turtles with [true]

  ;;Turnierbasierte Selektion zur Auswahl der beiden Elternpaare:
  ;; für die beiden  Elternteile weren jeweils so viele Lösungen zufällig ausgewählt, wie durch die "tournament-size" vorgegeben wird
  ;; diese Lösungen werden dann anhand der Fitness bewertet und jeweils diejenige mit der besten Fitness (hier: geringste Tourlänge) ausgewählt
  ;;>>>>>> sollte die Fitnessbewertung angepasst worden sein, ist hier zu prüfen, ob statt "min-one-of" besser "max-one-of" zu wählen ist <<<<<<
  ;;let parent1-p max-one-of (n-of tournament-size old-generation) [fitness]
  ;;let parent2-p max-one-of (n-of tournament-size old-generation) [fitness]
  ;;>>>>>> wenn die Selektionsmethode geändert wird, wäre statt der obigen Zeilen eine Anpassung bzw. Neuimplementierung erforderlich <<<<<<


  let parent1-p 0
  let parent2-p 0

  ;; NOTE: Bei turnierbasierter Selektion ist es möglich parent1 und parent2 mit dem gleichen Elternteil zu besetzten. Ist das sinnvoll?
  if selection? = "match" [
        ;;Turnierbasierte Selektion zur Auswahl der beiden Elternpaare:
        ;; für die beiden  Elternteile weren jeweils so viele Lösungen zufällig ausgewählt, wie durch die "tournament-size" vorgegeben wird
        set parent1-p min-one-of (n-of tournament-size old-generation) [fitness]
        set parent2-p min-one-of (n-of tournament-size old-generation) [fitness]
      ]

  if selection? = "roulette" [
        ;;Fitnessproportionale Selection zur Auswahl der beiden Elternpaare:
        ;;Hier Verwendung der Roulette-Wheel-Selection
        set parent1-p rnd:weighted-one-of turtles [ rouletteWheel ]
        set parent2-p rnd:weighted-one-of turtles [ rouletteWheel ]
   ]

  if recombination? = "edgeRecombination" [
        ;;>>>>>>Beginn des Edge Recombination Crossover
        ;;>>>>>>wenn Crossover-Operator geändert wird, wäre hier eine Anpassung nötig
        let parent1 [string] of parent1-p
        let parent2 [string] of parent2-p

        let x 0
        let edgetable1 []

        while [x < length parent1][
          let sl []

          ; first item
          if x = 0 [
            set sl lput item  x parent1 sl
            set sl lput item (x + 1) parent1 sl

            let l length parent1 - 1

            set sl lput (item l parent1) sl
            set edgetable1 lput sl edgetable1
          ]

          ; last item
          if x = length parent1 - 1 [
            set sl lput item  x parent1 sl
            set sl lput item (0) parent1 sl

            let l length parent1 - 2

            set sl lput (item l parent1) sl
            set edgetable1 lput sl edgetable1
          ]

          ; all other items
          if x > 0 and x < length parent1 - 1 [
            set sl lput item  x parent1 sl
            set sl lput item (x - 1) parent1 sl
            set sl lput item (x + 1) parent1 sl

            set edgetable1 lput sl edgetable1
          ]
          set x x + 1
        ]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        let edgetable2 []
        set x 0

        while [x < length parent2][
          let sl []

          ; first item
          if x = 0 [
            set sl lput item  x parent2 sl
            set sl lput item (x + 1) parent2 sl

            let l length parent2 - 1

            set sl lput (item l parent2) sl
            set edgetable2 lput sl edgetable2
          ]

          ; last item
          if x = length parent2 - 1 [
            set sl lput item  x parent2 sl
            set sl lput item (0) parent2 sl

            let l length parent2 - 2

            set sl lput (item l parent2) sl
            set edgetable2 lput sl edgetable2
          ]

          ; all other items
          if x > 0 and x < length parent2 - 1 [
            set sl lput item  x parent2 sl
            set sl lput item (x - 1) parent2 sl
            set sl lput item (x + 1) parent2 sl

            set edgetable2 lput sl edgetable2
          ]
          set x x + 1
        ]

  ;;;;
  ;;;;
  ;;;;put in order

        let y 1
        let edgetable3 []

        while [y <= length parent1] [
          set x 0

          while [x < length parent1] [

            if item 0 item x edgetable1 = y [set edgetable3 lput item x edgetable1 edgetable3]
            set x x + 1
        ]

          set y y + 1
        ]
 ;;;;;;;;;;;;
 ;;;;;;;;;;;;

        let edgetable4 []
        set y 1

        while [y <= length parent1] [
          set x 0

          while [x < length parent1] [

            if item 0 item x edgetable2 = y [set edgetable4 lput item x edgetable2 edgetable4]

            set x x + 1
          ]

          set y y + 1
        ]

        let masteredge1 []
        set x 0

        while [x < length parent1] [

          let sm []

          set sm lput item 1 item x edgetable3 sm
          set sm lput item 2 item x edgetable3 sm

          set masteredge1 lput sm masteredge1

          set x x + 1
        ]

        let masteredge2 []
        set x 0

        while [x < length parent1] [

          let sm []

          set sm lput item 1 item x edgetable4 sm
          set sm lput item 2 item x edgetable4 sm

          set masteredge2 lput sm masteredge2

          set x x + 1
        ]

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        set x 0
        set y 0
        let masteredge []

        while [x < length parent1] [

          let sm []
          set sm lput item 0 item x masteredge1 sm
          set sm lput item 1 item x masteredge1 sm

          set sm lput item 0 item x masteredge2 sm
          set sm lput item 1 item x masteredge2 sm

          set masteredge lput sm masteredge

          set x x + 1
        ]

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;

        set x (random 20) + 1

        let child1 []

        while [length child1 < length parent1] [

          let mastertemp []

          set y 0
          let z 1

          while [y < 20] [    ;;

            let sm []
            let r []
            set sm sublist masteredge y z
            set r item 0 sm

            set r remove x r

            set mastertemp lput r mastertemp

            set y y + 1
            set z z + 1
          ]

          set masteredge mastertemp
          set mastertemp lput [] mastertemp

          set child1 lput x child1

          set edge-table child1

          let l shortest x mastertemp

          set x l

          if length child1 = 19 [set child1 lput x child1]   ;;
        ]

        set string child1

 ;;<<<<<<wenn Crossover-Operator geändert wird, wäre hier eine Anpassung nötig
 ;;<<<<<<Ende des Edge Recombination Crossover
      ]


  if recombination? = "mappedCrossover" [
        let parent1 [string] of parent1-p
        let parent2 [string] of parent2-p

        let random1 random ((length parent1) / 2)
        if random1 < 2 [set random1 random1 + 1]
        let random2 random ((length parent1) / 2)
        if random2 < 2 [set random2 random2 + 1]
        let tmp parent1
        let middleParent1 []
        let middleParent2 []

        ;; Hier wird der mittlere Teil ausgetauscht
        let i random1
        while [i < ((length parent1) - random2)] [
          set parent1 (replace-item i parent1 (item i parent2))
          set middleParent1 lput (item i parent2) middleParent1
          set parent2 (replace-item i parent2 (item i tmp))
          set middleParent2 lput (item i tmp) middleParent2
          set i i + 1
        ]

        ;; Überprüfen, ob in dem ersten Teil eine Zahl doppelt vorkommt
        set i 0
        while [ i < random1 ] [
          while [ member? (item i parent1) middleParent1] [
            let pos position item i parent1 middleParent1
            set parent1 (replace-item i parent1 (item pos middleParent2))
          ]
          while [ member? (item i parent2) middleParent2] [
            let pos position item i parent2 middleParent2
            set parent2 (replace-item i parent2 (item pos middleParent1))
          ]
          set i i + 1
          ]

        ;; Überprüfen, ob in dem zweiten Teil eine Zahl doppelt vorkommt
        set i ((length parent1) - random2)
        while [i < length parent1] [
        while [ member? (item i parent1) middleParent1] [
            let pos position item i parent1 middleParent1
            set parent1 (replace-item i parent1 (item pos middleParent2))
          ]
        while [ member? (item i parent2) middleParent2] [
            let pos position item i parent2 middleParent2
            set parent2 (replace-item i parent2 (item pos middleParent1))
          ]
        set i i + 1
        ]
      ]

 ;;Bewertung der Distanz bzw. Fitness der neu erstellten Lösung
 calculate-distance
 calculate-fitness

    ]]]
  calculate-winner-looser-fintess

  ;;Aufruf der Prozedur zur Mutation der Individuen
  ;;wird vorgezogen, um den Start- und Endpunkt nicht doppelt hinzufügen bzw. enfernen zu müssen
  mutate


  ;; Start- und Endort werden wieder den einzelnen Lösungen hinzugefügt
  ask turtles [set string fput 0 string
               set string lput 0 string]



end


;;Prozedur für den Edge Recombination Crossover zur Listenverwaltung
to-report shortest [n wholelist]

  let short 999
  let numbershort -1

  let x 0
  let y 0

  let sm sublist wholelist (n - 1) n


  while [length sm > x] [

    let f item x item 0 sm
    let sl sublist wholelist f (f + 1)
    let z length sl

    if z < short [if z > 0 [set short z
                            set numbershort f]]

    ifelse preserve-common-links?

    [let r 0
     let c 0

      while [r < length sm] [
        while [c < length sm] [

          ifelse r = c []

          [if item r item 0 sm = item c item 0 sm [set numbershort item r item 0 sm
                                     set sm remove-item c item 0 sm
                                     set r 4
                                     set c 4
                                     set x 5]]

        set c c + 1
        ]
       set c 0
       set r r + 1
      ]]
    []

    set x x + 1

    ]

  report numbershort

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; diese Prozedur überprüft, ob nach erfolgter Mutation noch alle Städte der Rundreise genau einmal vorhanden sind,
;; ist dies nicht der Fall müssen die fehlenden Städte bzw. die fehlende Stadt ergänzt, sowie mögliche Duplikate entfernt werden
to fix-list
 ask turtles [
 set string remove-duplicates string]
  ask turtles [

  let x 1

  while [x < 21] [

  if position x string = false [set string lput x string]
  set x x + 1

  ]
  ]
end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;MUTATION PROCEDURE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;hier findet eine mögliche Mutation mit einer vorgegebenen Wahrscheinlichkeit (mutation-rate) bei allen Individuen/Lösungen statt

to mutate
  let random-item random 19
  let random-item2 random 19

  let random-number int (random-float 19) + 1
  let random-number2 int (random-float 19) + 1

  ask turtles [
    ifelse elitism? and self = winner
    [
      ;do nothing, as we do not want to mutate the winner
    ]
    [
      ifelse swap-mutation?

      ;;falls true, d.h. Schalter im Interface ist "On": two point swap mutation
      ;;zwei Orte werden innerhalb der Tour miteinander getauscht
      [if random-float 100.0 < mutation-rate [let tmp item random-item string
                                              set string replace-item random-item string (item random-item2 string)
                                              set string replace-item random-item2 string tmp]]

      ;;falls false, d.h Schalter im Interface ist "Off": two point random mutation
      ;;zwei Orte werden einfach durch Zufallszahlen überschrieben,
      ;; da die entstehende Tour vermutlich nicht mehr zulässig ist, muss nachträglich "fix-list" aufgerufen werden
      [if random-float 100.0 < mutation-rate [set string replace-item random-item string random-number
                                              set string replace-item random-item2 string random-number2]]
    ]
  ]

  ;;Reparatur der durch Mutation veränderten Routen, aufgrund der Implementierung ist dies auch für die two point swap mutation nötig
  fix-list

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;PLOTTING PROCEDURE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;Prozedur zur Ausgabe der Fitness-Plots (wird bei jedem tick, also in jeder Iteration aufgerufen)
to do-plotting
 let fitness-dump [fitness] of turtles
 let av mean fitness-dump
 let best min fitness-dump      ;;>>>>bei Anpassung der Fitnessberechnung müsste hier min/max geprüft werden<<<<
 let worst max fitness-dump     ;;>>>>bei Anpassung der Fitnessberechnung müsste hier min/max geprüft werden<<<<

  ;;Ausgabe im Fitness-Plot
  set-current-plot "fitness-plot"
  set-current-plot-pen "av"
    plot av
  set-current-plot-pen "best"
    plot best
  set-current-plot-pen "worst"
    plot worst

  ;;Ausgabe im Best-Fitness-Plot
  set-current-plot "best-fitness-plot"
      set-current-plot-pen "best"
        plot global-min-fitness

  if (global-min-fitness != best and ticks > 1) and elitism? [
    print "Elitismus gone wrong"
  ]
    ;;>>>>>
    ;; zur Kontrolle: sollte mit Elitismus gearbeitet werden, d.h. die beste Lösung wird immer (ohne Mutation) in die nachfolgende Generation übernommen
    ;; müsste der Plot der besten Lösung aus der aktuellen Generation im "fitness-plot" identisch zum Plot der insgesamt besten Lösung im "best-fitness-plot" sein
    ;;<<<<<

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;DIVERSITY PROCEDURES;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;diese Prozedur versucht die Diversität der vorhandenen Lösungen zu beurteilen, also wie unterschiedlich die einzelnen Lösungen einer Population sind
;;(ein Aufruf wäre z.B. innerhalb der GO-Procedure durch print diversity möglich, um die jeweilige Bewertung ausgegeben zu bekommen)
;;die Prozedur wird im weiteren Verlauf aber nicht verwendet
  to-report diversity

  let y 0
  let dump 0

  while [y < population-size] [

    let rand1[string] of (one-of turtles)
    let rand2[string] of (one-of turtles)

    let x 1
    let mian-dump 0

    while [x < 21] [

      let sm abs (item x rand1 - item x rand2)
      set mian-dump mian-dump + sm

      set x x + 1

      ]

    set dump dump + mian-dump

    set y y + 1
  ]

    report (dump / population-size)

end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;DRAW_SHORTEST_PATH PROCEDURE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;Zur Ausgabe der besten Lösung am Ende des Verfahrens
to draw-shortest-path
  if not empty? string-drawn [
      create-turtles 1 [
    set color blue
    setxy p-0-x p-0-y
    set string string-drawn
    pen-erase
     set pen-size 5.5
     set shape "salesman"
     set size 7


     let x 0

  while [x < 21] [

    if item x string = 1 [setxy p-1-x p-1-y ]
    if item x string = 2 [setxy p-2-x p-2-y ]
    if item x string = 3 [setxy p-3-x p-3-y  ]
    if item x string = 4 [setxy p-4-x p-4-y ]
    if item x string = 5 [setxy p-5-x p-5-y ]
    if item x string = 6 [setxy p-6-x p-6-y ]
    if item x string = 7 [setxy p-7-x p-7-y ]
    if item x string = 8 [setxy p-8-x p-8-y ]
    if item x string = 9 [setxy p-9-x p-9-y  ]
    if item x string = 10 [setxy p-10-x p-10-y]
    if item x string = 11 [setxy p-11-x p-11-y ]
    if item x string = 12 [setxy p-12-x p-12-y ]
    if item x string = 13 [setxy p-13-x p-13-y ]
    if item x string = 14 [setxy p-14-x p-14-y  ]
    if item x string = 15 [setxy p-15-x p-15-y]
    if item x string = 16 [setxy p-16-x p-16-y]
    if item x string = 17 [setxy p-17-x p-17-y]
    if item x string = 18 [setxy p-18-x p-18-y]
    if item x string = 19 [setxy p-19-x p-19-y]
    if item x string = 20 [setxy p-20-x p-20-y]

    set x x + 1
  ]

    setxy p-0-x p-0-y

      die
  ]
  ]

  let old-generation turtles with [true]


  create-turtles 1 [
    set color blue
    setxy p-0-x p-0-y
    set string global-min-string
    pen-down
     set pen-size 2.5
     set shape "salesman"
     set size 7 ]

  ask old-generation [die]

   ask turtles [
     let x 0

  while [x < 21] [

    if item x string = 1 [setxy p-1-x p-1-y ]
    if item x string = 2 [setxy p-2-x p-2-y ]
    if item x string = 3 [setxy p-3-x p-3-y  ]
    if item x string = 4 [setxy p-4-x p-4-y ]
    if item x string = 5 [setxy p-5-x p-5-y ]
    if item x string = 6 [setxy p-6-x p-6-y ]
    if item x string = 7 [setxy p-7-x p-7-y ]
    if item x string = 8 [setxy p-8-x p-8-y ]
    if item x string = 9 [setxy p-9-x p-9-y  ]
    if item x string = 10 [setxy p-10-x p-10-y]
    if item x string = 11 [setxy p-11-x p-11-y ]
    if item x string = 12 [setxy p-12-x p-12-y ]
    if item x string = 13 [setxy p-13-x p-13-y ]
    if item x string = 14 [setxy p-14-x p-14-y  ]
    if item x string = 15 [setxy p-15-x p-15-y]
    if item x string = 16 [setxy p-16-x p-16-y]
    if item x string = 17 [setxy p-17-x p-17-y]
    if item x string = 18 [setxy p-18-x p-18-y]
    if item x string = 19 [setxy p-19-x p-19-y]
    if item x string = 20 [setxy p-20-x p-20-y]

    set x x + 1
  ]

    setxy p-0-x p-0-y
    pen-up

  ]
end

;;Zur Ausgabe der besten bisherigen Lösung während des Verfahrens
to draw-shortest-path-during-runtime

  if not empty? string-drawn [
      create-turtles 1 [
    set color blue
    setxy p-0-x p-0-y
    set string string-drawn
    pen-erase
     set pen-size 5.5
     set shape "salesman"
     set size 7


     let x 0

  while [x < 21] [

    if item x string = 1 [setxy p-1-x p-1-y ]
    if item x string = 2 [setxy p-2-x p-2-y ]
    if item x string = 3 [setxy p-3-x p-3-y  ]
    if item x string = 4 [setxy p-4-x p-4-y ]
    if item x string = 5 [setxy p-5-x p-5-y ]
    if item x string = 6 [setxy p-6-x p-6-y ]
    if item x string = 7 [setxy p-7-x p-7-y ]
    if item x string = 8 [setxy p-8-x p-8-y ]
    if item x string = 9 [setxy p-9-x p-9-y  ]
    if item x string = 10 [setxy p-10-x p-10-y]
    if item x string = 11 [setxy p-11-x p-11-y ]
    if item x string = 12 [setxy p-12-x p-12-y ]
    if item x string = 13 [setxy p-13-x p-13-y ]
    if item x string = 14 [setxy p-14-x p-14-y  ]
    if item x string = 15 [setxy p-15-x p-15-y]
    if item x string = 16 [setxy p-16-x p-16-y]
    if item x string = 17 [setxy p-17-x p-17-y]
    if item x string = 18 [setxy p-18-x p-18-y]
    if item x string = 19 [setxy p-19-x p-19-y]
    if item x string = 20 [setxy p-20-x p-20-y]

    set x x + 1
  ]

    setxy p-0-x p-0-y

      die
  ]
  ]

  create-turtles 1 [
    set color blue
    setxy p-0-x p-0-y
    set string global-min-string
    pen-down
     set pen-size 2.5
     set shape "salesman"
     set size 7

    set string-drawn global-min-string
  ;]



     let x 0

  while [x < 21] [

    if item x string = 1 [setxy p-1-x p-1-y ]
    if item x string = 2 [setxy p-2-x p-2-y ]
    if item x string = 3 [setxy p-3-x p-3-y  ]
    if item x string = 4 [setxy p-4-x p-4-y ]
    if item x string = 5 [setxy p-5-x p-5-y ]
    if item x string = 6 [setxy p-6-x p-6-y ]
    if item x string = 7 [setxy p-7-x p-7-y ]
    if item x string = 8 [setxy p-8-x p-8-y ]
    if item x string = 9 [setxy p-9-x p-9-y  ]
    if item x string = 10 [setxy p-10-x p-10-y]
    if item x string = 11 [setxy p-11-x p-11-y ]
    if item x string = 12 [setxy p-12-x p-12-y ]
    if item x string = 13 [setxy p-13-x p-13-y ]
    if item x string = 14 [setxy p-14-x p-14-y  ]
    if item x string = 15 [setxy p-15-x p-15-y]
    if item x string = 16 [setxy p-16-x p-16-y]
    if item x string = 17 [setxy p-17-x p-17-y]
    if item x string = 18 [setxy p-18-x p-18-y]
    if item x string = 19 [setxy p-19-x p-19-y]
    if item x string = 20 [setxy p-20-x p-20-y]

    set x x + 1
  ]

    setxy p-0-x p-0-y
    pen-up

    die
  ]
end





;                                                               Originally Designed and created by Wes Hileman
;
;                                                                          Colorado Springs, CO
;
;                                                              Questions?, Comments? EMAIL: wesley133@msn.com



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; Last Updated: Jun 18, 2011  bzw. 8.5.2018 für Kurs Metaheuristiken und Simulation
@#$#@#$#@
GRAPHICS-WINDOW
514
63
1240
451
-1
-1
3.76
1
10
1
1
1
0
0
0
1
0
190
0
100
1
1
1
ticks
30.0

BUTTON
711
10
777
43
setup
setup
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
776
10
842
43
NIL
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

SLIDER
9
10
205
43
population-size
population-size
3
1000
146.0
1
1
NIL
HORIZONTAL

SLIDER
9
74
205
107
mutation-rate
mutation-rate
0
30
22.5
.1
1
NIL
HORIZONTAL

PLOT
16
259
492
514
fitness-plot
time
fitness
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"." 1.0 0 -16777216 true "" ""
"av" 1.0 0 -13345367 true "" ""
"best" 1.0 0 -10899396 true "" ""
"worst" 1.0 0 -5825686 true "" ""

BUTTON
841
10
907
43
step
go
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
512
10
708
43
Load Map
tsp2018Map
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
9
42
205
75
tournament-size
tournament-size
2
10
2.0
1
1
NIL
HORIZONTAL

MONITOR
16
214
158
259
Best Global Fitness
global-min-fitness
15
1
11

MONITOR
159
214
492
259
Best Global Solution
global-min-string
17
1
11

SLIDER
204
10
403
43
crossover-rate
crossover-rate
0
100
65.0
1
1
NIL
HORIZONTAL

SWITCH
204
74
403
107
swap-mutation?
swap-mutation?
0
1
-1000

SWITCH
204
42
403
75
preserve-common-links?
preserve-common-links?
0
1
-1000

PLOT
15
524
471
840
best-fitness-plot
time
fitness
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"." 1.0 0 -16777216 true "" ""
"best" 1.0 0 -10899396 true "" ""

SLIDER
963
18
1227
51
show-best-solution-at-each-x-iteration
show-best-solution-at-each-x-iteration
10
100
50.0
10
1
NIL
HORIZONTAL

MONITOR
1070
458
1239
503
NIL
start-time
17
1
11

MONITOR
1070
505
1240
550
NIL
end-time
17
1
11

CHOOSER
10
139
205
184
selection?
selection?
"match" "roulette"
0

SWITCH
205
106
403
139
elitism?
elitism?
1
1
-1000

CHOOSER
205
138
403
183
recombination?
recombination?
"mappedCrossover" "edgeRecombination"
1

SLIDER
9
107
205
140
number-of-cycles
number-of-cycles
1
1000
797.0
2
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

Put shortly, this is a model of the traveling salesman problem using a genetic algorithm. Below is an in deph description of both components. 

##
                          THE TRAVELING SALESMAN PROBLEM


	The Traveling Salesman Problem (TSP) is a famous optimization problem, studied extensively in mathematics and computer science (Yuping). A salesman must visit a network of cities once and return to the starting city. The problem is to find the shortest tour among these cities to minimize the total travel distance and cost of the tour (Kashyap). 

	One way of solving the TSP is to list all of the possible solutions and evaluate them one-by-one. This works well for smaller amounts of cities, but will become more time consuming as more cities are added, for the number of solutions to the TSP is represented by the formula: (N-1!). For this reason, emphasis has shifted from finding the best solution to finding good solutions in reasonable amounts of time. The genetic algorithm is one of the best algorithms for finding good solutions quickly (Ahmed).   
The TSP has attracted the attention of many people and will remain as an active research area. The main reason for this is large numbers of real-world problems can be modeled by the TSP, for example the automated drilling of printed circuit boards is one of them. By finding an efficient way to solve the TSP, other similar problems can be solved as well (Ahmed).

##
                              THE GENETIC ALGORITHM


	Essentially, genetic algorithms are solution-searching techniques based on the survival of the fittest, crossover, and mutation processes of evolutionary biology. They have been used for solving a number of different complicated problems, including the TSP. The original theory, based on genetic structure and the behavior of chromosomes in nature, was developed by John Holland and his students in the early 1970s. A population of chromosomes, represented by encoded solutions, is changed by applying three main genetic operators to the algorithm in each generation: selection, crossover, and mutation. The fitness of the chromosomes (how well individual solutions satisfy set criteria) is measured via the fitness function. The algorithm proceeds to cycle through this process until an adequate solution is found. Each time chromosomes cycle through the algorithm, a new generation is created [2].

	Similar to the way organisms adapt and improve, solutions produced through the algorithm should improve with every successive generation. Through this process, genetic algorithms are able to produce accurate solutions to complicated problems in reasonable amounts of time (Ahmed).

The main parts of the genetic algorithm include:  
-Initial population and encoding  
-The fitness function  
-Selection  
-Crossover  
-Mutation

Each are explaned below

## HOW IT WORKS: STEPS BELOW:

##
                          INITIAL POPULATION


	The initial population of chromosomes, necessary to start the algorithm, is randomly generated; each chromosome will represent a solution �a tour. To encode the tours, an appropriate encoding method needs to be selected [5]. Path representation is used to encode the tours; characters will represent cities. The number of characters in the path is equal to the number of cities in the tour and specific characters cannot repeat; for the salesman cannot visit one city more than once (Ahmed). The length of the tour, or the distance traveled by the salesman, is equivalent to the fitness of the tour and depends on the ordering of cities [2]. For example, the following figure represents a path the salesman could take on the tour:

## FITNESS FUNCTION

The fitness function determines how �good� a chromosome is. In the case of the TSP, the fitness of a particular tour is equal to the distance traveled if the tour was taken. The shortest tours have the best fitness, making the TSP a minimization problem (Bryant). The model may be extended to include factors like air travel cost and the sales potential of each city. Each factor is weighted a certain amount contributes to the total fitness of the solution: similar to weighted grades. To do this the problem needs to be converted into a maximization problem.

Genetic algorithms are usually used in maximization problems. The algorithm will still function properly as a minimization problem, but for scientific accuracy it needs to be converted into a maximization problem. As described above, if other factors needed to be added in, it is easier to convert the distance traveled to a maximization problem rather than covering all of the other factors to minimization problems. The following equation will convert the problem:

1/ Total Distance Traveled

The total distance traveled can be calculated using the distance formula for each point in the tour (Bhattacharyya).  Although this is the proper way to express the problem, it is easier to see how the algorithm works if left as a minimization problem (improvement is easily seen). 

## SELECTION

The selection process is what determines the chromosomes will be selected for reproduction and the ones that will not. Generally, selection puts more emphasis on good solutions and eliminates bad solutions, while keeping a constant population size. Multiple copies of good solutions are made; each with varying characteristics, an most bad solutions are discarded. Some of the bad solutions are kept for the diversity among the solutions; adding a bad solution to the population helps to prevent convergence on one particular solution. (Kashyap).

Selection may be applied two main ways: roulette wheel selection and tournament selection. Both methods depend upon the fitness level of specific chromosomes in the population (Cunkas).

During roulette wheel selection, each chromosome is assigned a slot on an imaginary roulette wheel. The slot is proportionate to the fitness of the chromosomes; chromosomes with better fitness levels receive larger slots on the roulette wheel and therefore a larger probability of being selected. The roulette wheel is then spun a number of times and each solution the wheel lands on is put in a group. A parent chromosome is selected at random from the group to enter the crossover phase of the algorithm. This process is repeated again to produce another parent chromosome (Kashyap). Figure two shows a simple four-chromosome example of roulette wheel selection based on fitness level (higher percentages indicate higher fitness levels).

In tournament selection, selection is based on a tournament among a few chromosomes. Usually about two or three chromosomes are selected at random from the population, then the best of these chromosomes becomes a parent chromosome. This process is repeated again to produce another parent chromosome. The parent chromosomes then move on to the crossover phase of the algorithm (Cunkas). Figure three shows tournament selection between two sets of two chromosomes.
   
Essentially, both of these processes mimic Darwinian survival of the fittest in nature. In the natural world, selection is determined by an organism�s ability to survive. Organisms that are not fit enough to survive die out from climate changes, predators, and other obstacles, while others who are fit enough continue to reproduce, evolve, and become fitter. This is the main principle that drives the genetic algorithm (Ahmed).

This model uses tournament selection.

Essentially, both of these processes mimic Darwinian survival of the fittest in nature. In the natural world, selection is determined by an organism�s ability to survive. Organisms that are not fit enough to survive die out from climate changes, predators, and other obstacles, while others who are fit enough continue to reproduce, evolve, and become fitter. This is the main principle that drives the genetic algorithm (Ahmed).

## CROSSOVER

Crossover is the process by which two chromosomes combine tours to produce new offspring with characteristics from both tours. Two chromosomes are picked at random from a group of chromosomes and are combined to produce new ones (Kashyap). This process searches the solution space by maintaining common connections and by recombining uncommon genes (Cunkas).

The basic crossover method proceeds as follows. A common crossover site is selected randomly among the selected chromosomes and the information after the site is swapped. Figure four shows this crossover; called a single point crossover.

Unfortunately, this method of crossover is not supported by the TSP without extensive modification (Ahmed). 

The single point method of crossover produces invalid offspring for the TSP; some cities in the tour will repeat. For this reason, the edge recombination crossover (ERX) has been developed. The ERX is not only compatible with the TSP; it emphasizes adjacency information instead of order and sequence. In other words, the ERX focuses on creating new chromosomes based on links into and out of cities in both parent�s tours. This creates better chromosomes by preserving similar genetic material between parent chromosomes. Additionally, the ERX is more likely to retain common links between the parents than other traditional methods (Kashap).

## MUTATION

The basic function of the mutation operator is to introduce diversity into the population of chromosomes (Potvin). Chromosomes are deliberately changed in random locations to increase diversity by exploring the entire solution space (Cunkas). Tours are randomly chosen to mutate based on some probability, then within the tours, random points are chosen for mutation (Bryant). This can be done a variety of ways: but for this algorithm two points within the picked tour are chosen, then changed randomly to other numbers. The tour is then checked to make sure it is still valid.   
Swap mutation is another method of mutation. Just as the name suggests, a number of points in a chromosome are selected then swapped out. There is no need to check for validation of tours when using this method (Cunkas).  
The process of mutation introduces random disturbances into the search process not possible through crossover. This allows for a wider search and a diverse population of solutions (Potvin).

## HOW TO USE IT

The population-size slider controls how large the initial population of solutions will be.

The tournament-size slider determines how large the tournament size will be in selection.

The mutation-rate slider controls how often each chromosome is mutated. The number shown is a percentage.

The number-of-cycles slider sets the number of cycles the algorithm will run before stopping.

The crossover-rate slider controls the percentages of solutions that are created from crossover to rather than cloning.

The preserve-common-links switch determines if the algorithm gives preference to common links among parents or not; for example, if both parents contain a link from city one to two, this link is more likely to be preserved with this option on.

The swap-mutation switch determines if the mutation method used. On: two point swap mutation. Off: two point random mutation

The best global fitness and best global solution monitors show the best solution the algorithm has found. If the algorithm �jumps� back up to a worse fitness, these monitors will keep the best fitness overall.

The fitness plot displays a graph of the worst, average, and best fitness for each cycle of the algorithm.

The map display shows the current map loaded into the algorithm, and when the algorithm has finished, draws out the best tour between the cities.

## THINGS TO NOTICE

-Notice how the fitness graph generally goes shows a lower fitness over time; this means the algorithm is 'learning' and producing better solutions. 

-The algorithm will not find the best solution every time, but it usually finds a good one.

-When the model finishes running, it draws the shortest path it found on the map.

-A small population size usually generates better results than larger ones.

-The best fitnesses are around 280-290.

## THINGS TO TRY

-Try running the model more than once, you'll get different results most times.

-Move the crossover slider to 0, and observe the fitness graph.

-Move the mutation slider to 0, and observe the fitness graph.

-Turn the preserve-common-links? and swap-mutation? sliders off or on and run the model.

-Leave the model running overnight and observe the fitness when its finished.

## EXTENDING THE MODEL

-Use latitude and longitude for city locations.

-Change the crossover method.

-Change the selection method.

-Try a differant map.

-Include a tour cost equation (to calculate how much the tour would cost if taken) in the fitness evaluation process.

## RELATED MODELS

-Simple Genetic Algorithm

## CREDITS AND REFERENCES

-Ahmed, Zakir H. Genetic Algorithms for the Traveling Salesman Problem using Sequential 	 Constructive Operator. Al-Imam.

-Al-Dulaimi, Buthainah Fahran and Hamza A. Ali. Enhanced Traveling Salesman Problem  Solving by Genetic Algorithm Technique. World Academy of Science, Engineering and Technology. 2008. Web. November 28, 2010. <citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.91>.

-Bhattacharyya, Malay, and Anup Kumar Bandyopadhyay. "COMPARATIVE STUDY OF SOME SOLUTION METHODS FOR TRAVELING SALESMAN PROBLEM USING GENETIC ALGORITHMS." Cybernetics & Systems 40.1 (2009): 1-24. Academic Search Premier. EBSCO. Web. 7 Dec. 2010.

-Bryant, Kylie. "Genetic Algorithms and the Traveling Salesman Problem." 2000. EBSCO. 6 12 2010.

-�unkas, Mehmet, and M. Yasin �zsa?lam. "A COMPARATIVE STUDY ON PARTICLE SWARM OPTIMIZATION AND GENETIC ALGORITHMS FOR TRAVELING SALESMAN PROBLEMS." Cybernetics & Systems 40.6 (2009): 490-507. Academic Search Premier. EBSCO. Web. 7 Dec. 2010.

-Jayalakshmi, G. Andal, S. Sathiamoorthy, and R. Rajaram. "A Hybrid Genetic Algorithm � A New Approach to Solve Traveling Salesman Problem." International Journal of Computational Engineering Science 2.2 (2001): 339. Academic Search Premier. EBSCO. Web. 7 Dec. 2010.

-Kashyap, Chhavi. "Genetic Algorithms." PowerPoint Presentation.

-Potvin, Jean-Yves. Genetic Algorithms for the Traveling Salesman Problem. Universite de Montreal. Allals of Operations Research. Web. November 30, 2010. < http://www.springerlink.com/content/j13214073h2808k0/>.

-Yuping, Wang, et al. "A new encoding based genetic algorithm for the traveling salesman problem." Engineering Optimization 38.1 (2006): 1-13. Academic Search Premier. EBSCO. Web. 7 Dec. 2010.

Also, take a look at wikipeadia's description of the genetic algorithm; its not half bad.
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

salesman
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105
Rectangle -6459832 true false 210 180 240 240

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
  <experiment name="swap-mutation" repetitions="10" runMetricsEveryStep="true">
    <setup>united_kingdom
setup</setup>
    <go>go</go>
    <metric>min-fitness</metric>
    <enumeratedValueSet variable="population-size">
      <value value="251"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="crossover-rate">
      <value value="90"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tournament-size">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mutation-rate">
      <value value="12.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-cycles">
      <value value="304"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="preserve-common-links?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="swap-mutation?">
      <value value="true"/>
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
