#!/usr/bin/tclsh8.7
#exit

source api.tcl ; set lang d ; source langwiki.tcl ; set dtoken [login [set dwiki $wiki]]
source api.tcl ; set lang de ; source langwiki.tcl ; set btoken [login [set bwiki $wiki]]

#source library.tcl
#set db [get_db dewiki]

#package require http
#package require tls
#package require tdom

set cardomap https://denkmalliste.denkmalpflege.sachsen.de/CardoMap/Denkmalliste_Report.aspx?HIDA_Nr

set db [get_db dewiki]
set lt [mysqlsel $db {
	select tl_from from templatelinks
	where !tl_from_namespace and tl_namespace = 10
		and tl_title = 'Denkmalliste_Sachsen_Tabellenzeile'
;} -flatlist]
mysqlclose $db

foreach t $lt {
	set wiki $bwiki ; #set token $btoken
#	set ent Q48195078
	puts [page_title $t]
	lassign {} c gem lrex
	set c [conts id $t 2]
	set gem [lindex [split $c \n] 0 end-1]
	set gemplz 04179
	set vgem Leipzig
	set qvgem [get_q $vgem 0]
	set lrex [regexp -all -inline -- {\{\{Denkmalliste Sachsen Tabellenzeile.*?\n\}\}} $c]
	foreach rex $lrex {
		lassign {} ID Name Artikel Ortsteil Adresse NS EW Datierung Datierung-sort
		lassign {} Beschreibung Bild Commonscat Wikidata
		lassign {} ltxt kchar bauwerk bau adr ref claims
		lassign {} P18 P31 P149
		set drex [parse_templ $rex]
		dict with drex {
			if {$ID ne $argv} {continue}
			foreach key [dict keys $drex] {
				puts "$key: [set $key]"
			}
if {0 && $ID eq {09292237}} {
			catch {exec wget -O z-thomas.pdf -- $cardomap=09292237}
#			catch {exec wget -O z-thomas.pdf -- $cardomap=09272109}
#			set ref [format {-ref {P854 %s P813 %s}} $ref [utc ^ seconds {} %Y-%m-%d {}]]
#			set ref [format {-ref {P854 %s}} $cardomap=$ID]
puts $errorCode
puts $::errorCode
			exec pdftotext z-thomas.pdf
}
			read_file z-thomas.txt txt
			set stxt [split $txt \n]
			foreach val $stxt {
				if {[set tval [string trim $val]] ne {}} {
					lappend ltxt $tval
				}
			}
			set ltxt [lrange $ltxt [lsearch $ltxt Obj.-Dok.-Nr.] end]
			puts \n----\n$ltxt
			puts [llength $ltxt]
			foreach {key val} $ltxt {
				puts $key:$val
			}
			if {[string first Denkmaltext $ltxt] > -1} {
				set kchar [join [lrange $ltxt [
					expr [lsearch $ltxt Kurzcharakteristik] + 1
				] [
					expr [lsearch $ltxt Denkmaltext] - 1
				]]]
			} else {
				set kchar [join [lrange $ltxt [
					expr [lsearch $ltxt Kurzcharakteristik] + 1
				] [
					expr [lsearch $ltxt Datierung] - 1
				]]]
			}
			if {[lsearch $ltxt Bauwerksname] > -1} {
				set bauwerk [lindex $ltxt [expr [lsearch $ltxt Bauwerksname] + 1]]
			} else {
				set bauwerk {}
			}
#			set bau [string trim [regexp -inline -- {\(.*?\)} $Datierung] {([])}]
			set bau [string trim [join [regexp -inline -- {\(.*?\)} $Datierung]] {([])}]
			switch $bau {
				Doppelmietshaus		{set P31 Q105959504}
				Eisenbahnerwohnhaus	{set P31 Q11755880}
				Mietvilla				{set P31 Q106512886}
				Villa						{set P31 Q3950}
				Wohnblock				{set P31 Q105681016}
				Wohnhaus					{set P31 Q11755880}
			}
			set adr [string map {; ,} $Adresse]
			set ref [format {
				-ref {P854 %s P813 {{%s}}}
			} $cardomap=$ID [list [set date [utc ^ seconds {} +%Y-%m-%d {}]] 11]]
#			set ref [format {-ref {P854 %s}} $cardomap=$ID]

#			set baudat [lindex $ltxt [expr [lsearch $ltxt Datierung] + 1]]
#			set bau [string trim [lindex $baudat 1] ()]
#			set gem [string trim [lindex [split [lindex $ltxt [expr [lsearch $ltxt {Gem. * Fl-stck. * Flur}] + 1]] *] 0]]
#			set adr [string map {; ,} [lindex $ltxt [expr [lsearch $ltxt Anschrift] + 1]]]
#			set char [string trim [lindex [split [lindex $ltxt [expr [lsearch $ltxt Kurzcharakteristik] + 1]] {;}] 0]]
#			puts "\n----\n$bau, $adr, $gem"
#			lappend claims [format {P31 -new -datas {{-q %s %s} {-q Q19413851 %s}}} $P31 $ref $ref]
#			lappend claims [format {P31 -new -datas {{-q %s %s}}} $P31 $ref]

#if {$bau eq {Villa}} {set bau $bauwerk}
regsub -- {(\d)(-)(\d)} $kchar {\1–\3} kchar
set kchar [string map [list GeorgSchwarz Georg-Schwarz {, sowie} { sowie}] $kchar]
set Name [lindex [split $kchar {;}] 0]
if {[string first Gründerzeit $ltxt] > -1} {
	set P149 Q51879601
} elseif {[string first Landhausbau $ltxt] > -1 || [string first Landhausstil $ltxt] > -1} {
	set P149 Q2611710
}

#puts $ID:$txt
#puts bau:$bau:$P31
#puts :$bauwerk:
#puts "$bau, $adr, $gem"
#puts :$Name:
#puts :$kchar:

			input ent "\nQ: "
			if {[string first Q $ent] == -1} {set ent Q$ent}
			set wiki $dwiki ; #set token $dtoken
			set lp [d_get_lp $ent]

puts \n----\n
if ![empty bauwerk] {
	puts "labels: [set label "$bauwerk, $gem"] : $adr, $gem"
} else {
	puts "labels: [set label "$bau, $adr, $gem"] : $adr, $gem"
}
puts "descs: $Name"
if {"$bau, $adr, $gem" ne $label} {puts "aliases: $bau, $adr, $gem"}
puts "P17: Q183 [wb_get_label Q183 de]"
if ![empty Bild] {puts "P18: $Bild P18: [d_get_lq $ent P18]"}
puts "P31: $P31 [wb_get_label $P31 de] : Q19413851 [wb_get_label Q19413851 de]"
puts "P131: $qvgem [wb_get_label $qvgem de]"
if ![empty P149] {puts "P149: $P149 [wb_get_label $P149 de]"}
puts "P571: ${Datierung-sort}"
puts "P625: $NS:$EW"
puts "P1435: Q19413851 [wb_get_label Q19413851 de]"
puts "P1708: $ID : $kchar"
puts "P6375: $adr, $gemplz $gem"
gets stdin

			if ![empty bauwerk] {
				lappend claims [format {
					-p labels -q {de {%s} en {%s}}
				} $label "$adr, $gem"]
			} else {
				lappend claims [format {
					-p labels -q {de {%s} en {%s}}
				} $label "$adr, $gem"]
			}
			lappend claims [format {-p descs -q {de {%s}}} $Name]
			if {"$bau, $adr, $gem" ne $label} {
				lappend claims [format {-p aliases -q {%s}} [list de [list "$bau, $adr, $gem"]]]
			}
			if {[d_get_refdate $ent P17 Q183] ne $date} {
				lappend claims [format {
					-p P17 -datas {{-q %s -val Q183 %s}}
				} [expr {{P17} ni $lp ? "-new" : [d_get_lq $ent P17]}] $ref]
			}
			if {![empty Bild] && [join [d_get_lq $ent P18]] ne $Bild} {
				lappend claims [format {
					-p P18 -datas {{-q %s -val {%s}}}
				} [expr {{P18} ni $lp ? "-new" : [d_get_lq $ent P18]}] $Bild]
			}
			if {[d_get_refdate $ent P31 $P31] ne $date} {
				lappend claims [format {
					-p P31 -datas {{-q %s -val %s %s} {-q -new -val Q19413851 %s}}
				} [expr {{P31} ni $lp ? "-new" : [d_get_lq $ent P31]}] $P31 $ref $ref]
			}
			if {[d_get_refdate $ent P131 $qvgem] ne $date} {
				lappend claims [format {
					-p P131 -datas {{-q %s -val %s %s}}
				} [expr {{P131} ni $lp ? "-new" : [d_get_lq $ent P131]}] $qvgem $ref]
			}
			if {![empty P149] && [d_get_refdate $ent P149 $P149] ne $date} {
				lappend claims [format {
					-p P149 -datas {{-q %s -val %s %s}}
				} [expr {{P149} ni $lp ? "-new" : [d_get_lq $ent P149]}] $P149 $ref]
			}
			if {[d_get_refdate $ent P571 [list +${Datierung-sort}-00-00 9]] ne $date} {
				lappend claims [format {
					-p P571 -datas {{-q %s -val %s %s}}
				} [expr {{P571} ni $lp ? "-new" : [list [d_get_lq $ent P571]]}] [list "+${Datierung-sort}-00-00 9"] $ref]
			}
			if {[d_get_lq $ent P625] ne [list $NS $EW]} {
				lappend claims [format {
					-p P625 -datas {{-q %s -val {%s}}}
				} [expr {{P625} ni $lp ? "-new" : [list [d_get_lq $ent P625]]}] [list $NS $EW]]
			}
			if {[d_get_refdate $ent P1435 Q19413851] ne $date} {
				lappend claims [format {
					-p P1435 -datas {{-q %s -val Q19413851 %s}}
				} [expr {{P1435} ni $lp ? "-new" : [d_get_lq $ent P1435]}] $ref]
			}
			if {[d_get_refdate $ent P1708 $ID] ne $date} {
				lappend claims [format {
					-p P1708 -datas {{-q %s -val %s -qual {P1810 {{%s}}} %s}}
				} [expr {{P1708} ni $lp ? "-new" : "$ID"}] $ID $kchar $ref]
			}
			if {[d_get_refdate $ent P6375 "$adr, $gemplz $gem"] ne $date} {
				lappend claims [format {
					-p P6375 -datas {{-q %s -val {%s} %s}}
				} [expr {{P6375} ni $lp ? "-new" : [d_get_lq $ent P6375]}] [list "$adr, $gemplz $gem" de] $ref]
			}

#			lappend claims [format {P131 %s -datas {{-q %s %s}}} [get_q $gem 0] $qvgem $ref]

			puts "\n----\n$claims"
		}

if {$ID eq $argv} {



puts $claims
puts $ent
#exit

		d_edit_entity1 $ent $claims
#		set wiki $bwiki ; #set token $btoken
#		gets stdin
		exit
}
	}
exit
}




exit

proc d_edit_entity1 ent items {
	global wiki format token
	set ldata {}
	foreach item $items {
		dict with item {
			set p [lindex $item 0]
			set q [lindex $item 1]
			if {$p eq {labels}} {
				foreach {l label} $q {
					lappend llabel [format {{"language":"%s","value":"%s"}} $l $label]
				}
			} elseif {$p eq {descs}} {
				foreach {l desc} $q {
					lappend llabel [format {{"language":"%s","value":"%s"}} $l $desc]
				}
			}


#d_edit_entity Q105947973 $claims

exit

		source api.tcl ; set lang d ; source langwiki.tcl ; #set token [login $wiki]
		d_edit_entity Q105947973 $claims
		source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]
		gets stdin
	}
exit
}









exit

#set lt1 [dcat sqllist {Liste (Kulturdenkmale in Sachsen)} 0]
set db [get_db dewiki]
set lt [mysqlsel $db {
	select page_title
	from templatelinks join page on tl_from = page_id
	where !tl_from_namespace and tl_namespace = 10 and tl_title = 'Denkmalliste_Sachsen_Tabellenzeile' and !page_namespace
;} -flatlist]
mysqlclose $db

puts $lt











exit


if 0 {

set iz 0
foreach l $lt2 {
#	puts $l
	set sl [split [conts t $l x] \n]
	foreach s $sl {
		if {[regexp -all -nocase -- {[\w.,:;/()-–]datiert} $s] > 0 || [regexp -all -nocase -- {[.,:;/()-–] datiert} $s] > 0} {lappend ll $l}
	}
}
set sortll [lsort -unique $ll]
foreach l $sortll {
	puts $l
}
exit
#	set l {Liste_der_Kulturdenkmale_in_Zschäschütz}
	if {$l in {Liste_der_Kulturdenkmale_in_Freital Liste_der_Kulturdenkmale_in_Meißen_(linkselbisch) Liste_der_Kulturdenkmale_in_Meißen_(rechtselbisch)}} {continue}
	unset -nocomplain lz
	set sl [split [conts t $l x] \n]
	foreach s $sl {
		set s [string trim $s]
		if {$s eq "\{\{Denkmalliste Sachsen Tabellenzeile"} {
			incr iz
			continue
		}
		if $iz {
			if {$s eq "\}\}"} {
				decr iz
				lappend lz $z
				unset z
			} else {
				lappend z $s
			}
		}
	}
	unset -nocomplain az
	set = 0
	foreach osnak $lz {
		unset -nocomplain nz
		foreach snak $osnak {
			if {[string first | $snak] == 0} {
				set ssnak [split $snak =]
				set val [join [lrange $ssnak 1 end] =]
				set key [lindex [split [lindex $ssnak 0]] 0]
				if {[set lenkey [string length $key]] < 3} {puts Fehler:$snak ; gets stdin}
				set nsnak [string trim "$key[string repeat { } [expr 15 - $lenkey]] = [string trim $val]"]
				if {[string index $nsnak end] eq { }} {puts Fehler:$snak ; gets stdin}
				if {$nsnak ne $snak} {incr =}
			} else {
				set nsnak $snak
			}
			lappend nz $nsnak
		}
		lappend az [join $osnak \n] [join $nz \n]
	}
	puts $az\n$l\n${=}
#	exit


exit

foreach l $lt2 {
	set l {Liste_der_Kulturdenkmale_in_Connewitz,_A–K}
	set nline {}
	puts $l
	set lz [regexp -all -inline -- {\{\{Denkmalliste Sachsen Tabellenzeile.*\n\}\}} [conts t $l x]]
	foreach z [join $lz] {
puts 
gets stdin
		if {[string first {Denkmalliste Sachsen Tabellenzeile} $z] > -1} {
		lappend nline "\{\{Denkmalliste Sachsen Tabellenzeile"
		foreach line [regexp -all -inline -line -- {^[\{|\}].*$} $z] {
			set sline [split $line =]
			foreach key {ID Name {Adresse } Adresse-sort  NS EW {Datierung } Datierung-sort Beschreibung Bild Commonscat} {
				set val [expr 15 - [string length $key]]
				if {[string first $key [lindex $sline 0]] > -1} {
					set mline "|$key[string repeat { } $val]"
					append mline "= [set lid1 [string trimleft [lindex $sline 1]]]=[join [lrange $sline 2 end] =]"
					if [empty lid1] {
						set mline [string replace $mline end end {}]
						lappend nline [string trim $mline]
					} else {
						lappend nline [string trim $mline { =}]
					}
#					puts $line
#					puts $nline
					break
				}
			}
		}
		lappend nline \}\}
		}
	}
	foreach line $nline {
		puts $line
	}
if {[string first datiert $nline] > -1} {puts $l:Treffer ; gets stdin}
exit
}

exit

if 0 {
foreach l $lt2 {
	puts [incr i]:$l
}
foreach l $lt2 {
#	set l Liste_der_Kulturdenkmale_in_Dippoldiswalde
	set a [regexp -all -line -inline -- {^\|([ ]?Beschreibung.*?=.*)\n{1,2}(?!\|).*$} [set nconts [set conts [conts t $l x]]]]
#	puts [edit user:TaxonBot/Test {Bot: überflüssige Zeilenumbrüche entfernt} $nconts]
	puts [incr j]:$l
	foreach {b c} $a {
		if {[string trim [lindex [split $c =] 1]] eq {}} {
			puts $b:$c
			set nconts [string map [list $b [string map [list \n { }] $b]] $nconts]
		}
	}
	set nconts [string map [list {= |} "=\n|"] $nconts]
	if {$nconts ne $conts} {
		puts [edit $l {Bot: überflüssige Zeilenumbrüche entfernt} $nconts]
	}
#	if {$a > 0} {puts \a ; gets stdin}
}

}
}

set res {Name {} NS {} Datierung {} Beschreibung {}}
foreach t [lsort $lt2] {
puts $t
	set doublelinecheck [string map [list "\}\}\n\n\n\{\{" "\}\}\n\n\{\{"] [set dlcconts [conts t $t x]]]
#	if {$doublelinecheck ne $dlcconts} {
#		puts [edit $t {Bot: Leerzeilen-Check} $doublelinecheck / minor]
#	}
	lassign {} nlc lsline ID
	set lc [split $doublelinecheck \n]
	foreach c $lc {
		if {[string index [string trim $c] 0] eq {|}} {lappend nlc $c}
	}
	foreach c $nlc {
		lappend lsline [split $c |=]
	}
	set t "\[\[[sql -> $t]\]\]"
	foreach col $lsline {
#puts $col
		if {[string trim [lindex $col 1]] eq {ID}} {set ID [string trim [lindex $col 2]]}
#puts $ID
		if {[string trim [lindex $col 2]] eq {}} {
			switch [string trim [lindex $col 1]] {
				Name				{if {$t ni [dict get $res Name]} {dict lappend res Name $t} ; dict lappend dIDName $t $ID}
				NS					{if {$t ni [dict get $res NS]} {dict lappend res NS $t} ; dict lappend dIDNS $t $ID}
				Datierung		{if {$t ni [dict get $res Datierung]} {dict lappend res Datierung $t} ; dict lappend dIDDatierung $t $ID}
				Beschreibung	{if {$t ni [dict get $res Beschreibung]} {dict lappend res Beschreibung $t} ; dict lappend dIDBeschreibung $t $ID}
			}
		}
	}
	
if 0 {
		if {[string trim [lindex $col 1]] in {Name NS Datierung Beschreibung} && [string trim [lindex $col 2]] eq {}} {
			dict lappend res Name $col
		}
		
	
	if ![empty res] {lappend lt "\[\[[sql -> $t]\]\]"}
}
#if {[incr i] > 25} {break}

}
#puts $res
#puts $dIDName
#puts $dIDNS
#puts $dIDDatierung
#puts $dIDBeschreibung

foreach {key val} $res {
	lappend out "== $key =="
	set valout {}
	foreach value $val {
		lappend valout "|-\n| style=\"width: 20%;\" | $value || style=\"font-size: smaller; width: 80%;\" | [lsort -unique [join [string map {/ {}} [dict get [subst $[subst dID$key]] $value]]]]"
	}
	lappend out "\{| class=\"wikitable\" style=\"width: 100%;\"\n[join $valout \n]\n|\}"
}
#puts [join $out \n\n]
#puts [edit user:TaxonBot/Test {Bot: Aktualisierung} [join $out \n\n]]

puts [edit user:Z_thomas/Kulturdenkmallisten_Sachsen {Bot: Aktualisierung} [join $out \n\n]]

exit



set lpage {
Liste_der_Kulturdenkmale_in_Adorf/Vogtl.
Liste_der_Kulturdenkmale_in_Annaberg_(A–N)
Liste_der_Kulturdenkmale_in_Annaberg_(O–Z)
Liste_der_Kulturdenkmale_in_Arzberg_(Sachsen)
Liste_der_Kulturdenkmale_in_Augustusburg
Liste_der_Kulturdenkmale_in_Bad_Düben
Liste_der_Kulturdenkmale_in_Bad_Gottleuba-Berggießhübel
Liste_der_Kulturdenkmale_in_Bad_Lausick
Liste_der_Kulturdenkmale_in_Bad_Schandau
Liste_der_Kulturdenkmale_in_Bahretal
Liste_der_Kulturdenkmale_in_Bauda_(Großenhain)
Liste_der_Kulturdenkmale_in_Beiersdorf
Liste_der_Kulturdenkmale_in_Beilrode
Liste_der_Kulturdenkmale_in_Belgern-Schildau
Liste_der_Kulturdenkmale_in_Belgershain
Liste_der_Kulturdenkmale_in_Bernstadt_a._d._Eigen
Liste_der_Kulturdenkmale_in_Bertsdorf-Hörnitz
Liste_der_Kulturdenkmale_in_Biesnitz
Liste_der_Kulturdenkmale_in_Blankenhain_(Crimmitschau)
Liste_der_Kulturdenkmale_in_Bobritzsch-Hilbersdorf
Liste_der_Kulturdenkmale_in_Borna
Liste_der_Kulturdenkmale_in_Borsdorf
Liste_der_Kulturdenkmale_in_Brand-Erbisdorf
Liste_der_Kulturdenkmale_in_Brandis
Liste_der_Kulturdenkmale_in_Buchholz
Liste_der_Kulturdenkmale_in_Burgstädt
Liste_der_Kulturdenkmale_in_Burkhardtsdorf
Liste_der_Kulturdenkmale_in_Böhlen_(Sachsen)
Liste_der_Kulturdenkmale_in_Callenberg
Liste_der_Kulturdenkmale_in_Canitz_(Riesa)
Liste_der_Kulturdenkmale_in_Cannewitz_(Grimma)
Liste_der_Kulturdenkmale_in_Claußnitz
Liste_der_Kulturdenkmale_in_Colditz
Liste_der_Kulturdenkmale_in_Dahlen_(Sachsen)
Liste_der_Kulturdenkmale_in_Delitzsch
Liste_der_Kulturdenkmale_in_Dennheritz
Liste_der_Kulturdenkmale_in_Deutschenbora
Liste_der_Kulturdenkmale_in_Deutschneudorf
Liste_der_Kulturdenkmale_in_Diera-Zehren
Liste_der_Kulturdenkmale_in_Dippoldiswalde
Liste_der_Kulturdenkmale_in_Doberquitz
Liste_der_Kulturdenkmale_in_Dohna
Liste_der_Kulturdenkmale_in_Dorfchemnitz
Liste_der_Kulturdenkmale_in_Dorfhain
Liste_der_Kulturdenkmale_in_Drebach
Liste_der_Kulturdenkmale_in_Döbeln
Liste_der_Kulturdenkmale_in_Döben_(Grimma)
Liste_der_Kulturdenkmale_in_Dürrröhrsdorf-Dittersbach
Liste_der_Kulturdenkmale_in_Ebersbach/Sa._(M–Z)
Liste_der_Kulturdenkmale_in_Ebersbach_(bei_Großenhain)
Liste_der_Kulturdenkmale_in_Ehrenfriedersdorf
Liste_der_Kulturdenkmale_in_Eibenstock
Liste_der_Kulturdenkmale_in_Elsnig
Liste_der_Kulturdenkmale_in_Elterlein
Liste_der_Kulturdenkmale_in_Eppendorf
Liste_der_Kulturdenkmale_in_Erlau_(Sachsen)
Liste_der_Kulturdenkmale_in_Frankenau_(Mittweida)
Liste_der_Kulturdenkmale_in_Frankenberg/Sa.
Liste_der_Kulturdenkmale_in_Frankenhausen_(Crimmitschau)
Liste_der_Kulturdenkmale_in_Frauenstein_(Erzgebirge)
Liste_der_Kulturdenkmale_in_Fraureuth
Liste_der_Kulturdenkmale_in_Freiberg-Altstadt
Liste_der_Kulturdenkmale_in_Freiberg-Süd
Liste_der_Kulturdenkmale_in_Fremdiswalde
Liste_der_Kulturdenkmale_in_Frohburg
Liste_der_Kulturdenkmale_in_Gablenz_(Crimmitschau)
Liste_der_Kulturdenkmale_in_Geithain
Liste_der_Kulturdenkmale_in_Gelenau/Erzgeb.
Liste_der_Kulturdenkmale_in_Geringswalde
Liste_der_Kulturdenkmale_in_Gersdorf
Liste_der_Kulturdenkmale_in_Glashütte_(Sachsen)
Liste_der_Kulturdenkmale_in_Glaubitz
Liste_der_Kulturdenkmale_in_Glauchau
Liste_der_Kulturdenkmale_in_Gohrisch
Liste_der_Kulturdenkmale_in_Gornsdorf
Liste_der_Kulturdenkmale_in_Groitzsch
Liste_der_Kulturdenkmale_in_Großbothen
Liste_der_Kulturdenkmale_in_Großdubrau
Liste_der_Kulturdenkmale_in_Großhartmannsdorf
Liste_der_Kulturdenkmale_in_Großschirma
Liste_der_Kulturdenkmale_in_Großweitzschen
Liste_der_Kulturdenkmale_in_Grünhainichen
Liste_der_Kulturdenkmale_in_Görlitz-Altstadt,_A–K
Liste_der_Kulturdenkmale_in_Görlitz-Altstadt,_L–Z
Liste_der_Kulturdenkmale_in_Hainichen
Liste_der_Kulturdenkmale_in_Hartenstein_(Sachsen)
Liste_der_Kulturdenkmale_in_Hartha
Liste_der_Kulturdenkmale_in_Hartmannsdorf-Reichenau
Liste_der_Kulturdenkmale_in_Hartmannsdorf_(bei_Chemnitz)
Liste_der_Kulturdenkmale_in_Hartmannsdorf_bei_Kirchberg
Liste_der_Kulturdenkmale_in_Hausdorf_(Frankenberg)
Liste_der_Kulturdenkmale_in_Hermsdorf/Erzgeb.
Liste_der_Kulturdenkmale_in_Hinterhermsdorf
Liste_der_Kulturdenkmale_in_Hirschstein
Liste_der_Kulturdenkmale_in_Hohenstein-Ernstthal
Liste_der_Kulturdenkmale_in_Hohnstein_(Sächsische_Schweiz)
Liste_der_Kulturdenkmale_in_Innenstadt_(Görlitz),_A–Be
Liste_der_Kulturdenkmale_in_Innenstadt_(Görlitz),_Bi–D
Liste_der_Kulturdenkmale_in_Innenstadt_(Görlitz),_L–Q
Liste_der_Kulturdenkmale_in_Jahnsdorf/Erzgeb.
Liste_der_Kulturdenkmale_in_Jerisau_(Glauchau)
Liste_der_Kulturdenkmale_in_Klingenberg_(Sachsen)
Liste_der_Kulturdenkmale_in_Klingewalde
Liste_der_Kulturdenkmale_in_Klipphausen
Liste_der_Kulturdenkmale_in_Klosterbuch
Liste_der_Kulturdenkmale_in_Kohren-Sahlis
Liste_der_Kulturdenkmale_in_Kreischa
Liste_der_Kulturdenkmale_in_Kriebstein
Liste_der_Kulturdenkmale_in_Kunnerwitz
Liste_der_Kulturdenkmale_in_Käbschütztal
Liste_der_Kulturdenkmale_in_Königsfeld_(Sachsen)
Liste_der_Kulturdenkmale_in_Königshain-Wiederau
Liste_der_Kulturdenkmale_in_Königshufen
Liste_der_Kulturdenkmale_in_Königstein_(Sächsische_Schweiz)
Liste_der_Kulturdenkmale_in_Kössern
Liste_der_Kulturdenkmale_in_Lampertswalde
Liste_der_Kulturdenkmale_in_Langenbernsdorf
Liste_der_Kulturdenkmale_in_Langenhessen
Liste_der_Kulturdenkmale_in_Langenreinsdorf
Liste_der_Kulturdenkmale_in_Langenweißbach
Liste_der_Kulturdenkmale_in_Lauenhain_(Crimmitschau)
Liste_der_Kulturdenkmale_in_Lauenstein_(Altenberg)
Liste_der_Kulturdenkmale_in_Lauter-Bernsbach
Liste_der_Kulturdenkmale_in_Laußig
Liste_der_Kulturdenkmale_in_Leipnitz_(Grimma)
Liste_der_Kulturdenkmale_in_Leisnig
Liste_der_Kulturdenkmale_in_Leubnitz_(Werdau)
Liste_der_Kulturdenkmale_in_Leubsdorf_(Sachsen)
Liste_der_Kulturdenkmale_in_Lichtenau_(Sachsen)
Liste_der_Kulturdenkmale_in_Lichtenberg/Erzgeb.
Liste_der_Kulturdenkmale_in_Lichtenstein/Sa.
Liste_der_Kulturdenkmale_in_Lichtentanne
Liste_der_Kulturdenkmale_in_Liebschützberg
Liste_der_Kulturdenkmale_in_Liebstadt
Liste_der_Kulturdenkmale_in_Lommatzsch
Liste_der_Kulturdenkmale_in_Ludwigsdorf_(Görlitz)
Liste_der_Kulturdenkmale_in_Lunzenau
Liste_der_Kulturdenkmale_in_Löbnitz_(Sachsen)
Liste_der_Kulturdenkmale_in_Marienberg
Liste_der_Kulturdenkmale_in_Marienthal_West
Liste_der_Kulturdenkmale_in_Markranstädt
Liste_der_Kulturdenkmale_in_Meerane
Liste_der_Kulturdenkmale_in_Mitte-Nord
Liste_der_Kulturdenkmale_in_Mitte-West
Liste_der_Kulturdenkmale_in_Mittweida
Liste_der_Kulturdenkmale_in_Mochau
Liste_der_Kulturdenkmale_in_Mockrehna
Liste_der_Kulturdenkmale_in_Mosel_(Zwickau)
Liste_der_Kulturdenkmale_in_Mulda/Sa.
Liste_der_Kulturdenkmale_in_Muldenhammer
Liste_der_Kulturdenkmale_in_Mutzschen
Liste_der_Kulturdenkmale_in_Mylau
Liste_der_Kulturdenkmale_in_Mügeln
Liste_der_Kulturdenkmale_in_Müglitztal
Liste_der_Kulturdenkmale_in_Mühlau_(Sachsen)
Liste_der_Kulturdenkmale_in_Mühlbach_(Frankenberg)
Liste_der_Kulturdenkmale_in_Mülsen
Liste_der_Kulturdenkmale_in_Narsdorf
Liste_der_Kulturdenkmale_in_Naundorf_(Sachsen)
Liste_der_Kulturdenkmale_in_Neuensalz
Liste_der_Kulturdenkmale_in_Neugersdorf
Liste_der_Kulturdenkmale_in_Neustadt_in_Sachsen
Liste_der_Kulturdenkmale_in_Niederau
Liste_der_Kulturdenkmale_in_Niederfrohna
Liste_der_Kulturdenkmale_in_Niederlungwitz
Liste_der_Kulturdenkmale_in_Niederplanitz
Liste_der_Kulturdenkmale_in_Nikolaivorstadt
Liste_der_Kulturdenkmale_in_Nünchritz
Liste_der_Kulturdenkmale_in_Oberbärenburg
Liste_der_Kulturdenkmale_in_Oberlungwitz
Liste_der_Kulturdenkmale_in_Oberrothenbach
Liste_der_Kulturdenkmale_in_Oberschöna
Liste_der_Kulturdenkmale_in_Oberwiera
Liste_der_Kulturdenkmale_in_Oderwitz
Liste_der_Kulturdenkmale_in_Oederan
Liste_der_Kulturdenkmale_in_Olbernhau
Liste_der_Kulturdenkmale_in_Ostrau_(Sachsen)
Liste_der_Kulturdenkmale_in_Ottendorf_(Sebnitz)
Liste_der_Kulturdenkmale_in_Parthenstein
Liste_der_Kulturdenkmale_in_Pegau
Liste_der_Kulturdenkmale_in_Pockau-Lengefeld
Liste_der_Kulturdenkmale_in_Priestewitz
Liste_der_Kulturdenkmale_in_Rackwitz
Liste_der_Kulturdenkmale_in_Rechenberg-Bienenmühle
Liste_der_Kulturdenkmale_in_Regis-Breitingen
Liste_der_Kulturdenkmale_in_Reichenbach_im_Vogtland_(A–K)
Liste_der_Kulturdenkmale_in_Reichenbach_im_Vogtland_(L–Z)
Liste_der_Kulturdenkmale_in_Reinhardtsdorf-Schöna
Liste_der_Kulturdenkmale_in_Reinholdshain_(Glauchau)
Liste_der_Kulturdenkmale_in_Reinsberg_(Sachsen)
Liste_der_Kulturdenkmale_in_Reinsdorf_(Sachsen)
Liste_der_Kulturdenkmale_in_Remse
Liste_der_Kulturdenkmale_in_Riesa_(L–Z)
Liste_der_Kulturdenkmale_in_Rippien
Liste_der_Kulturdenkmale_in_Rochlitz
Liste_der_Kulturdenkmale_in_Rodewisch
Liste_der_Kulturdenkmale_in_Rosenthal-Bielatal
Liste_der_Kulturdenkmale_in_Rossau_(Sachsen)
Liste_der_Kulturdenkmale_in_Roßwein
Liste_der_Kulturdenkmale_in_Rudelswalde
Liste_der_Kulturdenkmale_in_Rötha
Liste_der_Kulturdenkmale_in_Sachsenburg_(Frankenberg)
Liste_der_Kulturdenkmale_in_Saupsdorf
Liste_der_Kulturdenkmale_in_Sayda
Liste_der_Kulturdenkmale_in_Schedewitz/Geinitzsiedlung
Liste_der_Kulturdenkmale_in_Schkeuditz
Liste_der_Kulturdenkmale_in_Schkortitz
Liste_der_Kulturdenkmale_in_Schneeberg_(Erzgebirge)
Liste_der_Kulturdenkmale_in_Schneppendorf
Liste_der_Kulturdenkmale_in_Schwarzenberg/Erzgeb.
Liste_der_Kulturdenkmale_in_Schönberg_(Sachsen)
Liste_der_Kulturdenkmale_in_Schönfeld_(Landkreis_Meißen)
Liste_der_Kulturdenkmale_in_Sebnitz
Liste_der_Kulturdenkmale_in_Seelitz
Liste_der_Kulturdenkmale_in_Sehmatal
Liste_der_Kulturdenkmale_in_St._Egidien
Liste_der_Kulturdenkmale_in_Stauchitz
Liste_der_Kulturdenkmale_in_Steinpleis
Liste_der_Kulturdenkmale_in_Stollberg/Erzgeb.
Liste_der_Kulturdenkmale_in_Stolpen
Liste_der_Kulturdenkmale_in_Strehla
Liste_der_Kulturdenkmale_in_Striegistal
Liste_der_Kulturdenkmale_in_Taura
Liste_der_Kulturdenkmale_in_Thallwitz
Liste_der_Kulturdenkmale_in_Tharandt
Liste_der_Kulturdenkmale_in_Thiendorf
Liste_der_Kulturdenkmale_in_Tirpersdorf
Liste_der_Kulturdenkmale_in_Torgau_(A–L)
Liste_der_Kulturdenkmale_in_Trebsen/Mulde
Liste_der_Kulturdenkmale_in_Treuen
Liste_der_Kulturdenkmale_in_Walda-Kleinthiemig
Liste_der_Kulturdenkmale_in_Waldenburg_(Sachsen)
Liste_der_Kulturdenkmale_in_Waldheim
Liste_der_Kulturdenkmale_in_Wechselburg
Liste_der_Kulturdenkmale_in_Weinhübel
Liste_der_Kulturdenkmale_in_Weischlitz
Liste_der_Kulturdenkmale_in_Weißenborn/Erzgeb.
Liste_der_Kulturdenkmale_in_Wermsdorf
Liste_der_Kulturdenkmale_in_Wernsdorf_(Glauchau)
Liste_der_Kulturdenkmale_in_Wildenfels
Liste_der_Kulturdenkmale_in_Wilsdruff
Liste_der_Kulturdenkmale_in_Wuhsen
Liste_der_Kulturdenkmale_in_Zeithain
Liste_der_Kulturdenkmale_in_Zettlitz
Liste_der_Kulturdenkmale_in_Ziegenhain_(Nossen)
Liste_der_Kulturdenkmale_in_Zinnwald-Georgenfeld
Liste_der_Kulturdenkmale_in_Zschaitz-Ottewig
Liste_der_Kulturdenkmale_in_Zschorlau
Liste_der_Kulturdenkmale_in_Zug_(Freiberg)
Liste_der_Kulturdenkmale_in_Zwenkau
Liste_der_Kulturdenkmale_in_der_Innenstadt_(Zwickau)
Liste_der_Umgebindehäuser_im_Landkreis_Sächsische_Schweiz-Osterzgebirge
Liste_der_technischen_Denkmale_im_Landkreis_Mittelsachsen
Liste_der_technischen_Denkmale_im_Landkreis_Sächsische_Schweiz-Osterzgebirge
}

puts $lpage
