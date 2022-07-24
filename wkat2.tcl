#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

#exit

catch {if {[exec pgrep -cxu taxonbot wkat2.tcl] > 1} {exit}}

source api.tcl ; set lang dea ; source langwiki.tcl ; #set token [login $wiki]

puts [clock format [clock seconds] -format %T]
set db [get_db dewiki]
mysqlreceive $db "
	select page_title, cl_to
	from page c, templatelinks, categorylinks d
	where tl_from = c.page_id and d.cl_from = c.page_id and c.page_namespace = 0 and tl_from_namespace = 0 and tl_namespace = 10 and tl_title in (
		select page_title
		from page a, categorylinks b
		where b.cl_from = a.page_id and a.page_namespace = 10 and b.cl_to = 'Vorlage:Veraltet'
	)
	order by c.page_title
;" {pt ct} {
	dict lappend wALTkat [sql -> $pt] Kategorie:[sql -> $ct]
}
mysqlclose $db
puts "[clock format [clock seconds] -format %T]:wALTkat komplett"

#set lpt [set lcat 'Wikipedia:Lagewunsch']
#while {$lcat ne {}} {
#	set lcat1 {}
#	mysqlreceive $db "
#		select page_title
#		from page, categorylinks
#		where cl_from = page_id and page_namespace = 14 and cl_to in ([join $lcat ,])
#	;" pt {
#		set lcat {}
#		lappend lpt '$pt'
#		lappend lcat1 '$pt'
#	}
#	set lcat $lcat1
#}
set db [get_db dewiki]
mysqlreceive $db "
	select page_title, cl_to
	from (
		select page_id, page_title
		from page, categorylinks a
		where a.cl_from = page_id and page_namespace = 0 and a.cl_to in ([dcat sql Wikipedia:Lagewunsch 14])
	) b, categorylinks c
	where c.cl_from = b.page_id
	order by page_title
;" {pt ct} {
	dict lappend wGEOkat [sql -> $pt] Kategorie:[sql -> $ct]
}
mysqlclose $db
puts "[clock format [clock seconds] -format %T]:wGEOkat komplett"

set db [get_db dewiki]
mysqlreceive $db "
	select page_title, cl_to
	from page b, categorylinks, templatelinks
	where cl_from = b.page_id and tl_from = b.page_id and b.page_namespace = 0 and tl_from_namespace = 0 and tl_namespace = 10 and tl_title not in (
		select page_title
		from page a
		where a.page_namespace = 10
	)
	order by page_title
;" {pt ct} {
	dict lappend wVFkat [sql -> $pt] Kategorie:[sql -> $ct]
}
mysqlclose $db
puts "[clock format [clock seconds] -format %T]:wVFkat komplett"

#set f [open WORKLIST/@wDFit.db w] ; close $f
set wDFit {}
set db [get_db dewiki]
mysqlreceive $db "
	select page_title, il_to
	from page c, imagelinks
	where il_from = c.page_id and c.page_namespace = 0 and il_from_namespace = 0 and il_to not in (
		select page_title
		from page a
		where a.page_namespace = 6
	) and il_to not in (
		select page_title
		from commonswiki_p.page b
		where b.page_namespace = 6
	)
;" {pt it} {
	set demiss [missing File:$it]
	set lang commons ; source langwiki.tcl ; #set token [login $wiki]
	set commiss [missing File:$it]
	set lang dea ; source langwiki.tcl ; #set token [login $wiki]
	if {$demiss && $commiss} {
		lappend lpt '[sql <- $pt]'
		lappend wDFit $it
		lappend lwl "* \[\[:[sql -> $pt]\]\]: \[\[:Datei:[sql -> $it]\]\]"
	}
}
mysqlclose $db
set f [open WORKLIST/@wDFit.db w] ; puts $f [lsort -unique $wDFit] ; close $f
puts [edid 4901404 "Bot: WORKLIST: [tdot [llength $lwl]] Einträge" [string map {{\&} &} [regsub -- {(<!--MB-WORKLIST-->).*<!--MB-WORKLIST-->} [conts id 4901404 x] \\1\n[join [string map {& {\&}} $lwl] \n]\n\\1]] / minor]
set db [get_db dewiki]
mysqlreceive $db "
	select page_title, cl_to
	from page, categorylinks
	where cl_from = page_id and page_namespace = 0 and page_title in ([join $lpt ,])
;" {pt ct} {
	dict lappend wDFkat [sql -> $pt] Kategorie:[sql -> $ct]
}
mysqlclose $db
puts "[clock format [clock seconds] -format %T]:wDFkat komplett"
unset -nocomplain lpt

set db [get_db dewiki]
mysqlreceive $db "
	select page_title, cl_to
	from (
		select page_id, page_title
		from page, categorylinks a
		where a.cl_from = page_id and page_namespace = 0 and a.cl_to in ([dcat sql Wikipedia:Bilderwunsch 14])
	) b, categorylinks c
	where c.cl_from = b.page_id
	order by page_title
;" {pt ct} {
	dict lappend wBWkat [sql -> $pt] Kategorie:[sql -> $ct]
}
mysqlclose $db
puts "[clock format [clock seconds] -format %T]:wBWkat komplett"

lappend wkat2 wALTkat $wALTkat wGEOkat $wGEOkat wVFkat $wVFkat wDFkat $wDFkat wBWkat $wBWkat

set f [open WORKLIST/@wkat2.db w] ; puts $f $wkat2 ; close $f







