#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

#exit

catch {if {[exec pgrep -cxu taxonbot wkat1.tcl] > 1} {exit}}

source api.tcl ; set lang dea ; source langwiki.tcl ; #set token [login $wiki]
set db [get_db dewiki]

puts "[clock format [clock seconds] -format %T]:wWkat komplett"

mysqlreceive $db "
	select page_title
	from page, categorylinks
	where page_id = cl_from and page_namespace = 0 and cl_to like 'Wikipedia:Redundanz\_%'
	order by page_title
;" pt {
	lappend lpt $pt
}
while 1 {
unset -nocomplain llparam
if ![catch {
foreach pt $lpt {
	set scont [split [string map [list \n {} \{\{ \n\{\{ \}\} \}\}\n] [conts t $pt x]] \n]
	foreach line $scont {
		if {[string first Redundanztext $line] > -1} {break}
	}
	set rddict1 [split [join [regsub -all {\[\[.*?\]\]} [string map [list \n {} style= {}] [dict values [
		regexp -inline -- {\{\{Redundanztext ??\| ?(\d.*?)\}\}} $line
	]]] ...]] |=]
	unset -nocomplain lparam i
	if {$rddict1 eq {}} {
		set rddict2 [split [join [regsub -all {\[\[.*?\]\]} [string map [list \n {} style= {}] [dict values [
			regexp -inline -- {\{\{Redundanztext ??\|(.*?)\}\}} $line
		]]] ...]] |=]
		foreach param $rddict2 {
			lappend lparam [incr i] [string trim $param]
		}
		lappend llparam $lparam
	} else {
		foreach param $rddict1 {
			lappend lparam [string trim $param]
		}
		lappend llparam $lparam
	}
}
}] {break}
}
foreach lparam $llparam {
	if {[string first { (CE} [lindex $lparam end]] > -1 && [lindex $lparam end-1] != 1} {set lparam [linsert $lparam end-1 1]}
	unset -nocomplain ltitle nltitle nlsqltitle
	lassign {} 3 4 5 6 7 8 9 10
	dict with lparam {
		lappend ltitle $3 $4 $5 $6 $7 $8 $9 $10
	}
	foreach title $ltitle {
		if {$title ne {}} {
			lappend nltitle [sql -> $title]
			set sqltitle [join [dict values [regexp -inline -- {^(.*?)(?:#|$)} $title]]]
			lappend nlsqltitle '[sql <- $sqltitle]'
		}
	}
	set nltitle [lsort -unique $nltitle]
	mysqlreceive $db "
		select cl_to
		from categorylinks, page
		where page_id = cl_from and page_title in ([join $nlsqltitle ,]) and page_namespace = 0
	;" {ct} {
		dict lappend wRDkat $nltitle Kategorie:[sql -> $ct]
	}
}
puts "[clock format [clock seconds] -format %T]:wRDkat komplett"

#lappend wkat1 wVSkat $wVSkat wINTkat $wINTkat wWkat $wWkat wRDkat $wRDkat

#set f [open WORKLIST/@wkat1.db w] ; puts $f $wkat1 ; close $f







