#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

#exit

catch {if {[exec pgrep -cxu taxonbot qswkat.tcl] > 1} {exit}}

source api.tcl ; set lang kat ; source langwiki.tcl ; #set token [login $wiki]

set lkc "	cl_to = 'Wikipedia:Löschkandidat'
			or cl_to = 'Wikipedia:Löschkandidat/Benutzer-_und_Metaseiten'
			or cl_to = 'Wikipedia:Löschkandidat/Vorlagen'
			or cl_to = 'Wikipedia:Löschkandidat_Bahn'
"
puts [clock format [clock seconds] -format %T]
set db [get_db dewiki]
mysqlreceive $db "
	select page_title, cl_to from (
		select page_title, page_id
		from page, categorylinks
		where cl_from = page_id and page_namespace != 14 and ($lkc)
	) as page, categorylinks
	where cl_from = page_id
	order by page_title
;" {pt ct} {
	dict lappend lkkat [string map {_ { }} $pt] Kategorie:[string map {_ { }} $ct]
}
mysqlclose $db
puts "[clock format [clock seconds] -format %T]:lkkat komplett"

#foreach lkid [
#	join "
#		[catids Wikipedia:Löschkandidat -kat]
#		[catids {Wikipedia:Löschkandidat/Benutzer- und Metaseiten} -kat]
#		[catids Wikipedia:Löschkandidat/Vorlagen -kat]
#		[catids {Wikipedia:Löschkandidat Bahn} -kat]
#	"
#] {lappend llkid "page_id = $lkid"}
#mysqlreceive $db "
#	select page_namespace, page_title, cl_to
#	from page, categorylinks
#	where cl_from = page_id and ([join $llkid { or }])
#	order by page_title
#;" {pns pt ct} {
#	if {[set pt [nssort -kat $pns $pt]] ne {}} {dict lappend lkkat $pt Kategorie:[string map {_ { }} $ct]}
#}

lassign [
	list [
			catitems Wikipedia:Kategorienlöschung 14
		] [catitems Wikipedia:Kategorienumbenennung 14
		] [catitems Wikipedia:Kategorienzusammenführung 14
		] [catitems {Wikipedia:Qualitätssicherung Kategorien} 14
		] [catitems Wikipedia:Kategorienklassifizierung 14
	]
] kdla kdub kdzf kdqs kdkl
lappend kdkat kdla $kdla kdub $kdub kdzf $kdzf kdqs $kdqs kdkl $kdkl
puts "[clock format [clock seconds] -format %T]:kdkat komplett"

foreach rvid [catids Wikipedia:Reviewprozess -kat] {lappend lrvid "page_id = $rvid"}
set db [get_db dewiki]
mysqlreceive $db "
	select page_namespace, page_title, cl_to
	from page, categorylinks
	where cl_from = page_id and ([join $lrvid { or }])
	order by page_title
;" {pns pt ct} {
	if {[set pt [nssort -kat $pns $pt]] ne {}} {dict lappend rvkat $pt Kategorie:[string map {_ { }} $ct]}
}
mysqlclose $db
puts "[clock format [clock seconds] -format %T]:rvkat komplett"


#foreach lk [join [lappend llk [cat {Kategorie:Wikipedia:Löschkandidat} -kat] [cat {Kategorie:Wikipedia:Löschkandidat/Benutzer- und Metaseiten} -kat] [cat {Kategorie:Wikipedia:Löschkandidat/Vorlagen} -kat] [cat {Kategorie:Wikipedia:Löschkandidat Bahn} -kat]]] {
#	lappend lkkat $lk [pagecat $lk]
#}

#lassign [list [cat {Kategorie:Wikipedia:Kategorienlöschung} 14] [cat {Kategorie:Wikipedia:Kategorienumbenennung} 14] [cat {Kategorie:Wikipedia:Kategorienzusammenführung} 14] [cat {Kategorie:Wikipedia:Qualitätssicherung Kategorien} 14] [cat {Kategorie:Wikipedia:Kategorienklassifizierung} 14]] kdla kdub kdzf kdqs kdkl
#lappend kdkat kdla $kdla kdub $kdub kdzf $kdzf kdqs $kdqs kdkl $kdkl

#foreach rv [cat {Kategorie:Wikipedia:Reviewprozess} -kat] {
#	lappend rvkat $rv [pagecat $rv]
#}

source QSWORKLIST/@qsdict.db
foreach key [dict keys $qsdict] {lappend lkey "tl_title = '[string map {{ } _ {\'} {\'} {'} {\'}} $key]'"}
set db [get_db dewiki]
mysqlreceive $db "
	select page_title, tl_title, cl_to
	from page, templatelinks, categorylinks
	where tl_from = page_id and cl_from = page_id and page_namespace = 0 and ([join $lkey { or }])
	order by page_title
;" {pt tl ct} {
	dict lappend lsnak [list $pt $tl] Kategorie:[string map {_ { }} $ct]
}
mysqlclose $db
foreach {pttl lcat} $lsnak {
	lappend qskat [string map {_ { }} [lindex $pttl 0]] [
		list pagecat $lcat qstempl [
			set key [string map {_ { }} [lindex $pttl 1]]
		] qsshort [lindex [set val [dict get $qsdict $key]] 0] qslong [lindex $val 1]
	]
}
puts "[clock format [clock seconds] -format %T]:qskat komplett"

#source QSWORKLIST/@qsdict.db
#foreach key [dict keys $qsdict] {lappend lqs [template $key 0]}
#foreach item [lsort -unique [join $lqs]] {
#	foreach templ [dict keys $qsdict] {
#		if [matchtemplate $item Vorlage:$templ] {
#			lassign [list [lindex [dict get $qsdict $templ] 0] [lindex [dict get $qsdict $templ] 1]] qsshort qslong
#			lappend qskat $item [list pagecat [pagecat $item] qstempl $templ qsshort $qsshort qslong $qslong]
#			break
#		}
#	}
#}

set db [get_db dewiki]
mysqlreceive $db "
	select page_namespace, page_title, cl_to from page, categorylinks, templatelinks
	where cl_from = page_id and tl_from = page_id
		and (tl_title = 'Portalhinweis' or tl_title = 'Projekthinweis' or tl_title = 'Redaktionshinweis')
	order by page_title
;" {pns pt ct} {
   if {[set pt [nssort p $pns $pt]] ne {}} {dict lappend phkat $pt Kategorie:[string map {_ { }} $ct]}
}
mysqlclose $db
puts "[clock format [clock seconds] -format %T]:phkat komplett"


#foreach ei {Portalhinweis Projekthinweis Redaktionshinweis} {lappend ph [template $ei p]}
#foreach ph [lsort -unique [join $ph]] {
#	lappend phkat $ph [pagecat $ph]
#}

lappend qswkat lkkat $lkkat kdkat $kdkat rvkat $rvkat qskat $qskat phkat $phkat

set f [open QSWORKLIST/@qswkat.db w] ; puts $f $qswkat ; close $f
