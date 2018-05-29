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
    
    let maxRouletteWheel max [rouletteWheel]of turtles
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
;;>>>>>>
;; Sollte z.B. Elitismus implementiert werden, ist darauf zu achten, dass die beste vorhandene Lösung NICHT mutiert wird
;; gegebenenfalls ist also eine neue Mutations-Prozedur zu implementieren, die für jeden Turtle/jede Lösung gesondert aufgerufen werden kann
;; (wie z.B. bei "calculate-distance" der Fall)
;;<<<<<<<


to mutate
  let random-item int (random-float 19)
  let random-item2 int (random-float 19)

  let random-number int (random-float 19) + 1
  let random-number2 int (random-float 19) + 1

  ;;>>>>>
  ;;in der bestehenden Implementierung werden die hier erstellten Zufallszahlen für jede Lösung einer Generation angewandt
  ;;d.h. es werden für eine Generation jeweils immer die gleichen Stellen in den Touren miteinander vertauscht (oder durch Zufallszahlen überschrieben);
  ;;dies könnte bei Bedarf auch angepasst und für jede Lösung individuell entschieden werden
  ;;<<<<<<


  ;;vor möglicher Mutation werden der Start- und Endort (Stadt 0) aus der Tourliste entfernt
;;ask turtles [
  ;;set string remove-item 0 string
  ;;set string remove-item 20 string]

ask turtles [
    ifelse elitism? and self = winner
    [
      ;do nothing, as we do not want to mutate the winner
    ]
    [
      ifelse swap-mutation?

      ;;falls true, d.h. Schalter im Interface ist "On": two point swap mutation
      ;;zwei Orte werden innerhalb der Tour miteinander getauscht
      ;;>>>>
      ;;dies wird hier so realisiert, dass in der Tour dann 2x der gleiche Ort vorkommt (und ein Ort überhaupt nicht mehr),
      ;;so dass und eine Reparatur durch den Aufruf von "fix-list" nötig ist;
      ;;der Tausch könnte bei Bedarf also deutlich effizienter und weniger fehleranfällig implementiert werden
      ;;<<<<<
      [if random-float 100.0 < mutation-rate [set string replace-item random-item string (item random-item2 string)
                                             set string replace-item random-item2 string (item random-item string)]]

      ;;falls false, d.h Schalter im Interface ist "Off": two point random mutation
      ;;zwei Orte werden einfach durch Zufallszahlen überschrieben,
      ;; da die entstehende Tour vermutlich nicht mehr zulässig ist, muss nachträglich "fix-list" aufgerufen werden
      [if random-float 100.0 < mutation-rate [set string replace-item random-item string random-number
                                              set string replace-item random-item2 string random-number2
                                              ]]
    ]
  ]

;;Reparatur der durch Mutation veränderten Routen, aufgrund der Implementierung ist dies auch für die two point swap mutation nötig
fix-list

 ;;Start- und Endort (Stadt 0) werden der Tourliste wieder hinzugefügt
 ;;ask turtles
  ;;[set string fput 0 string
   ;;set string lput 0 string]
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
