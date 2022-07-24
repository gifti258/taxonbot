#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

#exit

catch {if {[exec pgrep -cxu taxonbot NeueArtikel3v.t] > 1} {exit}}

source api2.tcl
set lang dea ; source langwiki.tcl ; #set token [login $wiki]
source procs.tcl
#while 1 {if [catch {set db [get_db dewiki]}] {after 60000 ; continue} else {break}}

set db [get_db dewiki]
mysqlreceive $db "
	select page_title
	from page join categorylinks on cl_from = page_id
	where page_namespace = 14 and cl_to = 'Kategorie:Versteckt'
	order by page_title
;" pt {
	lappend hidden Kategorie:[sql -> $pt]
}
mysqlclose $db
set f [open hidden.db w] ; puts $f "set hidden \{$hidden\}" ; close $f
unset hidden

set db [get_db dewiki]
mysqlreceive $db "
	select page_title
	from page join categorylinks on cl_from = page_id
	where !page_namespace and cl_to = 'Begriffsklärung'
	order by page_title
;" pt {
	lappend bkl [sql -> $pt]
}
mysqlclose $db
set f [open bkl.db w] ; puts $f "set bkl \{$bkl\}" ; close $f
unset bkl

#source QSWORKLIST/@qsdict.db
#set qswkat [read [set f [open QSWORKLIST/@qswkat.db r]]] ; close $f
#foreach key {lkkat kdkat rvkat qskat phkat} {
#	set $key [dict get $qswkat $key]
#}
#set wkat [read [set f [open WORKLIST/@wkat.db r]]] ; close $f
#foreach key {wUEkat wUVkat wLUEkat wLkat wQFkat wNkat wKATkat wVVkat wDWkat} {
#	set $key [dict get $wkat $key]
#}
#set wkat1 [read [set f [open WORKLIST/@wkat1.db r]]] ; close $f
#foreach key {wVSkat wINTkat wWkat wRDkat} {
#	set $key [dict get $wkat1 $key]
#}
#mysqlreceive $db "select page_title from page, categorylinks where page_namespace = 14 and cl_from = page_id and cl_to = 'Kategorie:Versteckt';" pt {lappend hidden Kategorie:[string map {_ { }} $pt]}

set tday [utc -> seconds {} %m%d {}]
#set tday 1204
#set twday [utc -> seconds {} %u {}]
#set tday [clock format [clock seconds] -format %m%d -timezone :Europe/Berlin]
#set tmonth [clock format [clock seconds] -format %m]
set lportal		[cat {Kategorie:Wikipedia:MerlBot-Listen Typ (NeueArtikel)} x]
set lqsportal	[cat {Kategorie:Wikipedia:MerlBot-Listen Typ (QSWORKLIST)} x]
set lwportal	[cat {Kategorie:Wikipedia:MerlBot-Listen Typ (WORKLIST)} x]
set lbwportal	[cat {Kategorie:Wikipedia:MerlBot-Listen Typ (BWWORKLIST)} x]
foreach portal $lqsportal {if {$portal ni $lportal} {lappend slqsportal $portal}}
foreach portal $lwportal {if {$portal ni $lportal && $portal ni $slqsportal} {lappend slwportal $portal}}
foreach portal $lbwportal {if {$portal ni $lportal && $portal ni $slqsportal && $portal ni $lwportal} {lappend slbwportal $portal}}
#foreach portal $lportal {lremove lqsportal $portal}
#set bkl [template Begriffsklärung 0]
set nadb [read [set f [open NeueArtikel.match/NeueArtikel-$tday r]]] ; close $f
set sdb [lrange [split $nadb \n] 1 end-1]
if {{/leer/} ni [dict values [lindex $sdb end-2]]} {puts {Vorlage fehlerhaft} ; exit}
set d {}
foreach line $sdb {
	dict with line {
		if {[lsearch -exact $d $portal] == -1} {
			lappend d $portal [list listformat $listformat alt $alt titles [list $hit $title $neu]]
		} else {
			dict lappend d $portal [list $hit $title $neu]
		}
	}
}
foreach {1 2} $d {lappend e $1 [join [list [lrange $2 0 4] [list [lrange $2 4 end]]]]}
foreach qsportal $slqsportal {lappend e $qsportal x}
foreach wportal $slwportal {lappend e $wportal x}
foreach bwportal $slbwportal {lappend e $bwportal x}

set aaaa 0

foreach {portal data} $e {
	if {$portal eq {Vorlage:Artikelwahlen}} {continue} ; # Vorlage:Artikelwahlen by artikelwahl.tcl
#	if {$portal eq {Benutzer:Squasher/Qualität} && $twday != 5} {continue} ; # nur freitags
#	if {$portal ne {Portal:Aargau/Bausteine} && !$aaaa} {continue} else {incr aaaa}
#	if {$portal ne {Portal:Österreich/Neue Artikel auto}} {continue} else {set 1x 1}
	while 1 {
		try {
			if {[exec pgrep -cxu taxonbot NeueArtikel5.tc] < 10} {
				exec ./NeueArtikel5.tcl "[list $portal $data]" &
				after 6000
				break
			}
		} on 1 {} {exec ./NeueArtikel5.tcl "[list $portal $data]" & ; after 6000 ; break}
#		if $1x {exit}
	}
}

while 1 {
	try {exec pgrep -cxu taxonbot NeueArtikel5.tc} on 1 {} {
		puts "\nend of task"
		set lang test ; source langwiki.tcl ; #set token [login $wiki]
		puts [edid 63277 {Log: MB4} {} / appendtext "\n* '''[
			clock format [clock seconds] -format %Y-%m-%dT%TZ
		] NeueArtikel3v: Task finished!'''"]
		exit
	}
}

