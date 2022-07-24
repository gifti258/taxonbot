#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

#if {[exec pgrep -cxu taxonbot com.tcl] > 1} {exit}

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]
while 1 {if [catch {set db [get_db dewiki]}] {after 60000 ; continue} else {break}}

set aaaa 0
set db [read [set f [open WORKLIST/@com2 r]]] ; close $f
foreach line [split $db \n] {
	if {[lindex $line 0] eq {redirect}} {lappend lline $line}
}
puts $lline ; gets stdin

foreach item $lline {
	lassign [list [lindex $item 1] [lindex $item 2]] detitle comtitle
	if {$detitle in {LATAM_Ecuador Ignaz_Denner Bärenfell Chrysler_Airflow Entwicklungsgeschichte_der_norwegischen_Triebwagen Eurocopter_AS_350 Eye_Candy Falkplatz Hirschbach_(Isar) Franck_Cammas Hr._Ms._Karel_Doorman_(R81) Japanische_Buchstempel Jainistische_Kunst Japanisches_Eisenbahndenkmal Kirche_von_Dalhem Kirche_von_Hamra_(Gotland) Klarissenkloster Kopfband Koroni Kriegerdenkmal_1809 Kunigunde_von_Böhmen_(Äbtissin) Kunst_im_öffentlichen_Raum_in_Ludwigshafen Ledocarpaceae Liste_der_Municípios_in_Portugal Liste_der_Sakralbauten_in_Freiburg_im_Breisgau Liste_von_Bauten_der_Liechtensteiner_in_der_Kulturlandschaft_Lednice-Valtice Liste_von_Denkmalen,_Gedenksteinen_und_Steinkreuzen_in_Ruhland Liste_der_Straßen_und_Plätze_in_Berlin-Mahlsdorf Liste_von_Lokomotiven_und_Triebwagen_der_Norwegischen_Eisenbahnen Marienkirche_(Maria_Saal) Markgraf Methoni_(Messenien) Michelsberg_(Rumänien) Mitra Napier_&_Son Möllendorffstraße Oszillierender_Zylinder Panzerspähwagen_Sd.Kfz._231 Paul-Lincke-Ufer Piazza_del_Popolo RMS_Titanic SM_U_117 Sergei_Wiktorowitsch_Parschiwljuk Spittelmarkt Stillleben Ständerung_(Heraldik) Tschistyje_Prudy_(Kaliningrad) Wallfahrt_nach_Saintes-Maries-de-la-Mer Wappenbuch Wappenrolle Wehrmachtsgespann Yanggak}} {continue}
	if {$detitle ne {Wehringhausen} && !$aaaa} {continue} else {incr aaaa}
	set deconts [conts t $detitle x]
	set lang commons ; source langwiki.tcl ; #set token [login $wiki]
	set comconts [conts t $comtitle x]
	set lang de ; source langwiki.tcl ; #set token [login $wiki]
	puts \n$detitle:$comtitle
	foreach line [split $deconts \n] {
		if {[string first \{\{Commons $line] > -1 || [string first \{\{commons $line] > -1 || [string first \{\{Schwesterp $line] > -1} {
			incr z
			puts $line
			puts $comconts
			regexp -nocase -- {(redirect|cat|redir|-red|category) ??\| ?(?:1= ?)?(.*?)[|\}].*} $comconts -- -- target
			if ![exists target] {regexp -nocase -- {\[\[(.*?)[|\]]} $comconts -- target}
			set target [string trimleft $target :]
			puts $target
			if {[string first Category: $target] > -1} {set templ Commonscat} else {set templ Commons}
			set pline [split [join [join $line]] |*]
			if {[lindex $pline 0] eq {}} {set pline [lrange $pline 1 end]}
			set lp {}
			foreach p $pline {lappend lp [string trim $p]}
			if {[string first cat| $comconts] > -1 || [string first \{Cat $comconts] > -1 || [string first \[:Cat $comconts] > -1 || [string first \{cat $comconts] > -1 || [string first \[:cat $comconts] > -1} {
				set rtarget [string map {Category: {} category: {}} $target]
				if {[llength $lp] == 3} {
					if {[lindex $lp 2] eq $rtarget} {
						set res \{\{Commonscat|$rtarget\}\}
					} else {
						set res \{\{Commonscat|$rtarget|[lindex $lp 2]\}\}
					}
				} elseif {[sql -> $detitle] ne $rtarget} {
					set res \{\{Commonscat|$rtarget\}\}
				} else {
					set res \{\{Commonscat\}\}
				}
				puts $res
				puts [edit $detitle {Bot: Korrektur Commonslink} [string map [list $line $res] $deconts] / minor]
#				if {[incr zzz] < 10} {gets stdin}
			}
			unset target
		}
	}
	if {$z != 1} {puts Fehler ; gets stdin}
	set z 0
}
# !!! Ergebnis kann uppercase oder lowercase sein
exit

lassign {https://commons.wikimedia.org/wiki/ special:uploadwizard?} first1 first2
set f [open WORKLIST/@com1 w] ; close $f
mysqlreceive $db "
	select page_title, el_to
	from page, externallinks
	where el_from = page_id and page_namespace = 0
	order by page_title
;" {pt elt} {
	if {[string first $first1 $elt] > -1 && [string first $first2 [string tolower $elt]] == -1} {
		set cpage [string map {\\ {}} [dict values [
			regexp -inline -- {https://commons.wikimedia.org/wiki/(.*?)(?:\?uselang|$)} [urldecode $elt]
		]]]
		lappend lcpage $pt [lindex [split $cpage |] 0]
	}
}
foreach {pt cpage} $lcpage {
	set f [open WORKLIST/@com1 a]
	while 1 {
		try {
			if [missing $cpage] {puts $f "missing $pt $cpage" ; puts "missing $pt $cpage"}
			if [redirect $cpage] {puts $f "redirect $pt $cpage" ; puts "redirect $pt $cpage"}
			if [matchtemplate $cpage {Template:Category redirect}] {puts $f "redirect $pt $cpage" ; puts "redirect $pt $cpage"}
			break
		} on 1 {} {}
	}
	close $f
}
set com1 [read [set f [open WORKLIST/@com1 r]]] ; close $f
set f [open WORKLIST/@com2 w] ; puts $f $com1 ; close $f

