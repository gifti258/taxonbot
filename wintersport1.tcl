#!/usr/bin/tclsh8.7
#exit

source api.tcl ; set lang dea ; source langwiki.tcl ; #set token [login $wiki]

set lcat Wintersport
lappend lcat [dcat list Wintersport 14]
set lt [lsort -nocase [dcat list Wintersport 0]]
set lenArtikel [llength $lt]
foreach t $lt {
	while 1 {
		if ![catch {
			set db1 [get_db dewiki]
			lassign {} sort redir
			mysqlreceive $db1 "
				select page_title
				from page join redirect on rd_from = page_id
				where !page_namespace and !rd_namespace and rd_title = '[sql <- $t]'
			;" pt {
				lappend redir [format {[[:%s]]} [sql -> $pt]]
			}
			if ![empty redir] {
				set redir [format {<small> · [[:Diskussion:%s|Disk.]] · WLs: %s</small>} $t [join $redir {, }]]
			} else {
				set redir [format {<small> · [[:Diskussion:%s|Disk.]]</small>} $t]
			}
			regexp -line -- {\{\{(.*?SORT.*?)\}\}} [conts t $t x] -- sort
			set sort [string toupper [string trim [join [lrange [split $sort :] 1 5]]] 0]
			if [empty sort] {set sort [string toupper $t 0]}
			set index [string index $sort 0]
			if {$index eq {Ä}} {
				set index A
			} elseif {$index eq {Ö}} {
				set index O
			} elseif {$index eq {Ü}} {
				set index U
			} elseif {[string is integer $index] || $index eq {#}} {
				set index 0–9
			}
			dict lappend dline $index "* \[\[:$t\]\]$redir"
			mysqlclose $db1
		}] {break}
	}
}
foreach {index val} $dline {
	set header [format {<noinclude>{{Portal:Wintersport/Index/Kopf}}%s{{nobots|deny=verschieberest}}%s</noinclude>} \n \n]
	set body [format {== Artikel %s ==%s<div style="-moz-column-count:2; column-count:2;">%s</div>} $index \n \n[join $val \n]\n]
	set footer {[[Kategorie:Portal:Wintersport]]}
	set nart $header\n\n$body\n\n$footer
	puts [edit Portal:Wintersport/Index/$index {Bot: Aktualisierung} $nart / minor]
}

lassign {} dline body
foreach {ns index} {10 Vorlage 6 Datei 100 Portal 4 Wikipedia} {
	switch $ns {
		10			{
						set lt [list [dcat list {Vorlage:Infobox Wintersport} 10]]
						lappend lt [dcat list {Vorlage:Navigationsleiste Wintersport} 10]
						set lt [lsort -nocase [join $lt]]
						set len$index [llength $lt]
						lappend lcat {{Vorlage:Infobox Wintersport} {Vorlage:Navigationsleiste Wintersport}}
						lappend lcat [dcat list {Vorlage:Infobox Wintersport} 14]
						lappend lcat [dcat list {Vorlage:Navigationsleiste Wintersport} 14]
					}
		4			{
						set lt {{WikiProjekt Alpiner Skisport} {WikiProjekt Austragungsorte im Wintersport} {WikiProjekt Eishockey} {WikiProjekt Olympische Spiele}}
						set lenProjekt [llength $lt]
					}
		default	{
						set lt [lsort -nocase [dcat list $index:Wintersport $ns]]
						set len$index [llength $lt]
						lappend lcat $index:Wintersport
						lappend lcat [dcat list $index:Wintersport 14]
					}
	}
	foreach t $lt {
		while 1 {
			if ![catch {
				set db1 [get_db dewiki]
				lassign {} sort redir
				mysqlreceive $db1 "
					select page_title
					from page join redirect on rd_from = page_id
					where page_namespace = $ns and rd_namespace = $ns and rd_title = '[sql <- $t]'
				;" pt {
					lappend redir [format {[[:%s]]} [sql -> $index:$pt]]
				}
				if ![empty redir] {
					set redir [format {<small> · [[:%s Diskussion:%s|Disk.]] · WLs: %s</small>} $index $t [join $redir {, }]]
				} else {
					set redir [format {<small> · [[:%s Diskussion:%s|Disk.]]</small>} $index $t]
				}
				if {$t eq {Wintersport/Index/Sonstiges}} {
					dict lappend dline $index "* $index:$t$redir"
				} else {
					dict lappend dline $index "* \[\[:$index:$t\]\]$redir"
				}
				mysqlclose $db1
			}] {break}
		}
	}
}
foreach {index val} $dline {
	if {$index eq {Wikipedia}} {set index Projekt}
	lappend body [format {== %s ==%s<div style="-moz-column-count:2; column-count:2;">%s</div>} $index \n \n[join $val \n]\n]
}
set extra $header\n\n[join $body \n\n]\n\n$footer
puts [edit Portal:Wintersport/Index/Sonstiges {Bot: Aktualisierung} $extra / minor]

set lenKategorie [llength [join $lcat]]
foreach t [join $lcat] {
	while 1 {
		if ![catch {
			set db1 [get_db dewiki]
			lassign {} sort redir
			mysqlreceive $db1 "
				select page_title
				from page join redirect on rd_from = page_id
				where page_namespace = 14 and rd_namespace = 14 and rd_title = '[sql <- $t]'
			;" pt {
				lappend redir [format {[[:%s]]} [sql -> Kategorie:$pt]]
			}
			if ![empty redir] {
				set redir [format {<small> · [[:Kategorie Diskussion:%s|Disk.]] · WLs: %s</small>} $t [join $redir {, }]]
			} else {
				set redir [format {<small> · [[:Kategorie Diskussion:%s|Disk.]]</small>} $t]
			}
			dict lappend dcat Kategorie "* \[\[:Kategorie:$t\]\]$redir"
			mysqlclose $db1
		}] {break}
	}
}
set body [format {== Kategorie ==%s<div style="-moz-column-count:2; column-count:2;">%s</div>} \n \n[join [dict get $dcat Kategorie] \n]\n]
set cat $header\n\n$body\n\n$footer
puts [edit Portal:Wintersport/Index/Kategorien {Bot: Aktualisierung} $cat / minor]

set head [list [format {* '''Stand:''' %s} [utc -> seconds {} %Y-%m-%d {}]]]
lappend head [format {* '''Artikel:''' %s} [tdot $lenArtikel]]
lappend head [format {* '''Vorlagen:''' %s} [tdot $lenVorlage]]
lappend head [format {* '''Dateien:''' %s} [tdot $lenDatei]]
lappend head [format {* '''Kategorien:''' %s} [tdot $lenKategorie]]
lappend head [format {* '''Portalseiten:''' %s} [tdot $lenPortal]]
lappend head [format {* '''Projektseiten:''' %s} [tdot $lenProjekt]]
lappend head {} {{{TOC/Wintersport}}}
set nhead [regsub -- {\*.*} [conts t Portal:Wintersport/Index/Kopf x] [join $head \n]]
puts [edit Portal:Wintersport/Index/Kopf {Bot: Aktualisierung} $nhead / minor]

foreach basiscat [scat Wintersport 14] {
	lappend lbasiscat [format {[[:Kategorie:%s]]} $basiscat]
}
set header1 "Es wurden [tdot [expr $lenArtikel + $lenVorlage + $lenDatei]] Einträge in [tdot $lenKategorie] Kategorien gefunden."
set header2 "'''Basiskategorien''': [join $lbasiscat {, }]"
lappend lcatid 2754729 {*}[dcat listid Wintersport 14]
set cid 2754729
proc subcat {i cid} {
	global db
	set lc0 [mysqlsel $db "
		select cl_from
		from categorylinks join page on page_id = cl_from
		where cl_to = (
			select page_title
			from page
			where page_id = $cid and page_namespace = 14
		) and page_namespace = 14
	;" -flatlist]
	mysqlreceive $db "
		select page_id, page_title, cat_pages
		from page join category on cat_title = page_title
		where page_id in ([join $lc0 ,]) and page_namespace = 14
		order by page_title
	;" {cid pt cp} {
		set pt [sql -> $pt]
		lappend lpt $cid [
			format {%s [[:Kategorie:%s|%s]] (%s)} [string repeat # $i] $pt $pt $cp
		]
	}
	return $lpt
}
proc step {i l} {
	foreach {id line} $l {
		global lcatid lres l$i
		catch {
			set nl {}
			foreach [list cid$i res$i] [subcat $i $id] {
				if {[subst $[subst cid$i]] ni $lcatid} {
					regexp -- {(#{1,15}) (\[\[.*?\]\])} [subst $[subst res$i]] -- rexi rexres
					lappend nl "$rexi ''($rexres)''"
					continue
				}
				lremove lcatid [subst $[subst cid$i]]
				lappend nl [subst $[subst res$i]]
				lappend l$i [subst $[subst cid$i]] [subst $[subst res$i]]
			}
			set nl [join [list [list $line] $nl]]
			lrepl lres $line $nl
		}
	}
	set lres [string map [list "{{" "{" "}}" "}" " \}" " "] $lres]
}
set db [get_db dewiki]
foreach {cid res} [subcat 1 $cid] {
	if {$cid ni $lcatid} {continue}
	lremove lcatid $cid
	lappend lres $res
	lappend l1 $cid $res
}
for {set step 2} {$step <= 15} {incr step} {
	catch {step $step [subst $[subst l[expr $step - 1]]]}
}
set conts [conts t {Portal:Wintersport/Index/Baum Wintersport} x]
regsub -line -- {^Es wurden.*$} $conts $header1 conts
regsub -line -- {^'''Basiskategorien.*$} $conts $header2 conts
regsub -- {#.*} $conts [join $lres \n] res
puts [edit {Portal:Wintersport/Index/Baum Wintersport} {Bot: Aktualisierung Kategorienbaum Wintersport} $res / minor]
mysqlclose $db

