#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

#exit

#catch {if {[exec pgrep -cxu taxonbot wkat.tcl] > 1} {exit}}

source api.tcl ; set lang dea ; source langwiki.tcl ; #set token [login $wiki]
set db [get_db enwiki]

puts [clock format [clock seconds] -format %T]

#foreach wUEid [catids Wikipedia:Überarbeiten p] {lappend lwUEid $wUEid"}
#set wUEid [catids Wikipedia:Überarbeiten p]
#puts $wUEid
#exit

if 0 {

mysqlreceive $db "
	select page_namespace, page_title, cl_to
	from page, categorylinks
	where cl_from = page_id and page_id in ([join [catids Wikipedia:Überarbeiten p] ,])
	order by page_title
;" {pns pt ct} {
	if {[set pt [nssort p $pns $pt]] ne {}} {dict lappend wUEkat $pt Kategorie:[string map {_ { }} $ct]}
}
puts "[clock format [clock seconds] -format %T]:wUEkat komplett"

#foreach wUVid [catids Wikipedia:Unverständlich p] {lappend lwUVid "page_id = $wUVid"}
mysqlreceive $db "
	select page_namespace, page_title, cl_to
	from page, categorylinks
	where cl_from = page_id and page_id in ([join [catids Wikipedia:Unverständlich p] ,])
	order by page_title
;" {pns pt ct} {
	if {[set pt [nssort p $pns $pt]] ne {}} {dict lappend wUVkat $pt Kategorie:[string map {_ { }} $ct]}
}
puts "[clock format [clock seconds] -format %T]:wUVkat komplett"

#foreach wLUEid [catids Wikipedia:Lückenhaft p] {lappend lwLUEid "page_id = $wLUEid"}
mysqlreceive $db "
	select page_namespace, page_title, cl_to
	from page, categorylinks
	where cl_from = page_id and page_id in ([join [catids Wikipedia:Lückenhaft p] ,])
	order by page_title
;" {pns pt ct} {
	if {[set pt [nssort p $pns $pt]] ne {}} {dict lappend wLUEkat $pt Kategorie:[string map {_ { }} $ct]}
}
puts "[clock format [clock seconds] -format %T]:wLUEkat komplett"

#foreach wLid [catids {Wikipedia:Nur Liste} p] {lappend lwLid "page_id = $wLid"}
mysqlreceive $db "
	select page_namespace, page_title, cl_to
	from page, categorylinks
	where cl_from = page_id and page_id in ([join [catids {Wikipedia:Nur Liste} p] ,])
	order by page_title
;" {pns pt ct} {
	if {[set pt [nssort p $pns $pt]] ne {}} {dict lappend wLkat $pt Kategorie:[string map {_ { }} $ct]}
}
puts "[clock format [clock seconds] -format %T]:wLkat komplett"

#mysqlreceive $db "
#	select page_title, cl_to
#	from (
#		select page_title, page_id
#		from page, categorylinks
#		where cl_from = page_id and page_namespace = 0 and cl_to = 'Wikipedia:Belege_fehlen'
#	) as page, categorylinks
#	where cl_from = page_id
#	order by page_title
#;" {pt ct} {
#	dict lappend wQFkat [string map {_ { }} $pt] Kategorie:[string map {_ { }} $ct]
#}

#foreach wQFid [catids {Wikipedia:Belege fehlen} p] {lappend lwQFid "page_id = $wQFid"}
mysqlreceive $db "
	select page_namespace, page_title, cl_to
	from page, categorylinks
	where cl_from = page_id and page_id in ([join [catids {Wikipedia:Belege fehlen} p] ,])
	order by page_title
;" {pns pt ct} {
	if {[set pt [nssort p $pns $pt]] ne {}} {dict lappend wQFkat $pt Kategorie:[string map {_ { }} $ct]}
}
puts "[clock format [clock seconds] -format %T]:wQFkat komplett"

#foreach wNid [catids Wikipedia:Neutralität p] {lappend lwNid "page_id = $wNid"}
mysqlreceive $db "
	select page_namespace, page_title, cl_to
	from page, categorylinks
	where cl_from = page_id and page_id in ([join [catids Wikipedia:Neutralität p] ,])
	order by page_title
;" {pns pt ct} {
	if {[set pt [nssort p $pns $pt]] ne {}} {dict lappend wNkat $pt Kategorie:[string map {_ { }} $ct]}
}
puts "[clock format [clock seconds] -format %T]:wNkat komplett"

}

set hidden [scat Kategorie:Versteckt 14]
puts $hidden

mysqlreceive $db "
	select page_id, cl_to
	from dewiki_p.page
	left join dewiki_p.categorylinks on cl_from = page_id
	where page_namespace = 0 and page_is_redirect = 0
	order by page_title
;" {pt cl} {
puts $pt
#	if {$cl in $hidden} {set cl {}}
#	dict lappend lwKAT $pt $cl
}
puts $lwKAT
exit

foreach {pt cl} $lwKAT {
	foreach item $cl {
		if {$item eq {}} {lremove cl $item}
	}
	if {$cl eq {}} {
		if ![regexp -nocase -all {#WEITERLEITUNG|#REDIRECT|\{\{URV} [conts id $pt x]] {lappend nlwKAT $pt}
	}
}
foreach item $nlwKAT {
	set lcat {}
	if [catch {set conts [conts id $item 0]}] {continue}
	set lwlink [dict values [regexp -all -inline -- {\[\[(.*?)[|#\]]} $conts]]
	foreach wlink [lsort -unique $lwlink] {
		if [catch {if ![ns $wlink] {lappend lcat [pagecat $wlink]}}] {continue}
	}
	set pt [string map {_ { }} [mysqlsel $db "select page_title from page where page_id = $item;" -list]]
	lappend wKATkat $pt [lsort -unique [join $lcat]]
}
puts "[clock format [set catsecs [clock seconds]] -format %T]:wKATkat komplett"
set stand [clock format $catsecs -format {Stand: %Y-%m-%d %T (%Z)} -timezone :Europe/Berlin -locale de]
set kathead {Als Ergänzung zu [[Spezial:Nicht kategorisierte Seiten]], die Artikel mit Wartungskategorien nicht listet, werden auf dieser Seite alle ''nicht kategorisierten Artikel'' dargestellt:}
mysqlreceive $db "
	select page_title
	from page
	where page_id in ([join $nlwKAT ,]) and page_namespace = 0
	order by page_title
;" pt {
	lappend lpt "# \[\[[sql -> $pt]\]\]"
}
puts [edid 9857594 "Bot: [llength $nlwKAT] unkategorisierte Artikel" "$kathead\n\n$stand by \[\[Benutzerin:TaxonBota|TaxonBota\]\]\n\n[join $lpt \n]" / minor]
set f [open wKATkat w] ; puts $f nlwKAT:$nlwKAT\n\nwKATkat:$wKATkat ; close $f
unset -nocomplain hidden lwKAT nlwKAT lwlink lcat lpt

set yr [clock format [clock seconds] -format %Y]
mysqlreceive $db "
	select page_title, cl_to
	from page, categorylinks
	where cl_from = page_id and page_namespace = 0 and (cl_to like 'Geboren%' or cl_to like 'Gestorben%')
	order by page_title
;" {pt ct} {
	dict lappend lpd $pt $ct
}
foreach {pt pd} $lpd {
	if {[llength $pd] == 1 && [string first Geboren $pd] > -1} {
		unset -nocomplain born
		regexp -- {\d{4}} $pd born
		catch {
			if {[expr $yr - $born] > 105} {
				lappend lpt "page_title = '$pt'"
			}
		}
	}
}
mysqlreceive $db "
	select page_title, ll_lang, ll_title, cl_to
	from page
	left join langlinks on ll_from = page_id
	left join categorylinks on cl_from = page_id
	where page_namespace = 0 and ([join $lpt { or }])
;" {pt lll llt ct} {
	dict lappend lwVVkat [string map {_ { }} $pt] [list $lll [string map {_ { }} $llt]]
	dict lappend cwVVkat [string map {_ { }} $pt] Kategorie:[string map {_ { }} $ct]
}
foreach {pt ll} $lwVVkat {lappend nlwVVkat $pt [join [lsort -unique $ll]]}
foreach {pt ct} $cwVVkat {lappend ncwVVkat $pt [lsort -unique $ct]}
set wVVkat [join [lmap pt [dict keys $nlwVVkat] ll [dict values $nlwVVkat] ct [dict values $ncwVVkat] {list [list $pt $ll] $ct}]]
puts "[clock format [clock seconds] -format %T]:wVVkat komplett"
unset -nocomplain lpt

lappend wkat wUEkat $wUEkat wUVkat $wUVkat wLUEkat $wLUEkat wLkat $wLkat wQFkat $wQFkat wNkat $wNkat wKATkat $wKATkat wVVkat $wVVkat

set f [open WORKLIST/@wkat.db w] ; puts $f $wkat ; close $f







