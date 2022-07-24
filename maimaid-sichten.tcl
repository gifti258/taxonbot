#!/usr/bin/tclsh8.7
#exit

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]
source procs.tcl
source library.tcl
set db [get_db dewiki]

if 0 {
cont {ret1 {
	foreach item [encoding convertfrom [get $ret1 query unreviewedpages]] {
		lappend lurpage $item
	}
}} {*}$get / list unreviewedpages / utf8 1


set dcatSport [dcat list Sport 0]
puts $dcatSport

exit
}

set sportfilm [read [set f [open maimaid-sport-film.db r]]] ; close $f

cont {ret1 {
	foreach item [encoding convertfrom [get $ret1 query oldreviewedpages]] {
		lappend lorpage $item
	}
}} {*}$get / list oldreviewedpages / utf8 1

set lorpage [lsort $lorpage]
foreach orpage $lorpage {
	
	puts $orpage
	incr i
}
puts $i


exit

[16:04, 8.11.2017] Friederike Kotzian: hier kommt die Aufgabe: Kannst du alle 
nachzusichtenden Seiten so sortieren, dass die Seiten mit den meisten Beobachtern 
ganz oben stehen? 
[16:06, 8.11.2017] Friederike Kotzian: und kannst du dabei bitte 
all solche Seiten ausschließen, die zur Kategorie Sport oder Film, Schauspieler gehören?
[16:07, 8.11.2017] Friederike Kotzian: und kannst du diese Liste dann bitte noch untergliedern nach Personen, geografischen Objekten und Baudenkmalen?
[17:02, 8.11.2017] Friederike Kotzian: ach ja, und bitte auch noch alle Bearbeitungen ausschließen, die keinen Eintrag in der Bearbeitungszusammenfassungszeile haben

