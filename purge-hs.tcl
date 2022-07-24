#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

#exit

#catch {if {[exec pgrep -cxu taxonbot purge.tcl] > 1} {exit}}

source api.tcl ; set lang dea ; source langwiki.tcl ; #set token [login $wiki]

puts [utc <- seconds {} %Y-%m-%d-%T {}]\n

set c3 [conts t Benutzer:AsuraBot/Purges 3]
set ll3 [dict values [regexp -all -inline -line -- {^\* \[\[[:]?(.*?)[|\]].*$} $c3]]
foreach l3 $ll3 {
	if {[string first Hauptseite/ $l3] == -1} {lappend nll3 $l3}
}

set db [get_db dewiki]
mysqlreceive $db {
	select pl_title
	from pagelinks
	where pl_from = 8395013 and pl_from_namespace = 2 and pl_namespace = 4 and pl_title like 'Hauptseite/%' and pl_title != 'Hauptseite/Heute' and pl_title != 'Hauptseite/morgen'
;} pt {
	lappend nll3 Wikipedia:[sql -> $pt]
}
mysqlclose $db

puts \nPurge-HS:[get [post $wiki {*}$format / action purge / titles [join $nll3 |] / forcerecursivelinkupdate 1]]\n
puts \nPurge-HS:[get [post $wiki {*}$format / action purge / titles Wikipedia:Hauptseite / forcerecursivelinkupdate 1]]\n
