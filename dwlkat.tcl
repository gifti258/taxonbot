#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

#exit

catch {if {[exec pgrep -cxu taxonbot dwlkat.tcl] > 1} {exit}}

source api.tcl ; set lang kat ; source langwiki.tcl ; #set token [login $wiki]
source library.tcl

while 1 {if [catch {set db [get_db dewiki]}] {after 60000 ; continue} else {break}}

foreach wDW [sqldeepcat {Wikipedia:Defekte Weblinks} 0|1] {
	lappend wDWkat $wDW [pagecat $wDW]
}

lappend wkat wDWkat $wDWkat

set f [open WORKLIST/@wdwlkat.db w] ; puts $f $wkat ; close $f







