#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

source api.tcl ; set lang dea ; source langwiki.tcl ; #set token [login $wiki]

foreach {sport navi} {Eishockey Eishockey/Kaderwartung Fußball Fußball/Kader-Navigationsleisten} {
	unset -nocomplain ltt navinpage linkintempl dtempl
	lassign [list Vorlage:Navigationsleiste_$sport\kader "Wikipedia:WikiProjekt $navi" '' {} 0] sqltempl portal oldtempl lres cres
	set db [get_db dewiki]
	if {$sport eq {Fußball}} {
		mysqlreceive $db "
			select page_title
			from page join templatelinks on tl_from = page_id
			where page_namespace = 10 and tl_from_namespace = 10 and tl_namespace = 10 and tl_title = 'Veraltet'
		;" pt {
			lappend oldtempl '[sql <- $pt]'
		}
	}
	mysqlclose $db
	set db [get_db dewiki]
	mysqlreceive $db "
		select tl_title, page_title
		from templatelinks, page
		where page_id = tl_from and !tl_from_namespace and tl_namespace = 10 and tl_title in ([dcat sql $sqltempl 10]) and tl_title not in ([join $oldtempl {, }]) and !page_namespace and page_title in ([dcat sql Person_nach_Geschlecht 0])
	;" {tt pt} {
		lappend ltt '[sql <- $tt]'
		dict lappend navinpage [sql -> $tt] [sql -> $pt]
	}
	mysqlclose $db
	set ltt [lsort -unique $ltt]
	set db [get_db dewiki]
	mysqlreceive $db "
		select page_title, pl_title
		from page, pagelinks
		where page_id = pl_from and page_namespace = 10 and pl_from_namespace = 10 and !pl_namespace and page_title in ([join $ltt ,]) and pl_title in ([dcat sql Person_nach_Geschlecht 0])
	;" {pt plt} {
		dict lappend linkintempl [sql -> $pt] [sql -> $plt]
	}
	mysqlclose $db
	foreach {templ p} $navinpage {
		dict lappend dtempl $templ [lsort -unique $p]
	}
	foreach {templ p} $linkintempl {
		dict lappend dtempl $templ [lsort -unique $p]
	}
	foreach {templ d} $dtempl {
		set res {}
		foreach {navinpage linkintempl} $d {
			foreach p $navinpage {if {$p ni $linkintempl} {lappend res "\[\[:$p\]\] (ohne Eintrag)"}}
			foreach p $linkintempl {if {$p ni $navinpage} {lappend res "\[\[:$p\]\] (Navi fehlt)"}}
		}
		if ![empty res] {
			lappend lres "\{\{Vorlage|$templ\}\}<small> ([join $res {, }])</small>"
			incr cres
		}
	}
	set nportal [conts t $portal x]
	set branch ";\[\[Datei:Templatetools.svg|30x15px|text-unten|Vorlagenwartung|link=:Kategorie:Vorlagenwartung\]\]&nbsp;Vorlagenwartung<small> ([tdot $cres])</small>"
	set WORKLIST [string map {& {\&}} "\n$branch\n# [join $lres "\n# "]"]
	set nportal [string map {{\&} &} [regsub -- {(<!--MB-WORKLIST-->).*<!--MB-WORKLIST-->} $nportal \\1$WORKLIST\n\\1]]
#	puts $nportal ; gets stdin
	puts [edit $portal "Bot: WORKLIST: [tdot $cres]" $nportal / minor]
}
exit


