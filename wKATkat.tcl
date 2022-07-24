#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

#exit

catch {if {[exec pgrep -cxu taxonbot wkat.tcl] > 1} {exit}}

set editafter 1

source api.tcl ; set lang dea ; source langwiki.tcl ; #set token [login $wiki]

if $argv {set test 1} else {set test 0}

set qsp Wikipedia:Qualitätssicherung/[
	string trim [clock format [clock seconds] -format {%e. %B %Y} -timezone :Europe/Berlin -locale de]
]
set t3 [clock format [clock add [clock seconds]  -3 hours] -format %Y%m%d%H%M%S]
set td [clock format [clock add [clock seconds] -27 hours] -format %Y%m%d%H%M%S]

set db [get_db dewiki]
mysqlreceive $db "
	select rc_title
	from recentchanges, page
	where page_title = rc_title and rc_timestamp > $td and rc_timestamp < $t3 and rc_namespace = 0 and rc_type in (0,1) and page_namespace = 0 and page_is_redirect = 0
	group by rc_title
;" rct {
	lappend lrct '[sql <- $rct]'
}
mysqlclose $db

# Kategorie-Check
#mysqlreceive $db "
#	select page_title
#	from page, categorylinks
#	where page_namespace = 14 and cl_from = page_id and cl_to = 'Kategorie:Versteckt'
#;" pt {
#	lappend hidden '[sql <- $pt]'
#}
set db [get_db dewiki]
mysqlreceive $db "
	select page_title
	from page e
	where e.page_title in ([join $lrct ,]) and e.page_title not in (
		select page_title
		from page c
		left join categorylinks d on d.cl_from = c.page_id
		where c.page_title in ([join $lrct ,]) and c.page_namespace = 0 and c.page_is_redirect = 0 and d.cl_to not in (
			select page_title
			from page a, categorylinks b
			where a.page_namespace = 14 and b.cl_from = a.page_id and b.cl_to = 'Kategorie:Versteckt'
		)
	)
	and e.page_namespace = 0 and e.page_is_redirect = 0
	order by page_title
;" pt {
	lappend lpt '[sql <- $pt]'
}
mysqlclose $db

set db [get_db dewiki]
mysqlreceive $db "
	select rc_title, rc_timestamp
	from recentchanges
	where rc_title in ([join $lpt ,]) and rc_type in (0,1)
;" {rct rcts} {
	dict lappend drc $rct $rcts
}
mysqlclose $db

set bkl [dcat list Begriffsklärung 0]

foreach {rct lrcts} $drc {
set rct {Dennis Klapschus}
	if {![missing $rct] && [set lr [lindex $lrcts end]] < $t3} {
		set rctconts [conts t $rct x]
		if ![regexp -- {\{\{QS|\{\{Intensivtherapie|\{\{Projekt:Country|\{\{Lösch|\{\{LK|\{\{URV} $rctconts] {
			lassign {} qsframe qsblock lplt ll lit clit rlpt1 rlpt2 lpt senrex ctempl mppv lrvid
			puts "\n\n--------\n$rct: $lr"
			set pcat [pagecat $rct]
			set qsframe "\{\{subst:QS"
			# Kategorien fehlen
			if {[string first :Kategorie: $rctconts] > -1} {
				append qsframe {|Kategorien ausgeblendet}
				lappend qsblock {Kategorien ausgeblendet}
			} else {
				append qsframe {|Kategorien fehlen}
				lappend qsblock {Kategorien fehlen}
			}
			foreach cat $pcat {
				if [missing $cat] {
					append qsframe {|nicht existente Kategorien}
					lappend qsblock {in nicht existente Kategorien einsortiert}
					break
				}
			}
			# Personendaten fehlen
			if {[regexp -- {\* \d{1,2}\. } [string map {[ {} ] {}} $rctconts]] && ![matchtemplate $rct Vorlage:Personendaten]} {
				append qsframe {, {{Vorlage|Personendaten}} fehlt}
				lappend qsblock {Vorlage {{Vorlage|Personendaten}} fehlt}
			}
			# externe Weblinks im Text
			regexp -- {(.*Weblinks)?.*} [string map {{ } {}} $rctconts] full cut
			if [empty cut] {set searchframe $full} else {set searchframe $cut}
			regsub -all -- {<ref.*?(</ref>|/>)} $searchframe {} searchframe
			if [regexp -all -line -- {[^>=:.]\[http} $searchframe] {
				append qsframe {, externe Weblinks im Text}
				lappend qsblock {externe Weblinks im Text}
			}
			# Links auf Begriffsklärungsseiten
			set db [get_db dewiki]
			mysqlreceive $db "
				select pl_title
				from pagelinks, page
				where page_id = pl_from and pl_from_namespace = 0 and pl_namespace = 0 and page_title = '[sql <- $rct]' and page_namespace = 0
			;" {plt} {
				if {$plt in $bkl} {
					lappend lplt $plt
				}
			}
			mysqlclose $db
			puts $lplt
			if ![empty lplt] {
				append qsframe {, Links auf BKS}
				lappend qsblock "Links auf Begriffsklärungsseiten vorhanden: \[\[$lplt\]\]"
			}
			# defekter Dateilink
			if {{Kategorie:Wikipedia:Defekter Dateilink} in $pcat} {
				append qsframe {, defekte Dateilinks}
				lappend qsblock {defekte Dateilinks}
			}
			# verwaiste Seiten
			set lpt {}
			set db [get_db dewiki]
			mysqlreceive $db "
				select page_title
				from page, pagelinks
				where pl_from = page_id and page_namespace = 0 and pl_from_namespace = 0 and pl_namespace = 0 and pl_title = '[sql <- $rct]'
			;" pt {
				lappend rlpt1 '[sql <- $pt]'
			}
			mysqlclose $db
			if ![empty rlpt1] {
				set db [get_db dewiki]
				mysqlreceive $db "
					select page_title
					from page
					where page_title in ([join $rlpt1 ,]) and page_namespace = 0 and page_is_redirect = 0
				;" pt {
					lappend rlpt2 [sql -> $pt]
				}
				mysqlclose $db
			}
			if ![empty rlpt2] {
				set exceptlist [dcat list Liste 0]
				foreach pt $rlpt2 {
					if {$pt ni $exceptlist} {
						lappend lpt $pt
					}
				}
			}
			if [empty lpt] {
				append qsframe {, Artikel verwaist}
				lappend qsblock {Artikel verwaist (kein Artikel verlinkt auf diese Seite)}
			}
#			if {[string first {Wikipedia:Redundanz } $pcat] > -1} {
#				append qsframe {, Redundanz mit anderen Artikeln}
#				lappend qsblock {Redundanz mit anderen Artikeln}
#			}
			# Kommafehler
#			if {[string first {, sowie} $rctconts] > -1} {
#				append qsframe {, Kommafehler}
#				lappend qsblock {Kommafehler im Text}
#			}
			# Syntaxkorrekturen
			if {		([regexp -all -- {== \n{0,0}} $rctconts] > 2 && [regexp -all -- {==\w} $rctconts] > 2)
					||	 [regexp -- {== ?<ref} $rctconts]
					||	 [regexp -- {== ?''} $rctconts]
					||	 [regexp -- {==  } $rctconts]
					||	 [regexp -line -- {^= } $rctconts]
					||	 [string first \n\n\n $rctconts] > -1
					||	 [regexp -- {<ref> } $rctconts]
					||	 [regexp -- { </ref>} $rctconts]
					||	 [regexp -- {†\d\d} $rctconts]
					||	 [regexp -- {(18|19|20)\d\d-\d\d} $rctconts]															} {
				append qsframe {, Syntaxkorrekturen notwendig}
				lappend qsblock {Syntaxkorrekturen notwendig}
			}
			if {([string first == $rctconts] == -1 && ![regexp -line -- {^= } $rctconts])} {
				append qsframe {, Textwüste}
				lappend qsblock {Textwüste (kaum Gliederung, Formatierung und/oder Wikilinks)}
			}
			# fehlender Einzelnachweisabschnitt
			if {		 [string first <ref $rctconts] > -1
					&& ([string first Einzelnachweise $rctconts] == -1 && [string first Quellen $rctconts] == -1)	} {
				append qsframe {, Syntaxkorrekturen notwendig}
				lappend qsblock {Einzelnachweisabschnitt fehlt}
			}
			# fehlerhafte Einzelnachweisformatierungen
			if {[regexp -all -- {date=(?!\d\d\d\d-\d\d-\d\d)} $rctconts] > 0} {
				append qsframe {, fehlerhafte Einzelnachweisformatierungen}
				lappend qsblock {fehlerhafte Einzelnachweisformatierungen}
			}
			# Website als Sammelwerk in der Literaturvorlage
			set lenrex [regexp -all -inline -- {\|Sammelwerk=.*?\|} [string map {{ } {}} $rctconts]]
			foreach enrex $lenrex {if [regexp -- {\.\w{2,4}\|$} $enrex] {lappend senrex $enrex}}
			if ![empty senrex] {
				append qsframe {, fehlerhafte Parameterwerte in Vorlagen}
				lappend qsblock "Website als Sammelwerk in Vorlage \{\{Vorlage|Literatur\}\}: $senrex"
			}
			# commons-Bilder vorhanden bei bilderlosem Artikel
			set lpt {}
			proc picselect it {
				if {		[string first Ambox $it] == -1
						&& [string first Arbcom $it] == -1
						&& [string first X_mark $it] == -1
						&& [string first Yes_check $it] == -1
						&& [string first Red_x $it] == -1
						&&	[string first flag $it] == -1
						&&	[string first map $it] == -1
						&& [string first Keeptidy $it] == -1
						&& [string first Mail-mark $it] == -1
						&& [string first Crystal_Clear_app $it] == -1
						&& [string first Open_book $it] == -1
						&& [string first puzzle $it] == -1
						&& [string first Symbol_list $it] == -1
						&& [string first Translation_Latin $it] == -1
						&& [string first Zh_conversion $it] == -1
						&& [regexp -all -nocase {folder} $it] == 0
						&& [string first Qsicon $it] == -1
						&& [string first Question $it] == -1
						&& [string first Increase $it] == -1
						&& [string first Commons $it] == -1		} {
					return 1
				} else {
					return 0
				}
			}
			set db [get_db dewiki]
			mysqlreceive $db "
				select il_to
				from imagelinks, page
				where page_id = il_from and page_title = '[sql <- $rct]' and page_namespace = 0
			;" {it} {
				if [picselect $it] {
					lappend lit $it
				}
			}
			mysqlclose $db
			if [empty lit] {
				set db [get_db dewiki]
				mysqlreceive $db "
					select ll_lang, ll_title
					from langlinks, page
					where page_id = ll_from and page_title = '[sql <- $rct]' and page_namespace = 0
				;" {lll llt} {
					lappend ll $lll '[sql <- [string map {Anexo: {}} $llt]]'
				}
				mysqlclose $db
				if ![empty ll] {
					foreach {lll llt} $ll {
						puts $lll
						puts $llt
						set db [get_db [string map {- _} $lll]wiki]
						mysqlreceive $db "
							select il_to
							from imagelinks, page
							where page_id = il_from and page_title = $llt and page_namespace in (0,104)
						;" {it} {
							lappend lit '[sql <- $it]'
						}
						mysqlclose $db
					}
					if ![empty lit] {
						while 1 {if [catch {set db [get_db commonswiki]}] {after 60000 ; continue} else {break}}
						set db [get_db dewiki]
						mysqlreceive $db "
							select page_title
							from page
							where page_title in ([join $lit ,]) and page_namespace = 6
						;" pt {
							if [picselect $pt] {
								lappend lpt \[\[:c:File:[sql -> $pt]\]\]
							}
						}
						mysqlclose $db
					}
					if ![empty lpt] {
						append qsframe {, bilderlos}
						lappend qsblock "eventuell commons-Bild verwendbar: [join $lpt {; }]"
					}
					set db [get_db commonswiki]
				}
			}
			# Commons-Link broken
			regexp -- {\{\{(Commonscat)\|(.*?)\}\}} $rctconts -- ctempl ctarget
			if ![empty ctempl] {
				set lang commons ; source langwiki.tcl ; #set token [login $wiki]
				if [missing Category:$ctarget] {
					append qsframe {, fehlerhafter Commons-Link}
					lappend qsblock {Ziel des Commons-Links nicht vorhanden}
				}
				set lang dea ; source langwiki.tcl ; #set token [login $wiki]
			}
			# Wikidata-Objektkennung fehlt
			set db [get_db dewiki]
			mysqlreceive $db "
				select pp_value
				from page_props, page
				where pp_page = page_id and pp_propname = 'wikibase_item' and page_title = '[sql <- $rct]' and page_namespace = 0
			;" {ppv} {
				set mppv $ppv
			}
			mysqlclose $db
			puts $mppv
			if [empty mppv] {
				append qsframe {, Wikidata-Objektkennung fehlt}
				lappend qsblock {Wikidata-Objektkennung fehlt}
			}
			append qsframe " ${~}\}\}\n\n"
			puts $pcat
			puts $qsframe
			puts $qsblock
if !$test {
#			set qsframe "\{\{subst:QS|Kategorien fehlen ${~}\}\}\n\n"
			set rct [sql -> $rct]
			puts [edit $rct "Bot: auf \[\[$qsp\]\] eingetragen" {} / prependtext $qsframe / minor]
			set db [get_db dewiki]
			mysqlreceive $db "
				select rev_id
				from revision, page
				where page_id = rev_page and page_title = '[sql <- $rct]' and page_namespace = 0
			;" rvid {
				lappend lrvid $rvid
			}
			mysqlclose $db
			set qsblock "# [join $qsblock "\n# "]\n\[\[Spezial:Diff/[lindex $lrvid end]/cur|Diff seit QS\]\]"
#			set qstext "<small>(Dieser Service wird derzeit noch ausgebaut ...)</small>\n$qsblock ${~}"
			puts [edit $qsp "Bot: + QS \[\[$rct\]\]" "$qsblock ${~}" / section new / sectiontitle "\[\[$rct\]\]"]
exit
}
		}
	}
}



#puts $pc
#puts [regexp -all -- {\{\}} $pc]
exit

set wKATkat [dict get [read [set f [open WORKLIST/@wkat.db r]]] wKATkat] ; close $f
foreach {pt lct} $wKATkat {
	if ![missing $pt] {
		if ![regexp -- {\{\{QS|\{\{Intensivtherapie|\{\{Projekt:Country|\{\{Lösch|\{\{LK} [conts t $pt x]] {lappend lpt $pt}
	}
}

puts $lpt\n\n

foreach rct $lrct {
	if {$rct in $lpt && {Kategorie:Wikipedia:In Bearbeitung} ni [pagecat $rct] && [string first {Liste der Tomatensorten/} $rct] == -1} {
		set lcat {}
		foreach cat [pagecat $rct] {
			if {$cat ni $hidden} {lappend lcat $rct}
		}
		if [empty lcat] {
puts \n$rct
			set qsframe "\{\{subst:QS|Kategorien fehlen ${~}\}\}\n\n"
			puts [edit $rct {Bot: QS eingeleitet} $qsframe[conts t $rct x] / minor]
			set qstext "\n\n== \[\[$rct\]\] ==\n<small>(Dieser Service wird derzeit noch ausgebaut ...)</small>\n# Kategorien fehlen\n${~}"
			puts [edit $qsp "Bot: + QS \[\[$rct\]\]" [conts t $qsp x]$qstext]
		}
	}
}

