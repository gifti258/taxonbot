#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

#exit

catch {if {[exec pgrep -cxu taxonbot NeueArtikel2.tc] > 1} {exit}}

source api2.tcl
set lang kat ; source langwiki.tcl
source procs.tcl

set files [lsort [glob -tails -path NeueArtikel/ *]]
foreach 1 $files {lappend rawdb $1 [read [set f [open NeueArtikel/$1 r]]] ; close $f}
foreach {1 2} $rawdb {
	dict with 2 {
		lappend db [string map {_ { } ~~~~~ ~ ~ / ´´´´ !} $1] [list catdb $catdb param $param]
		lappend idb [string map {_ { } ~~~~~ ~ ~ / ´´´´ !} $1] $icatdb
	}
}
set f [open NeueArtikel.match/@NeueArtikel.db w] ; puts $f $db ; close $f
set f [open NeueArtikel.match/@iNeueArtikel.db w] ; puts $f $idb ; close $f
