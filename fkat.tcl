#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

#exit

catch {if {[exec pgrep -cxu taxonbot wkat2.tcl] > 1} {exit}}

source api.tcl ; set lang dea ; source langwiki.tcl ; #set token [login $wiki]

puts [clock format [clock seconds] -format %T]

set db [get_db dewiki]
mysqlreceive $db "
	select pl_title
	from pagelinks
	where pl_from in ([dcat sqlid Frauen 0]) and pl_from_namespace = 0 and pl_namespace = 0 and pl_title not in (
		select page_title
		from page
		where page_namespace = 0
	)
	order by pl_title
;" plt {
	dict lappend dplt [sql <- $plt] [sql <- $plt]
}
mysqlclose $db
foreach {plt lplt} $dplt {
	lappend wVFkat [llength $lplt] $plt
}
set wVFkat [lsort -stride 2 -index 0 -integer $wVFkat]
puts $wVFkat
set f [open fkat.db w] ; puts $f $wVFkat ; close $f
puts "[clock format [clock seconds] -format %T]:wVFkat komplett"


#lappend wkat2 wALTkat $wALTkat wGEOkat $wGEOkat wVFkat $wVFkat

#set f [open WORKLIST/@wkat2.db w] ; puts $f $wkat2 ; close $f







