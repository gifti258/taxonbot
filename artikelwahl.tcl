#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

#exit

catch {if {[exec pgrep -cxu taxonbot artikelwahl.tcl] > 1} {exit}}

set editafter 1

source api.tcl ; set lang dea ; source langwiki.tcl ; #set token [login $wiki]

set topkand {

[[Datei:QSicon Kand.svg|30x15px|text-unten|Auszeichnungskandidatur|link=:Wikipedia:Kandidaturen von Artikeln, Listen und Portalen]]&nbsp;'''Auszeichnungskandidatur:'''
}
set topkandidat {

[[Datei:Qsicon lesenswert Kandidat.svg|30x15px|text-unten|Kandidat Lesenswert|link=:Wikipedia:Kandidaten für lesenswerte Artikel]]&nbsp;'''Kandidat Lesenswert:'''
}
set topwiederwahl {

[[Datei:QSicon Kand.svg|30x15px|text-unten|Wiederwahl Lesenswert|link=:Wikipedia:Kandidaten für lesenswerte Artikel]]&nbsp;'''Wiederwahl Lesenswert:'''
}
set topexzabwahl {

[[Datei:Qsicon exzellent Abwahl.svg|30x15px|text-unten|Abwahl Exzellent|link=:Wikipedia:Kandidaturen von Artikeln, Listen und Portalen]]&nbsp;'''Abwahl Exzellent:'''
}
set topabwahl {

[[Datei:Qsicon lesenswert Abwahl.svg|30x15px|text-unten|Abwahl Lesenswert|link=:Wikipedia:Kandidaten für lesenswerte Artikel]]&nbsp;'''Abwahl Lesenswert:'''
}
lappend ltkand [template Kandidat 0] ; lappend ltkand [template Kandidat 100] ; set ltkand [string trim [join $ltkand]]
set ltkandidat [string trim [template Lesenswert-Kandidat 0]]
set ltwiederwahl [string trim [template Lesenswert-Wiederwahl 0]]
set ltexzabwahl [string trim [template Exzellent-Abwahl 0]]
set ltabwahl [string trim [template Lesenswert-Abwahl 0]]
if ![empty ltkand] {
	incr count [llength $ltkand]
	foreach tkand [lsort $ltkand] {
		lappend lkand "\[\[:$tkand\]\]<small> \[\[Wikipedia:Kandidaturen von Artikeln, Listen und Portalen#$tkand|(Disk)\]\]</small>"
	}
	append c $topkand [join $lkand "\n• "]
}
if ![empty ltkandidat] {
	incr count [llength $ltkandidat]
	foreach tkandidat [lsort $ltkandidat] {
		lappend lkandidat "\[\[:$tkandidat\]\]<small> \[\[Wikipedia:Kandidaten für lesenswerte Artikel#$tkandidat|(Disk)\]\]</small>"
	}
	append c $topkandidat [join $lkandidat "\n• "]
}
if ![empty ltwiederwahl] {
	incr count [llength $ltwiederwahl]
	foreach twiederwahl [lsort $ltwiederwahl] {
		lappend lwiederwahl "\[\[:$twiederwahl\]\]<small> \[\[Wikipedia:Kandidaten für lesenswerte Artikel#$twiederwahl|(Disk)\]\]</small>"
	}
	append c $topwiederwahl [join $lwiederwahl "\n• "]
}
if ![empty ltexzabwahl] {
	incr count [llength $ltexzabwahl]
	foreach texzabwahl [lsort $ltexzabwahl] {
		lappend lexzabwahl "\[\[:$texzabwahl\]\]<small> \[\[Wikipedia:Kandidaturen von Artikeln, Listen und Portalen#$texzabwahl|(Disk)\]\]</small>"
	}
	append c $topexzabwahl [join $lexzabwahl "\n• "]
}
if ![empty ltabwahl] {
	incr count [llength $ltabwahl]
	foreach tabwahl [lsort $ltabwahl] {
		lappend labwahl "\[\[:$tabwahl\]\]<small> \[\[Wikipedia:Kandidaten für lesenswerte Artikel#$tabwahl|(Disk)\]\]</small>"
	}
	append c $topabwahl [join $labwahl "\n• "]
}
regsub -- {(<!--MB-BWWORKLIST-->)(.*?)(\n<!--MB-BWWORKLIST-->)} [contents t Vorlage:Artikelwahlen x] \\1[string map {& \\&} $c]\\3 bw
set summary "Bot: Aktualisiere Wartungsliste BWWORKLIST ($count Einträge)"
if {$bw ne $contents} {
	puts [edit Vorlage:Artikelwahlen $summary $bw / minor]
}
