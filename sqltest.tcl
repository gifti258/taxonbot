#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

#set editafter 1

source api.tcl ; set lang kat ; source langwiki.tcl ; #set token [login $wiki]
set db [get_db dewiki]

set cat {Sport}
set nlpt [sql <- $cat]
set olpt '[sql <- $cat]'

while 1 {
lappend nlpt [set lpt [
	mysqlsel $db "
		select page_title
		from page, categorylinks
		where cl_from = page_id and page_namespace = 14 and cl_to in ([join $olpt ,])
	;" -list
]]
unset -nocomplain olpt
foreach pt $lpt {lappend olpt '[sql <- $pt]'}
if ![exists olpt] {break}

#puts $lpt

}
#puts $nlpt

puts [lsort -unique [join $nlpt]]

exit

while 1 {
	set i 0
	mysqlreceive $db "
		select page_title
		from page, categorylinks
		where cl_from = page_id and page_namespace = 14 and cl_to in ([join $oclt ,])
	;" clt {
		puts $i
		if !$i {incr i ; unset oclt}
		puts $clt
		lappend oclt '$clt'
		lappend nclt $clt
	}
	puts $oclt
	if ![exists oclt] {puts 1 ; break}
}
puts [lsort $nclt]

exit

lappend lpage [dcat list {Gmejna w Sakskej} 0]
lappend lpage [dcat list {Gmejna w Braniborskej} 0]
set lpage [join $lpage]

foreach page $lpage {
	unset -nocomplain conts nconts
	puts $page
	set conts [conts t $page x]
	set conts [split $conts \n]
	foreach line $conts {
		if {[string first |wokrjes= $line] > -1 || [string first |přestrjeń= $line] > -1 || [string first {| wokrjes=} $line] > -1 || [string first {| přestrjeń=} $line] > -1 || [string first {|wokrjes } $line] > -1 || [string first {|přestrjeń } $line] > -1 || [string first {| wokrjes } $line] > -1 || [string first {| přestrjeń } $line] > -1} {continue} else {lappend nconts $line}
	}
	set conts [join $nconts \n]
	puts [edit $page {Bot: removal of obsolete infobox parameters} $conts / minor]
#	"wokrjes=..." und "přestrjeń=...
}

exit

mysqlreceive $db "
	select page_title
	from page
	where page_namespace = 0
	order by page_title
;" pt {
	puts [incr i]:$pt
	set nconts [string map {Źórła Žórła wósmjoch wosmjoch šěsćoch šesćoch sydmjoch sedmjoch {w 18. lětstotku} {we 18. lětstotku}} [set oconts [conts t $pt x]]]
	if {$nconts ne $oconts} {
		puts [edit $pt {Bot: spell check} $nconts / minor]
		if {[incr z] < 5} {gets stdin}
	}
}

exit

set logpage [conts id 9886028 x]

mysqlreceive $db "
	select pl_title
	from page, pagelinks
	where pl_from = page_id and page_id = 9886028
;" pt {
	lappend lpt $pt
}

foreach pt $lpt {catch {
	set conts [conts t $pt x]
	set lsconts [split $conts \n]
	lassign {} lkat l2kat
	foreach sconts $lsconts {
		if {[string first \[\[Kategorie: $sconts] > -1} {
			lappend lkat $sconts
		}
	}
	set j1kat [join $lkat \n]
	foreach kat $lkat {
		if {$kat ni $l2kat} {
			lappend l2kat $kat
		}
	}
	set j2kat [join $l2kat \n]
	set nconts [string map [list $j1kat $j2kat] $conts]
	if {$nconts ne $conts} {
		puts $pt\n----\n$j1kat\n----\n$j2kat\n----
		puts [edit $pt {Bot: Kategorien-Fix} $nconts / minor]\n\n
	}
}}

exit

package require http
package require tls
package require tdom

set db [read [set f [open kfz.db r]]] ; close $f

foreach {o lr} $db {
	lassign {} lkey nr
	puts \n$o
	puts $lr
	foreach r $lr {
		lappend lkey [dict keys $r]
	}
	foreach r $lr {
		foreach key [join $lkey] {
			try {dict lappend nr $key [dict get $r $key]} on 1 {} {continue}
		}
	}
	puts $nr
	set lk [split [string map {{, } ,} [join [dict get $nr k] {, }]] ,]
	set nlk {}
	foreach k $lk {
		if {$k ni $nlk} {lappend nlk $k}
	}
	set nlk [join $nlk {, }]
	puts $nlk
	set kfz {}
	set no $o
	switch $no {
		 Ahrweiler						{set no {Bad Neuenahr-Ahrweiler}}
		 Altenkirchen 					{set no {Altenkirchen (Westerwald)}}
		 Annaberg						{set no  Annaberg-Buchholz}
		 Aschendorf-Hümmling			{set no  Papenburg}
		 Aue								{set no {Aue (Sachsen)}
		 Auerbach						{set no  Auerbach/Vogtl.}
		 Bartenstein					{set no  Bartoszyce}
		 Belgard							{set no  Białogard}
		{Bergheim (Erft)}				{set no  Bergheim}
		 Bernau							{set no {Bernau bei Berlin}}
		 Bernkastel						{set no  Bernkastel-Kues}
		{Beuthen in Oberschlesien}	{set no  Bytom}
		
	}
	regexp -- {Kfz-Kennzeichen.*?\n<td>(.*?)</td>} [getHTML https://de.wikipedia.org/wiki/[string map {{ } _} $no]] -- kfz
	if {$o eq {Altdamm}} {set kfz ZS}
	if [empty kfz] {lappend ekfz $o}
}
puts $ekfz

exit

proc sup {sup o k} {
#	if {$sup <= 10} {
		if {$sup == 3} {
			lappend elk [list 1 Bytom]
		} elseif {$sup == 9} {
			lappend elk [list 1 Piła]
		} elseif {$o eq {Frankfurt-Höchst}} {
			lappend elk [list 1 {Frankfurt am Main}]
			set sup 2
		} elseif {$o eq {Altdamm}} {
			lappend elk [list 1 Stettin]
			incr sup
		} else {
			lappend elk [list 1 $o]
		}
		switch $o {
			 Altdamm									{set no  Stettin}
			{Bad Berleburg}						{set no  Wittgenstein}
			{Bad Oldesloe}							{set no  Stormarn}
			{Bartenstein (Ostpreußen)}			{set no {Bartenstein (Ostpr.)}}
			{Beuthen in Oberschlesien}			{set no  Beuthen-Tarnowitz}
			 Borna/Sachsen							{set no  Borna}
			{Brake (Unterweser)}					{set no  Wesermarsch}
			{Calbe an der Saale}					{set no {Calbe a./S.}}
			{Cammin in Pommern}					{set no {Cammin i. Pom.}}
			{Falkenberg Oberschlesien}			{set no {Falkenberg O.S.}}
			{Freienwalde (Oder)}					{set no  Oberbarnim}
			{Freystadt in Niederschlesien}	{set no {Freystadt i. Niederschles.}}
			{Friedeberg Neumark}					{set no {Friedeberg Nm.}}
			 Gleiwitz								{set no  Tost-Gleiwitz}
			{Greifenberg in Pommern}			{set no {Greifenberg i. Pom.}}
			{Heide (Holstein)}					{set no  Norderdithmarschen}
			{Heppenheim (Bergstraße)}			{set no  Bergstraße}
			 Itzehoe									{set no  Steinburg}
			 Jever									{set no  Friesland}
			 Kolberg									{set no  Kolberg-Körlin}
			{Königsberg (Preußen)}				{set no  Samland}
			{Kreuzburg Oberschlesien}			{set no {Kreuzburg O.S.}}
			{Landeshut in Schlesien}			{set no {Landeshut i. Schles.}}
			{Landsberg an der Warthe}			{set no {Landsberg (Warthe)}}
			 Mahlow									{set no  Teltow}
			 Meldorf									{set no  Süderdithmarschen}
			 Mühlhausen/Thüringen				{set no {Mühlhausen i. Th.}}
			 Niebüll									{set no  Südtondern}
			 Nordhorn								{set no {Grafschaft Bentheim}}
			 Otterndorf								{set no {Land Hadeln}}
			 Radebeul								{set no  Dresden}
			 Ratzeburg								{set no {Herzogtum Lauenburg}}
			 Reppen									{set no  Weststernberg}
			{Rosenberg Oberschlesien}			{set no {Rosenberg O.S.}}
			{Rothenburg an der Oder}			{set no {Grünberg i. Schles.}}
			{Rummelsburg in Pommern}			{set no {Rummelsburg i. Pom.}}
			 Salzbrunn								{set no  Waldenburg}
			 Tönning									{set no  Eiderstedt}
			 Westerstede							{set no  Ammerland}
			{Winsen (Luhe)}						{set no  Harburg}
			 default									{set no $o}
		}
		if ![missing "Landkreis $no"] {
			if {$o eq {Eisleben}} {
				lappend elk [list 3 {Mansfelder Seekreis}]
			} elseif {$o eq {Tilsit}} {
				lappend elk [list 3 {Landkreis Tilsit-Ragnit}]
			} elseif ![redirect "Landkreis $no"] {
				lappend elk [list 3 "Landkreis $no"]
			} else {
				lappend elk [list 3 [join [dict values [regexp -inline -- {\[\[(.*?)\]\]} [conts t "Landkreis $no" x]]]]]
			}
		} elseif {$o eq {Bad Homburg vor der Höhe}} {
			lappend elk [list 3 Obertaunuskreis]
		} elseif {$o eq {Bad Schwalbach}} {
			lappend elk [list 3 Untertaunuskreis]
		} elseif {$o eq {Diez}} {
			lappend elk [list 3 Unterlahnkreis]
		} elseif {$o eq {Erbach}} {
			lappend elk [list 3 Odenwaldkreis]
		} elseif {$o eq {Montabaur}} {
			lappend elk [list 3 Unterwesterwaldkreis]
		} elseif {$o eq {Rüdesheim am Rhein}} {
			lappend elk [list 3 Rheingaukreis]
		} elseif {$o eq {Schneidemühl}} {
			lappend elk [list 3 Netzekreis]
		} elseif {$o eq {Weilburg}} {
			lappend elk [list 3 {Landkreis Limburg-Weilburg}]
		} else {
			lappend elk [list 3 {}]
		}
		if {$o eq {Mühlhausen/Thüringen}} {set no Mühlhausen}
		if ![missing "Kreis $no"] {
			if ![redirect "Kreis $no"] {
				lappend elk [list 2 "Kreis $no"]
			} elseif {$o eq {Tilsit}} {
				lappend elk [list 2 "Landkreis Tilsit"]
			} else {
				lappend elk [list 2 [join [dict values [regexp -inline -- {\[\[(.*?)\]\]} [conts t "Kreis $no" x]]]]]
			}
		} elseif {$o eq {Bergisch Gladbach}} {
			lappend elk [list 2 {Rheinisch-Bergischer Kreis}]
		} elseif {$o eq {Frankfurt-Höchst}} {
			lappend elk [list 2 Main-Taunus-Kreis]
		} elseif {$o eq {Weilburg}} {
			lappend elk [list 2 Oberlahnkreis]
		} else {
			lappend elk [list 2 {}]
		}
		if ![missing "Amtshauptmannschaft $no"] {
			if ![redirect "Amtshauptmannschaft $no"] {
				lappend elk [list 4 "Amtshauptmannschaft $no"]
			} else {
				lappend elk [list 4 [join [dict values [regexp -inline -- {\[\[(.*?)\]\]} [conts t "Amtshauptmannschaft $no" x]]]]]
			}
		} else {
			lappend elk [list 4 {}]
		}
		set elk [join [lsort -unique $elk]]
		set k {}
		dict with elk {
			if $sup {
				lappend k \[\[$1|Stadtkreis\]\]
			}
			if ![empty 4] {
				lappend k \[\[$4|Amtshauptmannschaft\]\]
			}
			if {![empty 2] && ![empty 3]} {
				if {$2 eq $3} {
					lappend k \[\[$2|Landkreis\]\]
				} else {
					lappend k \[\[$3|Land\]\]\[\[$2|''kreis''\]\]
				}
			} elseif ![empty 2] {
				lappend k Land\[\[$2|''kreis''\]\]
			} elseif ![empty 3] {
				lappend k \[\[$3|Landkreis\]\]
			}
		}
		if {$o eq {Merseburg}} {
			set k "\[\[Saalkreis\]\], [join $k {, }]"
		} else {
			set k [join $k {, }]
		}
		puts $k
#	} else {
#	}
	return $k
}

set conts3 [regexp -all -inline -line -- {^.*?\[\[.*?\n.*?\n.*?\n.*?\n.*?$} [string map {_ {}} [conts id 4288518 13]]]
foreach r $conts3 {
	lassign {} sup o k
	set lterm [dict values [regexp -all -inline -- {\[\[(.*?)\]\]} $r]]
	foreach term $lterm {
		if {[string first {Landkreis } $term] > -1} {set sup 0 ; set o [string trim [string trimleft [lindex [split $term |] 0] Landkreis]]}
		if {[string first {Kreis } $term] > -1} {set sup 0 ; set o [string trim [string trimleft [lindex [split $term |] 0] Kreis]]}
		if {[string first {Kreisverwaltung} $r] > -1} {set sup 0 ; regexp -- {Kreisverwaltung in \[\[(.*?)[|#\]]} $r -- o ; break}
		if {[string first {Saalkreis} $r] > -1} {set sup 0 ; set o Merseburg ; break}
#		if {[string first {Main-Taunus-Kreis} $r] > -1} {set sup 0 ; set o Frankfurt-Höchst ; break}
		if {[string first {Kreisfreie Stadt} $term] > -1} {set sup 2 ; set o [lindex [split $term |] 0] ; break}
		if {[string first {Stadt-} $term] > -1} {set sup 2 ; set o [lindex [split $term |] 0] ; break}
		if {[string first {Stadtkreis} $term] > -1} {set sup 2 ; set o [lindex [split $term |] 0] ; break}
		if {[string first {Hansestadt} $term] > -1} {set sup 2 ; set o [lindex [split $term |] 0] ; break}
	}
	puts $sup:$o:$r
	set k [sup $sup $o $k]
	foreach {-- 2 3 4 5} [split [regsub -all -- {[A-ZÄÖÜ][a-zäöü]} $r {}] \n] {
		set 53 [regexp -all -inline -- {[A-ZÄÖÜ]{1,5}} $2]
		set 590 [regexp -all -inline -- {[A-ZÄÖÜ]{1,5}} $3]
		set 790 [regexp -all -inline -- {[A-ZÄÖÜ]{1,5}} $4]
		set 91 [regexp -all -inline -- {[A-ZÄÖÜ]{1,5}} $5]
	}
	dict lappend lr $o [list s $sup k $k 53 $53 590 $590 790 $790 91 $91]
}
set lr [lsort -stride 2 -index 0 $lr]
foreach {o r} $lr {
	puts $o\ $r
}



#exit

set conts2 [regexp -all -inline -line -- {^.*?\[\[.*?\n.*?\n.*?\n.*?$} [string map {_ {}} [conts id 4288518 4]]]
foreach r [lrange $conts2 1 end] {
	incr extra
	lassign {} sup o k
	set lterm [dict values [regexp -all -inline -- {\[\[(.*?)\]\]} $r]]
	foreach term $lterm {
		if {[string first {Landkreis } $term] > -1} {set sup 0 ; set o [string trim [string trimleft [lindex [split $term |] 0] Landkreis]]}
		if {[string first {Kreis } $term] > -1} {set sup 0 ; set o [string trim [string trimleft [lindex [split $term |] 0] Kreis]]}
		if {[string first {Kreisverwaltung} $r] > -1} {set sup 0 ; regexp -- {Kreisverwaltung in \[\[(.*?)[|#\]]} $r -- o ; break}
		if {[string first {Odenwaldkreis} $r] > -1} {set sup 0 ; set o Erbach ; break}
		if {[string first {Main-Taunus-Kreis} $r] > -1} {set sup 0 ; set o Frankfurt-Höchst ; break}
		if {[string first {Kreisfreie Stadt} $term] > -1} {set sup 2 ; set o [lindex [split $term |] 0] ; break}
		if {[string first {Stadt-} $term] > -1} {set sup 2 ; set o [lindex [split $term |] 0] ; break}
		if {[string first {Stadtkreis} $term] > -1} {set sup 2 ; set o [lindex [split $term |] 0] ; break}
		if {[string first {Hansestadt} $term] > -1} {set sup 2 ; set o [lindex [split $term |] 0] ; break}
	}
	puts $sup:$o:$r
	set k [sup $sup $o $k]
	foreach {-- 2 3 4} [split [regsub -all -- {[A-ZÄÖÜ][a-zäöü]} $r {}] \n] {
		set 50 [regexp -all -inline -- {[A-ZÄÖÜ]{1,5}} $2]
		set 51 [regexp -all -inline -- {[A-ZÄÖÜ]{1,5}} $3]
		set 56 [regexp -all -inline -- {[A-ZÄÖÜ]{1,5}} $4]
	}
	dict lappend lr $o [list s $sup k $k 50 $51 51 $51 56 $56]
	if {$extra == 1} {
		set o Bremerhaven
		set sup 2
		set k {}
		set k [sup $sup $o $k]
		lassign {HB HB HB} 50 51 56
		dict lappend lr $o [list s $sup k $k 50 $51 51 $51 56 $56]
	}
}
set lr [lsort -stride 2 -index 0 $lr]
foreach {o r} $lr {
	puts $o\ $r
}



#exit

set l1 [regexp -all -inline -line {^\| .*$} [string map {{ || } § { ||} § {|| } § || §} [conts id 3412699 2]]]
foreach r $l1 {
	set sr [split $r §]
	set sup 0
	regexp -- {<sup>(.*?)<} [lindex $sr 0] -- sup
	set lk [lreverse [split [join [dict values [regexp -inline -- {\[\[(.*?)\]\]} [lindex $sr 0]]]] |]]
	lassign [list [lindex $lk 0] [lindex $lk 1] {} {}] o k
	set k [sup $sup $o $k]
	dict lappend lr $o [list s $sup k $k 50 [lindex $sr 1] 53 [lindex $sr 2] 91 [lindex $sr 3]]
}
set lr [lsort -stride 2 -index 0 $lr]
foreach {o r} $lr {
			puts \n$o\ $r
}

set f [open kfz.db w] ; puts $f $lr ; close $f

exit


set cat1 [scat {Grabbau in Ägypten} 0]
set cat2 [scat {Tal der Könige} 0]
puts $cat1
puts $cat2

foreach cat $cat1 {
	if {$cat in $cat2} {
		set conts [conts t $cat x]
		set conts [string map [list "\[\[Kategorie:Grabbau in Ägypten\]\]\n" {} "\[\[Kategorie:Tal der Könige\]\]\n" "\[\[Kategorie:Grab im Tal der Könige\]\]\n"] $conts]
		puts [edit $cat {Umkategorisierung nach [[WD:WikiProjekt Kategorien/Warteschlange#Von zwei Kategorien in eine andere|Diskussion]]} $conts / minor]
		gets stdin
	}
}




exit

mysqlreceive $db "
	select page_title
	from page, templatelinks
	where tl_from = page_id and page_title = 0 and tl_from_namespace = 0 and tl_namespace = 10 and tl_title = 'Review'
;" pt {
	lappend lpt [sql -> $pt]
}
puts $lpt
set oconts [conts id 7807931 x]
regexp -- {(\{\{!-.*?\}\})\}} $oconts -- otab
set lline [split $otab \n]
foreach {line1 line2 line3 line4 line5 line6 line7 line8} [lrange $lline 0 end-1] {
	lappend dtr [join [dict values [regexp -inline -- {\[\[(.*?)\]\]} $line3]]] [
		list line1 $line1 line2 $line2 line3 $line3 line4 $line4 line5 $line5 line6 $line6 line7 $line7 line8 $line8
	]
}
#foreach {trkey trval} $dtr {
#	dict with trval {
#		lappend lrvintab [join [dict values [regexp -inline -- {\[\[(.*?)\]\]} $line3]]]
#	}
#}
foreach {trkey trval} $dtr {
	dict with trval {
		if {$trkey in $lpt} {
			lappend drvintab $trkey $trval
		}
	}
}
foreach pt $lpt {
	if {$pt ni [dict keys $drvintab]} {lappend lnewrev $pt}
}
foreach newrev $lnewrev {
	lassign {0 {}} br revgrv
	cont {revs {
		foreach revision [page $revs revisions] {
			dict with revision {
				set grv [join [dict values [regexp -inline -- {\{\{Review\|(\w{1,2})\}\}} ${*}]]]
				if ![empty grv] {
					lassign [list $revid $timestamp] revrevid revtimestamp
					if [empty revgrv] {set revgrv $grv}
				} else {
					lappend drvintab $newrev [
						set revtimestamp [utc -> $revtimestamp %Y-%m-%dT%TZ %Y-%m-%d {}]
						list line1 {{{!-}}} line2 "\{\{!\}\} \[\[Spezial:Permalink/$revrevid|$revtimestamp\]\]" line3 "\{\{!\}\} \[\[$newrev\]\]" line4 "\{\{!\}\} \[\[WP:RV$revgrv\#$newrev|RV$revgrv\]\]" line5 {{{!}}} line6 {{{!}}} line7 {{{!}}} line8 {{{!}}}
					]
					incr br
				}
			}
		}
		if $br {break}
	}} {*}$query / prop revisions / titles $newrev / rvprop ids|timestamp|content / rvlimit 1 / utf8 1
}

foreach {1 2} $drvintab {
	puts [incr zzz]:$1\n$2
}
exit

set otab [string map [list {\n} ¶ \\ {}] [regexp -inline -- {\{\{!-.*?\}\}\}} $oconts]]
puts $otab

set lline [split $otab ¶]
foreach line $lline {
	puts $line
}

exit

set hidden [
   join [
      mysqlsel $db "
         select page_title
         from page, categorylinks
         where page_namespace = 14 and cl_from = page_id and cl_to = 'Kategorie:Versteckt'
      ;" -list
   ]
]

puts [llength $hidden]

mysqlreceive $db "
select page_title
from page, categorylinks
where page_namespace = 14 and cl_from = page_id and cl_to = 'Kategorie:Versteckt'
;" pt {lappend lct $pt}

puts [llength $lct]

puts [llength [sscat Kategorie:Versteckt 14]]
#puts [sscat Kategorie:Versteckt 14]


mysqlreceive $db "
   select page_title, cl_to
   from page
   left join categorylinks on cl_from = page_id
   where page_namespace = 0 and page_is_redirect = 0 and cl_to not in ([sscat Kategorie:Versteckt 14])
   order by page_title
;" {pt cl} {
puts $pt:$cl
#   if {$cl in $hidden} {set cl {}}
#   dict lappend lwKAT $pt $cl
}
puts [llength $lwKAT]
exit

foreach {pt cl} $lwKAT {
   foreach item $cl {
      if {$item eq {}} {lremove cl $item}
   }
   if {$cl eq {}} {lappend nlwKAT $pt}
}

puts [llength $nlwKAT]

exit

mysqlreceive $db "
select rev_timestamp, page_title, rev_page, rev_comment, rev_parent_id
from revision, page
where page_id = rev_page and rev_timestamp >= 20170329220000 and rev_timestamp < 20170330220000 and page_namespace = 0 and page_is_redirect = 0 and rev_parent_id = 0
;" {rvts pt rvp rvc rvpid} {
puts $rvts:$pt:$rvp:$rvc:$rvpid
}
puts "[clock format [clock seconds] -format %T]: komplett"

exit



mysqlreceive $db "
select rev_timestamp, rev_page, rev_comment
from revision
where rev_timestamp >= 20170329220000 and rev_timestamp < 20170330220000 and rev_comment like '% verschob die Seite %'
;" {revts revp revc} {
puts $revts:$revp:$revc
}
puts "[clock format [clock seconds] -format %T]: komplett"

exit

mysqlreceive $db "
select log_type, log_action, log_title, log_page, log_params
from logging
where log_timestamp >= 20170329220000 and log_timestamp < 20170330220000 and log_namespace = 0 and log_type = 'move'
;" {lt la lt lp lc} {
puts $lt:$la:$lt:$lp:$lc
}

exit
}

mysqlreceive $db "
select rc_title, rc_timestamp, page_id, rc_log_type, rc_log_action, rc_logid, rc_comment, rc_params
from recentchanges, page
where page_title = rc_title and rc_timestamp >= 20170329220000 and rc_timestamp < 20170330220000 and rc_namespace  and page_namespace in (0,2) and (rc_type = 1 or rc_log_type = 'move')
;" {rct rcts pgid rclt rcla rcl rcc rcp} {
puts $rct:$rcts:$pgid:$rclt:$rcla:$rcl:$rcc:$rcp
}



exit


set	 ipt		[dcat sql Abkürzung 0]
append ipt	 " [dcat sql Begriffsklärung 0]"
append ipt 	 " [dcat sql Liste 0]"
append ipt 	 " [dcat sql Personenname 0]"
append ipt 	 " [dcat sql Wikipedia:Falschschreibung 0]"
append ipt 	 " [dcat sql Wikipedia:Liste 0]"
append ipt 	 " [dcat sql Wikipedia:Obsolete_Schreibung 0]"

foreach 1 [lrange [dict values [regexp -all -inline -- {\[\[(.*?)\]\]} [conts t {Benutzer:MerlBot/Verwaiste Artikel} x]]] 2 end] {lappend slink $1}
puts $slink

foreach 2 $slink {
	set 3 [get [post $wiki {*}$query / list backlinks / bltitle $2 / blnamespace 0 / blfilterredir nonredirects / bllimit 2500 / blredirect] query backlinks]
	if {[string first redirlinks $3] > -1} {
#		puts \n$2:
		set ltitle {}
		foreach 4 $3 {
			catch {
				foreach 5 [dict get $4 redirlinks] {
					set 6 [dict get $5 title]
					if {$6 ne $2 && $6 ni $ipt} {
						lappend ltitle $6
					}
				}
			}
		}
		if ![empty ltitle] {
			lappend 7 $2
		}
	}
}
foreach 8 $slink {
	if {$8 ni $7} {
		lappend 9 $8
	}
}
puts $9
puts "[clock format [clock seconds] -format %T]: komplett"
exit

 mysqlreceive $db "select page_title, pl_title from page, pagelinks where pl_from = page_id and page_namespace = 0 and page_is_redirect = 1 and pl_from_namespace = 0 and pl_namespace = 0 and pl_title in ([join $slink ,]);" {pt plt} {lappend r1 $pt}
 
 mysqlreceive $db "select page_title, pl_title from page, pagelinks where pl_from = page_id and page_namespace = 0 and page_is_redirect = 0 and pl_from_namespace = 0 and pl_namespace = 0 and pl_title in ([join $r1 ,]);" {pt plt} {puts $pt:$plt}


set ipt [dcat sql Abkürzung 0]
append ipt ,[dcat sql Begriffsklärung 0]
append ipt ,[dcat sql Liste 0]
append ipt ,[dcat sql Personenname 0]
append ipt ,[dcat sql Wikipedia:Falschschreibung 0]
append ipt ,[dcat sql Wikipedia:Liste 0]
append ipt ,[dcat sql Wikipedia:Obsolete_Schreibung 0]
mysqlreceive $db "
select page_title
from page
where page_title not in ($ipt) and page_namespace = 0
;" pt1 {
lappend lpt1 $pt1
}
puts "[clock format [clock seconds] -format %T]: komplett"
foreach pt1 $lpt1 {
lassign {} pt plt
mysqlreceive $db "
select pl_title
from pagelinks
where pl_namespace = 0 and pl_from = '[sql <- $pt1]' and pl_from_namespace = 0 and pl_title not in ($ipt) and pl_title not in (
select page_title
from page a
where a.page_namespace = 0 and a.page_is_redirect = 1
)
;" plt {
puts $pt1:$plt
#gets stdin
}
}
#puts $lpt
#puts [llength $lpt]
puts "[clock format [clock seconds] -format %T]: komplett"

exit

foreach p106 [string map {Q {}} [get [post $wiki {*}$format / action wbgetclaims / entity Q1138235] claims P106]] {
	lappend lp106 [dict get $p106 mainsnak datavalue value id]
}

set lttp106 {}

	mysqlreceive $db "
		select term_text
		from wb_terms
		where term_entity_id in ([join $lp106 ,]) and term_language ='de' and term_type = 'label'
	;" tt {
		puts $tt
		lappend lttp106 [sql -> $tt]in
	}
	puts $lttp106
set tt [join $ltt {, }]
if ![empty tt] {puts ($tt)}

exit

		where term_entity_id = [dict get $p106 mainsnak datavalue value id] and term_language = 'de' and term_type = 'label'


mysqlreceive $db "
	select ips_item_id, ips_site_id, ips_site_page
	from wb_items_per_site
	where ips_item_id = 23042593
;} {1 2 3} {
	puts $1:$2:$3
}

exit

mysqlreceive $db "
	select page_title
	from page, templatelinks
	where tl_from = page_id and page_namespace in (2,3) and tl_from_namespace in (2,3) and tl_namespace = 10 and tl_title like 'Gesperrter_Benutzer'
	order by page_title
;" pt {
	lappend lpt '[sql <- $pt]/%'
}
set lpt [lsort -unique $lpt]
foreach pt $lpt {
	mysqlreceive $db "
		select page_title
		from page
		where page_namespace = 2 and page_title like $pt
		order by page_title
	;" spt {
		if {[string first ArchivBot $spt] == -1} {
			lappend lspt "\[\[Benutzer:[sql -> $spt]\]\]"
		}
	}
	mysqlreceive $db "
		select page_title
		from page
		where page_namespace = 3 and page_title like $pt
		order by page_title
	;" spt {
		if {[string first Archiv $spt] == -1} {
			lappend lspt "\[\[Benutzer Diskussion:[sql -> $spt]\]\]"
		}
	}
}
puts [edit {user:TaxonBot/Unterseiten gesperrter Benutzer} {Bot: Listenerstellung} "# [join $lspt "\n# "]"]
exit

set ppv {}
mysqlreceive $db "
select pp_value
from page_props, page
where pp_page = page_id and pp_propname = 'wikibase_item' and page_title = 'Codex_Argenteu' and page_namespace = 0
;" {ppv} {puts $ppv}
puts $ppv

exit

lassign {Vorlage:Navigationsleiste_Eishockeykader {Wikipedia:WikiProjekt Eishockey/Kaderwartung}} sqltempl portal
#lassign {Vorlage:Navigationsleiste_Fußballkader {Wikipedia:WikiProjekt Fußball/Kader-Navigationsleisten}} sqltempl portal
mysqlreceive $db "
select tl_title, page_title
from templatelinks, page
where page_id = tl_from and tl_from_namespace = 0 and tl_namespace = 10 and tl_title in ([dcat sql $sqltempl 10]) and page_namespace = 0 and page_title in ([dcat sql Person_nach_Geschlecht 0])
;" {tt pt} {
lappend ltt '[sql <- $tt]'
dict lappend navinpage [sql -> $tt] [sql -> $pt]
}
set ltt [lsort -unique $ltt]
mysqlreceive $db "
select page_title, pl_title
from page, pagelinks
where page_id = pl_from and page_namespace = 10 and pl_from_namespace = 10 and pl_namespace = 0 and page_title in ([join $ltt ,]) and pl_title in ([dcat sql Person_nach_Geschlecht 0])
;" {pt plt} {
dict lappend linkintempl [sql -> $pt] [sql -> $plt]
}
foreach {templ p} $navinpage {
	dict lappend dtempl $templ [lsort -unique $p]
}
puts --------
puts --------
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
puts $nportal ; gets stdin
puts [edit $portal "Bot: WORKLIST: [tdot $cres]" $nportal / minor]
exit

mysqlreceive $db "
	select count(page_id)
	from page b
	where b.page_namespace = 0 and b.page_id in (
		select page_id
		from page a, imagelinks
		where il_from = a.page_id and a.page_namespace = 0 and il_from_namespace = 0
		group by a.page_id
	)
;" pt {
	puts $pt
}

exit

mysqlreceive $db "
	select page_title, (
		select count((
			select page_id
			from page a
			where il_to = a.page_title and a.page_namespace = 0
		))
		from imagelinks
		where il_to = b.page_title and b.page_namespace = 0 and il_from_namespace = 0
	) as c
	from page b
	where b.page_namespace = 0
;" {pt c} {
	puts $pt:$c
}

exit

set exclude "'Liste',[dcat sql Liste 14],[dcat sql Personenname 14],'Abkürzung','Begriffsklärung','Wikipedia:Falschschreibung','Wikipedia:Liste','Wikipedia:Liste_erstellt_mit_Wikidata','Wikipedia:Obsolete_Schreibung'"
mysqlreceive $db "
	select page_title, cl_to, (
		select count((
			select page_id
			from page a
			where pl_from = a.page_id and a.page_namespace = 0 and a.page_is_redirect = 0
		))
		from pagelinks
		where pl_title = f.page_title and f.page_namespace = 0 and pl_from_namespace = 0 and pl_namespace = 0
	) as e
	from page f, categorylinks g
	where g.cl_from = f.page_id and f.page_id not in (
		select page_id
		from page c, categorylinks d
		where d.cl_from = c.page_id and c.page_namespace = 0 and d.cl_to in ($exclude)
	) and f.page_namespace = 0 and f.page_is_redirect = 0
	having e = 0
	order by page_title
;" {pt ct e} {
	dict lappend lpt [sql -> $pt] Kategorie:[sql -> $ct]
}
set f [open wVSkat1 w] ; puts $f $lpt ; close $f
puts "[clock format [clock seconds] -format %T]: komplett"

exit

mysqlreceive $db "
	select page_title
	from page b
	where b.page_namespace = 0 and b.page_id not in (
		select page_id
		from page a, pagelinks
		where a.page_id = pl_from and a.page_namespace = 0 and pl_from_namespace = 0 and pl_namespace = 0
	)
;" pt {
	puts $pt
}
puts "[clock format [clock seconds] -format %T]: komplett"

exit

mysqlreceive $db "
      SELECT page_title, page_id, (
         SELECT COUNT((
            SELECT page_id
            FROM page X
            WHERE X.page_id = P.pl_from AND X.page_namespace = 0
         ))
         FROM pagelinks P
         WHERE P.pl_title = A.page_title AND P.pl_namespace = 0 AND P.pl_from_namespace = 0
      ) AS pl_field
      FROM page A
      WHERE A.page_namespace = 0 AND A.page_is_redirect = 0
      HAVING pl_field = 0
;"


exit

set l [read [set f [open out r]]] ; close $f
foreach {man lurl} $l {
	lassign {} sort gender
	if {{Kategorie:Mann} in [pagecat $man]} {
		set gender männlich
	} elseif {{Kategorie:Frau} in [pagecat $man]} {
		set gender weiblich
	}
	regexp -line -- {\{\{(SORTIERUNG: ?|DEFAULTSORT: ?)(.*?)\}\}} [conts t $man x] -- -- sort
	lappend lman $sort $man $gender $lurl
}
set lman [lsort -stride 4 $lman]
foreach {sort man gender lurl} $lman {
	set nlurl {}
	foreach url $lurl {
		lappend nlurl "\[https://[string map {http:// {} https:// {}} $url] $url\]"
	}
	lappend tman "|[incr i]\n|\[\[$man\]\]\n|$gender\n|[join $nlurl {<br />}]"
}
set tab "\{| class=\"wikitable sortable\"
!lfd.
!Lemma
!Geschlecht
!Links
|-
[join $tman \n|-\n]
|\}"
puts [edit Benutzer:Wikijunkie/data.fis-ski {Bot: Tabellenwunsch} $tab]
exit

mysqlreceive $db "
	select page_title, el_to
	from page b, categorylinks, externallinks
	where cl_from = b.page_id and el_from = b.page_id and b.page_namespace = 0 and b.page_id not in (
		select page_id
		from page a, templatelinks
		where tl_from = a.page_id and a.page_namespace = 0 and tl_from_namespace = 0 and tl_namespace = 10 and tl_title = 'FISDB'
	) and cl_to in ('Mann','Frau') and el_to like '%data.fis-ski%'
;" {pt et} {
	dict lappend lpet [sql -> $pt] $et
}
set f [open out w] ; puts $f [lsort -stride 2 $lpet] ; close $f
exit

mysqlreceive $db "
	select page_title
	from (
		select page_title, page_id
		from page, templatelinks
		where tl_from = page_id and page_namespace = 0 and tl_from_namespace = 0 and tl_namespace = 10 and tl_title = 'FISDB'
	) a, categorylinks
	where cl_from = a.page_id and cl_to in ('Frau','Mann')
;" pt {
	puts $pt
}



exit
set lpt 'Person_nach_Tätigkeit'
mysqlreceive $db "
	select page_title
	from page, categorylinks
	where page_id = cl_from and page_namespace = 14 and cl_to in ([join $lpt ,])
	group by page_title
;" pt {
	lappend lpt '[sql <- $pt]'
}
for {set x 1} {$x <= 13} {incr x} {
mysqlreceive $db "
	select page_title
	from page, categorylinks
	where page_id = cl_from and page_namespace = 14 and cl_to in ([join $lpt ,])
	group by page_title
;" pt {
	lappend lpt '[sql <- $pt]'
}
set lpt [lsort -unique $lpt]
}
mysqlreceive $db "
	select page_title
	from page, categorylinks
	where page_id = cl_from and page_namespace = 14 and cl_to in ([join $lpt ,])
	group by page_title
;" pt {
	lappend slpt Kategorie:[sql -> $pt]
}
puts $slpt
puts [llength $slpt]
set f [open apokat w] ; puts $f $slpt ; close $f









exit

set st				[scat Person_nach_Tätigkeit_und_Staat 14]
foreach 1 $st {
	if {[string first {Person (} $1] > -1} {
		lappend all [dcat list $1 14]
	}
}

puts [join $all]
set f [open apo5 w] ; puts $f [join $all] ; close $f

exit
#lappend all $gew $gen $gei $gae $f $enz $ent $ei $do $de $br $bi $bet $bea $au $ar $akti $akte $ag $re $ch $st
lappend all $ja $fr

puts [join $all]



exit

set om				[dcat list Ombudsmann 14]
set ns				[dcat list NS-Lagerpersonal 14]
set na				[dcat list Nachrichtensprecher 14]
set mu				[dcat list Musikdirektor 14]
set moder			[dcat list Moderator 14]
set model			[dcat list Model 14]
set mi				[dcat list Missionar 14]
set mae				[dcat list Mäzen 14]
set mar				[dcat list Marschall 14]
set man				[dcat list Manager 14]
set maf				[dcat list Mafioso 14]
set le				[dcat list Lehrer 14]
set landw			[dcat list Landwirt 14]
set lands			[dcat list Landschaftsarchitekt 14]
set ky				[dcat list Kynologe 14]
set kue				[dcat list Künstler 14]
set kom				[dcat list Kommunikationstrainer 14]
set kol				[dcat list Kolonialist 14]
set koc				[dcat list Koch 14]
set ka				[dcat list Kapellmeister 14]
set ju				[dcat list Jurist 14]
set jo				[dcat list Journalist 14]
set i					[dcat list Ingenieur,_Erfinder,_Konstrukteur 14]
set ho				[dcat list Hochschullehrer 14]
set herr				[dcat list Herrscher 14]
set hera				[dcat list Herausgeber 14]
set ha				[dcat list Handwerker 14]

lappend all $om $ns $na $mu $moder $model $mi $mae $mar $man $maf $le $landw $lands $ky $kue $kom $kol $koc $ka $ju $jo $i $ho $herr $hera $ha

puts [join $all]

set f [open apo2 w] ; puts $f [join $all] ; close $f


exit

set z     			[dcat list Zöllner 14]
set wis   			[dcat list Wissenschaftler 14]
set verle 			[dcat list Verleger 14]
set vera  			[dcat list Vanstalter_(Musik) 14]
set v					[dcat list V-Person 14]
set unternehmer	[dcat list Unternehmer 14]
set unternehmen	[dcat list Unternehmensberater 14]
set ue				[dcat list Übersetzer 14]
set ti				[dcat list Tierzüchter 14]
set te				[dcat list Techniker 14]
set st				[dcat list Stadionsprecher 14]
#set sp				[dcat list Sportler 14]
set soe				[dcat list Söldner 14]
set se				[dcat list Seefahrer 14]
set sc				[dcat list Schiedsrichter 14]
set sa				[dcat list Sammler 14]
set re 				[dcat list Redner 14]
set ra				[dcat list Raumfahrer 14]
set ps				[dcat list Psychotherapeut 14]
set pros				[dcat list Prostituierter 14]
set prop				[dcat list Prophet 14]
set pres				[dcat list Pressesprecher 14]
set pred				[dcat list Prediger 14]
set politis			[dcat list Politischer_Berater 14]
#set politik			[dcat list Politiker 14]
set pi				[dcat list Pilot 14]
set pe				[dcat list Personenschützer 14]
set par				[dcat list Parawissenschaftler 14]
set pae				[dcat list Pädagoge 14]

lappend all $z $wis $verle $vera $v $unternehmer $unternehmen $ue $ti $te $st $soe $se $sc $sa $re $ra $ps $pros $prop $pres $pred $politis $pi $pe $par $pae

puts [join $all]

set f [open apo3 w] ; puts $f [join $all] ; close $f

exit

set db [read [set f [open cat-db/P/Person_nach_Tätigkeit r]]] ; close $f
puts $db






exit

set orpt {'Region_Imboden' 'Rennersdorfer_Meilenstein' 'Casio_VL-1' 'Hochschule_RheinMain' 'New_Jersey' 'Falzbein' 'Horsd’œuvre' 'H1Z1' 'Mark_Stein_(Anglist)' 'Kurów_(Powiat_Puławski)' 'OPUS' 'Drum_național_2M' 'Aloys_Schreiber'}
mysqlreceive $db "
select page_title, il_to
from page, imagelinks
where il_from = page_id and page_title in ([join $orpt ,]) and page_namespace = 0 and il_from_namespace = 0 and il_to not in (
select page_title
from page
where page_namespace = 6
) and il_to not in (
select page_title
from commonswiki_p.page
where page_namespace = 6
)
order by page_title
;" {pt it} {
set demiss [missing File:$it]
set lang commons ; source langwiki.tcl ; #set token [login $wiki]
set commiss [missing File:$it]
set lang de ; source langwiki.tcl ; #set token [login $wiki]
if {$demiss && $commiss} {dict lappend lpt [sql -> $pt] \[\[:Datei:[sql -> $it]\]\]}
}
foreach {pt lit} $lpt {
lappend wDFblock "$pt<small> [join [lsort -unique $lit] { / }]</small>"
}
unset -nocomplain orpt lpt
puts $wDFblock
exit
mysqlreceive $db "
select page_title, cl_to
from page, categorylinks
where cl_from = page_id and page_namespace = 0 and page_title in ([join $lpt ,])
;" {pt ct} {
dict lappend wDFkat [sql -> $pt] Kategorie:[sql -> $ct]
}
puts $wDFkat
exit

mysqlreceive $db "
select page_title, il_to
from page, imagelinks
where il_from = page_id and page_namespace = 0 and il_from_namespace = 0 and il_to like '\"B%'
;" {pt it} {puts $pt:$it}


exit

set tab {        Atauro	9.274
            Beloi	1.678
                Adara	452
                Maquer	545
                Usubemaço	681
            Biqueli	2.076
                Ilicnamo	432
                Ilidua Douro	414
                Pala	856
                Uaro-Ana	374
            Macadade	1.632
                Anartuto	642
                Berau	448
                Bite	374
                Ili-Timur	168
            Maquili	2.062
                Fatulela	795
                Macelihu	612
                Mau-Laku	320
                Mau-Meta	335
            Vila Maumeta	1.826
                Eclae	734
                Ilimanu	257
                Ilitecaraquia	835
        Cristo Rei	62.848
            Balibar	1.708
                Fatu Loda	863
                Lacoto	254
                Lorico	44
                Tancae	547
            Becora	22.133
                Au-Hun	4.637
                Becusi Centro	4.995
                Becusi Craic	3.015
                Berebidu	159
                Caqueu Laran	2.143
                Carau Mate	740
                Clac Fuic	759
                Culau Laletec	1.522
                Darlau	14
                Maucocomate	1.414
                Malboro / Maliqueo	266
                Mota Ulun	1.456
                Quituto	304
                Romit	709
            Bidau Santana	6.482
                Bidau Mota Claran	508
                Manu Mata	2.023
                Sagrada Familia	2.276
                Toko Baru	1.675
            Camea	13.481
                Aidac Bihare	1.451
                Ailele Hun	1.927
                Ailoc Laran	2.929
                Bedois	671
                Buburlau	406
                Caisabe	218
                Fatuc Francisco	946
                Has Laran	1.839
                Lases	924
                Lenuc Hun	627
                Namalai	258
                Suco Laran	1.149
                Terminal	136
            Culu Hun	8.117
                Funu Hotu	918
                Lao Rai/Caregatiro	1.376
                Loe Laco	555
                Nato	769
                Soru Motu Badame	1.043
                Tane Muto	732
                Toko Baru Ii ( Antigo Asls)	2.724
            Hera	8.853
                Acanuno	2.562
                Ailoc Laran	1.691
                Hali Dolar	2.054
                Moris Foun	470
                Mota Quic	1.659
                Sucaer Laran	417
            Meti Aut	2.074
                17 De Abril	1.066
                Carungu Lau	662
                Fatu Cama	346
        Dom Aleixo	130.095
            Bairro Pite	34.993
                5 De Outubro	7.662
                Andevil	2.696
                Avança	1.778
                Bita-Ba	801
                Buca Fini	1.618
                Efaca	1.177
                Fatumeta	976
                Frecat	3.407
                Fuslam	623
                Haburas	947
                Hale Mutin	589
                Laloran	50
                Lau-Loran	902
                Licarapoma	249
                Lisbutac	1.163
                Manleu-Ana	280
                Moris Ba Dame	1.685
                Mundo Perdido	82
                Niken	1.599
                Rai Nain	1.391
                Ramelau	661
                Ribeira Maloa	593
                Rio De Janeiro	525
                Ruin Naclecar	517
                São Jose	59
                T.A.T	45
                Tane Timor	118
                Teki-Teki	321
                Terus Nanis	31
                Timor Cmanec	461
                We Dalac	1.691
                Xamatama	296
            Comoro	76.681
                12 De Outubro	14.025
                20 De Setembro	6.118
                30 De Agosto	8.797
                4 De Setembro	6.467
                7 De Dezembro	2.108
                Aimutin	1.886
                Anin Fuic	2.707
                Badiac	908
                Baya Leste	1.414
                Beto Tasi	1.510
                Fomento I	2.336
                Fomento Ii	2.044
                Fomento Iii	817
                Golgota	1.945
                Lemocari	2.015
                Loro Matan B. T	931
                Mane Mesac	843
                Mate Lahotu B.T	1.654
                Mauc	434
                Metin I	1.866
                Metin Ii	1.316
                Metin Iii	386
                Metin Iv	1.697
                Moris Foun	1.810
                Naroman B.T	934
                Posto Penal	759
                Ramelau Delta	969
                Rosario	1.720
                São José	1.973
                São Miguel	798
                Terra Santa	3.494
            Fatuhada	14.890
                Zero I	2.276
                Zero II	2.503
                Zero III	5.895
                Zero IV	2.181
                Zero V	2.035
            Kampung Alor	3.531
                Anin Fuic (Atarac Laran)	2.738
                Hamahon	307
                Rai Lacan	486
        Metinaro	5.654
            Duyung	4.021
                Benunuc	1.423
                Besahe	462
                Birahu Matan	312
                Has Laran	118
                Lebutun	115
                Mantelolao	63
                Manularan	220
                Manuleu	989
                Rai-Mean	11
                Sahan	308
            Sabuli	1.633
                Acadiru Laran	396
                Behauc	573
                Behoquir	291
                Sabuli	373
        Nain Feto	32.834
            Acadiru Hun	3.174
                Bedic	1.280
                Culuhun De Baixo	784
                Nu'U Badac	1.110
            Bemori	4.086
                Ailele Hun	483
                Baba Liu Rai Leste	943
                Baba Liu Rai Oeste	503
                Bemori Central	847
                Centro	761
                Has Laran	261
                My Friend	288
            Bidau Lecidere	1.208
                Capela	648
                Lecidere	560
            Gricenfor	948
                Bairo Central	242
                Bairo Dos Grilos	255
                Bairo Formosa	451
            Lahane Oriental	13.716
                Alcrin	1.988
                Becoe	1.479
                Deambata Bessi	1.119
                Deposito Penal	2.084
                Marabia	992
                Metin	1.373
                Monumento Calma	1.270
                Rai Mean	77
                Sare	363
                Suhu Rama	413
                Temporal	1.277
                Tuba Rai	732
                Vale De Lahane	549
            Santa Cruz	9.702
                12 De Novembro	1.490
                25 De Abril	844
                4 De Setembro	525
                7 De Dezembro	1.217
                Audian	1.734
                Baheda	415
                Donoge	515
                Loceneon	1.094
                Moris Foun	983
                Mura	885
        Vera Cruz	36.574
            Caicoli	5.067
                Centro Da Unidade	598
                De 12 Divino	1.813
                Foho Rai Boot	1.438
                Sacoco	354
                Tahu Laran	864
            Colmera	2.117
                Manu Fuic	1.512
                Rai Nain	605
            Dare	2.994
                Casnafar	117
                Coalau I	510
                Coalau Ii	282
                Fatu Naba	281
                Fila Beba Tua	325
                Fuguira / Bauloc	207
                Leilaus	208
                Lemorana	295
                Nahaec	511
                Suca Lau	258
            Lahane Ocidental	5.178
                Ainitas Hun	469
                Bedois	524
                Bela Vista	268
                Care Laran	368
                Correio	502
                Gomes Araujo	340
                Hospital Militar	541
                Mota Ulun	269
                Paiol	617
                Rai Cuac	479
                Teca Hudi Laran	801
            Mascarenhas	5.828
                Aldeia 03	720
                Alto Balide	2.137
                Alto P.M	665
                Baixo Balide	474
                Baixo P.M.	658
                Manu Cocorec	1.174
            Motael	5.039
                Bee Dalan	2.010
                Boa Morena	1.308
                Halibur	1.146
                Hura	481
                Lirio	94
            Vila Verde	10.351
                1 De Setembro	2.463
                Gideon	504
                Lemorai	1.926
                Mate Moris	802
                Mate Restu	761
                Matua	1.261
                Nopen	1.053
                Terus Nain	698
                Virgolosa	883
}
set tab [string map {. {} { -} - {- } - { - } -} $tab]
regsub -all -- {( {1,100}|\t{1,100})} $tab { } tab
regsub -all -- { (\d)} $tab \n\\1 tab
set tab [split $tab \n]
foreach t $tab {lappend l [string trim $t]}
set l [lrange $l 0 end-1]
puts $l
foreach {1 2} $l {dict lappend d $1 $2}
set d [string map {\{\{ \{ \}\} \}} $d]
set l [list Dili $d]
puts $l
set f [open suco.db a] ; puts $f $l ; close $f


exit

mysqlreceive $db "
select page_title, pl_title
from page b, categorylinks, pagelinks
where cl_from = b.page_id and cl_to = 'Frau' and pl_from = b.page_id and b.page_namespace = 0 and pl_from_namespace = 0 and pl_namespace = 0 and pl_title not in (
select page_title
from page a
where a.page_namespace = 0
)
order by page_title
;" {pt plt} {
puts "[sql -> $pt] : [sql -> $plt]"
}
puts "[clock format [clock seconds] -format %T]:wVFkat komplett"


exit

set lf [read [set f [open kanton/@list r]]] ; close $f
foreach {pg disp} $lf {
	set cpg [read [set f [open kanton/$pg r]]] ; close $f
	puts \n[incr i]:$pg
	puts [edit $pg {Bot: Gebietsreform frz. Kantone} $cpg]
#		puts $cpg
#		set f [open kanton/$pg w] ; puts $f [string map [list "\{\{ Verwaltungstabelle FR Inhalt | Art = g " "|-\n| bgcolor=\"#E7EDF5\""] $cpg] ; close $f
#		set f [open kanton/$pg w] ; puts $f "[string trim $cpg]\n\[\[Kategorie:Aufgelöst 2015\]\]" ; close $f
#		set f [open kanton/$pg w] ; puts $f [regsub -- {} [string trim $cpg] &|disparition=$disp\n] ; close $f
}




exit

#set prefix https://commons.wikimedia.org/wiki/
mysqlreceive $db "
	select page_title, el_to
	from page, externallinks
	where el_from = page_id and page_namespace = 0
	order by page_title
;" {pt elt} {
	if {[string first https://commons.wikimedia.org/wiki/ $elt] > -1 && [string first special:uploadwizard? [string tolower $elt]] == -1} {
		set cpage [string map {\\ {}} [dict values [
			regexp -inline -- {https://commons.wikimedia.org/wiki/(.*?)(?:\?uselang|$)} [urldecode $elt]
		]]]
		lappend lcpage $pt [lindex [split $cpage |] 0]
#		lappend lpt $pt [regsub -- "$prefix.*?\? $elt]
	}
}
foreach {pt cpage} $lcpage {
	set f [open com a]
	while 1 {
		try {
			if [missing $cpage] {puts $f m:$pt:$cpage ; puts m:$pt:$cpage}
			if [redirect $cpage] {puts $f r:$pt:$cpage ; puts r:$pt:$cpage}
			break
		} on 1 {} {}
	}
	close $f
}
exit

set dcat [dcat sql Karibik 14]

set ts 20170130
mysqlreceive $db "
	select page_id, rc_title, rc_this_oldid, rc_last_oldid, rc_user_text, rc_timestamp, rc_comment
	from recentchanges, page, categorylinks
	where page_title = rc_title and cl_from = page_id and page_namespace = 0 and rc_type in (0,1) and rc_namespace = 0 and rc_timestamp > 20170114000000 and rc_timestamp < 20170130130000 and cl_to in ([dcat sql Karibik 14])
	order by rc_timestamp;
;" {pageid title revid parentid user timestamp comment} {
	set timestamp [clock format [clock scan $timestamp -format %Y%m%d%H%M%S] -format %Y-%m-%dT%TZ]
	set rv "pageid $pageid ns 0 title [list [sql -> $title]] revid $revid parentid $parentid user [list $user] timestamp $timestamp comment [list $comment]"
	puts $rv
	set f [open rc/rc$ts\x.db a] ; puts $f $rv ; close $f
}

exit

if 0 {
set dcat [set lcat 'Person_nach_Todesjahrhundert']
while {$lcat ne {}} {
	set lcat1 {}
	mysqlreceive $db "
		select page_title
		from page, categorylinks
		where cl_from = page_id and page_namespace = 14 and cl_to in ([join $lcat ,])
	;" pt {
		set lcat {}
		lappend dcat '[sql <- $pt]'
		lappend lcat1 '[sql <- $pt]'
	}
	set lcat $lcat1
}
}

set l "\{| class=\"wikitable sortable\"\n! Radsportler !! LetztesUpdate"
mysqlreceive $db "
	select page_title
	from page, templatelinks
	where tl_from = page_id and page_namespace = 0 and tl_from_namespace = 0 and tl_namespace = 10 and tl_title = 'Infobox_Radsportler'
	order by page_title
;" pt {
	set lineconts [split [set oconts [conts t $pt x]] \n]]
	set date {}
#	if {$pt ne {Jochen_Danneberg}} {
		foreach line $lineconts {
			regexp -line -- {\|.*?LetztesUpdate.*?\=(.*)$} [string map [list "\}\}" {} \[\[ {} \]\] {}] $line] -- date
			set date [string trim $date]
			if ![empty date] {break}
		}
#	}
#	if {$date eq "\}\}"} {set date {}}
	if [empty date] {
		if [regexp -- {\| ?LetztesUpdate} $oconts] {set date {Parameter LetztesUpdate leer}} else {set date {Parameter LetztesUpdate fehlt}}
	}
	try {set dat [clock format [clock scan [string map {Jänner Januar} $date] -format {%e. %B %Y} -locale de] -format %Y-%m-%d]} on 1 {} {set dat { }}
	lappend b [sql -> $pt] "<!--$dat--> $date"
}
foreach {1 2} $b {
	if {[string first {<!-- -->} $2] == -1} {
		lappend b1 $1 $2
	} elseif {[string first Parameter $2] == -1} {
		lappend b2 $1 $2
	} else {
		lappend b3 $1 $2
	}
}
set b "[lsort -stride 2 -index 1 $b1] [lsort -stride 2 -index 1 $b2] [lsort -stride 2 -index 1 $b3]"
foreach {pt date} $b {append l "\n|-\n| \[\[:[sql -> $pt]\]\]\n| $date"}
regsub -all {<!--.*?--> } $l {} l

append l \n|\}

puts $l
puts [edit Benutzer:Wikijunkie/Arbeitsplatz/Radsportwartung/Update {Bot: Listenwunsch} $l]

exit


exit

mysqlreceive $db "
select page_title
from page b, templatelinks
where b.page_id = tl_from and tl_from_namespace = 0 and tl_namespace = 10 and tl_title not in (
select page_title
from page a
where a.page_namespace = 10
) and b.page_title in ('Westerlund_2','Türkei','Molybdofornacit') and b.page_namespace = 0
;" pt {
	lappend lpt $pt
}

puts $lpt
exit


#alle Vorlagen, auch rote, im 0:
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

puts $wVFkat
exit

mysqlreceive $db "
select page_title
from page
where page_title = 'Wartung-DC' and page_namespace = 10
;" pt {
puts $pt
}

exit

puts [lsort -unique $ltt]
foreach tt $ltt {
	if [missing Vorlage:[sql -> $tt]] {puts $tt ; lappend mtt $tt}
}
puts $mtt


exit

mysqlreceive $db "
select page_title, cl_to
from page, templatelinks, categorylinks
where tl_from = page_id and cl_from = page_id and page_namespace = 0 and tl_from_namespace = 0 and tl_namespace = 10 and tl_title in (
select page_title
from page a, categorylinks b
where b.cl_from = a.page_id and a.page_namespace = 10 and b.cl_to = 'Vorlage:Veraltet'
)
order by page_title
;" {pt ct} {
puts $pt:$ct
}



exit

if 0 {

while 1 {

set litem1 [insource {S\. [1-9][0-9]*- [1-9]/} 0]
#puts $litem1

set litem2 [insource {S\. [1-9][0-9]* -[1-9]/} 0]
#puts $litem2

#set litem3 [insource {S\. [1-9][0-9]*-[1-9]/} 0]
#puts $litem3

set litem4 [lsort -unique [join [list $litem1 $litem2]]]
#puts $litem4

#&nbsp; hinter S. !ampersand

foreach item $litem4 {
#	if {$item in {Betsingmesse Gemeinschaftsmesse}} {continue}
	puts \n[edit $item {Bot: Korrektur Halbgeviertstrich} [regsub -all -- {(S\.(&nbsp;| )\d{1,20})( -|- )(\d{1,20})} [conts t $item x] \\1–\\4] / minor]
#	if {[incr i] < 6} {gets stdin}
}

}












exit


#set a {Alte_Sprache Altsprachlicher_Unterricht Assistenz_(Behindertenhilfe) Außenhandelspolitik Bahnstrecke_Mannheim–Saarbrücken Bahnstrom Balkentheorie Bandpassunterabtastung Bewältigungsstrategie Biegefestigkeit Biegemoment Biegezugfestigkeit Blitzsynchronisation Blitzsynchronzeit Buchenbach Central_Tejo_(Arbeitsverhältnisse) Central_Tejo_(Funktionsbeschreibung) Central_Tejo_(Geschichte) Conversion-Tracking Datenbankindex Desktop-Virtualisierung Deutsche_Vereinigung_für_Posen_und_Pommerellen Deutschtumsbund_zur_Wahrung_der_Minderheitenrechte Dichtung Digitale_Katastralmappe Dirigieren Doppelschneckenextruder Ehrbarkeit Elternverband Elternverein Engineering-Data-Management Ethisches_Investment Extruderschnecke Extrusion_(Verfahrenstechnik) Führungsinformationssystem_(Wirtschaft) Ghetto_Theresienstadt Gilgit_(Landschaft) Glukosesirup Groupware Grundstücksdatenbank Grüne_Route Handelspolitik Heißluftgebläse Holzextrusion Hypoidantrieb Indexstruktur Informant Invertierte_Datei Jahreserstlinge Juristische_Sekunde KZ_Theresienstadt Kasse Kegelrad-Achsgetriebe Kettenschluss Klassische_Sprache Kleine_Festung_Theresienstadt Koextrusion Komplexität_(Informatik) Komplexitätstheorie Konversion_(Marketing) Landau-Symbole Lieferbereitschaft Liste_der_olympischen_Medaillengewinner_aus_Argentinien Lutherbuche_(Altenstein) Management-Informationssystem Modus_Barbara Multicodalität Multimodalität Museu_da_Electricidade_(Lissabon) Olympische_Geschichte_Argentiniens Persönliche_Assistenz Poesie Produktdatenmanagement Rote_Armee Sabrina_Setlur Sampling_(Musik) Scandferries Scandlines Schneckenwelle Social_Investment Social_Investor Sowjetarmee Soziales_Netzwerk_(Soziologie) Soziales_Netzwerk_(Systemtheorie) Stressmanagement Unbuntaufbau Unterfarbenreduktion Virtual_Desktop_Infrastructure Virtueller_Projektraum Volksgrenadier Volksgrenadier-Division Volltextindexierung Volltextrecherche Vías_Verdes Wagensteige}

#foreach 1 $a {
#	puts $1
#	puts [regexp -inline -- {\{\{Redundanztext.*?\d{4}.*?\|(.*?)\}\}} [conts t $1 x]]
#}


}


mysqlreceive $db "
	select page_title
	from page, categorylinks
	where page_id = cl_from and page_namespace = 0 and cl_to like 'Wikipedia:Redundanz\_%'
	order by page_title
;" pt {
	lappend lpt $pt
}

foreach pt $lpt {
	set scont [split [string map [list \n {} \{\{ \n\{\{ \}\} \}\}\n] [conts t $pt x]] \n]
	foreach line $scont {
		if {[string first Redundanztext $line] > -1} {break}
	}
	set reddict1 [split [join [regsub -all {\[\[.*?\]\]} [string map [list \n {} style= {}] [dict values [
		regexp -inline -- {\{\{Redundanztext ??\| ?(\d.*?)\}\}} $line
	]]] ...]] |=]
	unset -nocomplain lparam i
	if {$reddict1 eq {}} {
		set reddict2 [split [join [regsub -all {\[\[.*?\]\]} [string map [list \n {} style= {}] [dict values [
			regexp -inline -- {\{\{Redundanztext ??\|(.*?)\}\}} $line
		]]] ...]] |=]
		foreach param $reddict2 {
			lappend lparam [incr i] [string trim $param]
		}
		puts r2:$lparam
		lappend llparam $lparam
	} else {
		foreach param $reddict1 {
			lappend lparam [string trim $param]
		}
		puts r1:$lparam
		lappend llparam $lparam
	}
}
foreach lparam $llparam {
#	puts $lparam
	if {[string first { (CE} [lindex $lparam end]] > -1 && [lindex $lparam end-1] != 1} {set lparam [linsert $lparam end-1 1]}
	unset -nocomplain ltitle nltitle nlsqltitle
	lassign {} 3 4 5 6 7 8 9 10
	dict with lparam {
		lappend ltitle $3 $4 $5 $6 $7 $8 $9 $10
	}
	foreach title $ltitle {
		if {$title ne {}} {
			lappend nltitle [sql -> $title]
			lappend nlsqltitle '[sql <- $title]'
		}
	}
	set dltitle [set nltitle "ltitle [list $nltitle] cat {}"]
	mysqlreceive $db "
		select cl_to
		from categorylinks, page
		where page_id = cl_from and page_title in ([join $nlsqltitle ,]) and page_namespace = 0
	;" ct {
		dict lappend dltitle cat Kategorie:[sql -> $ct]
	}
	lappend ldltitle $dltitle
}
foreach dltitle [lsort -unique $ldltitle] {
	dict with dltitle {
		lappend wDWkat $ltitle $cat
	}
}

puts $wDWkat

exit

set lcat0 [set lcat 'Wikipedia:Staatslastig']
while {$lcat ne {}} {
   set lcat1 {}
   mysqlreceive $db "
      select page_title
      from page, categorylinks
      where cl_from = page_id and page_namespace = 14 and cl_to in ([join $lcat ,])
   ;" pt {
      set lcat {}
      lappend lpt '[sql <- $pt]'
      lappend lcat1 '[sql <- $pt]'
   }
   set lcat $lcat1
}
set lcat [lappend lpt [join $lcat0]]
mysqlreceive $db "
   select page_title, cl_to
   from (
      select page_id, page_title
      from page, categorylinks a
      where a.cl_from = page_id and page_namespace = 0 and a.cl_to in ([join $lcat ,])
   ) b, categorylinks c
   where c.cl_from = page_id
   order by page_title
;" {pt ct} {
   dict lappend wINTkat [sql -> $pt] Kategorie:[sql -> $ct]
}


exit

set lconts [lrange [split [conts id 9708855 x] \n] 4 end]
for {set x 0} {$x < 10} {incr x} {
	lappend litem [lindex $lconts [expr round(rand() * [llength $lconts])]]
}
set in {Auf diese Seiten verweisen entweder nur Seiten aus anderen Namensräumen, Weiterleitungsseiten, Begriffsklärungsseiten und ähnliche und gelten damit noch als verwaist. Hilf bitte mit, die Mängel zu beheben:}
puts [edit WP:LKH {Bot: Verwaiste Seiten} {} / appendtext "\n\n== Verwaiste Seiten ==\n$in\n[join [lsort -unique $litem] \n]\n\n${~}" / minor true / redirect true]

exit



set lcat0 [set lcat 'Wikipedia:Staatslastig']
while {$lcat ne {}} {
   set lcat1 {}
   mysqlreceive $db "
      select page_title
      from page, categorylinks
      where cl_from = page_id and page_namespace = 14 and cl_to in ([join $lcat ,])
   ;" pt {
      set lcat {}
      lappend lpt '[sql <- $pt]'
      lappend lcat1 '[sql <- $pt]'
   }
   set lcat $lcat1
}
set lcat [lappend lpt [join $lcat0]]
puts $lcat
mysqlreceive $db "
	select page_title, cl_to
	from (
		select page_id, page_title
		from page, categorylinks a
		where a.cl_from = page_id and page_namespace = 0 and a.cl_to in ([join $lcat ,])
	)b , categorylinks c
	where c.cl_from = page_id
	order by page_title
;" {pt ct} {
	dict lappend wINTkat $pt $ct
}
puts $wINTkat



puts [clock format [clock seconds] -format %T]




exit

#SOL
mysqlreceive $db "
	select page_id, page_title
	from page c
	where c.page_id not in (
		select page_id
		from page a, categorylinks b
		WHERE b.cl_from = a.page_id and b.cl_to IN ('Abkürzung', 'Begriffsklärung', 'Wikipedia:Falschschreibung', 'Wikipedia:Obsolete_Schreibung')
	) and c.page_namespace = 0 and c.page_is_redirect = 0
	order by page_title
;" {pgid pgt} {
	lappend lpgid $pgid
	lappend lpgt '[sql <- $pgt]'
}
lassign [list [lrange $lpgid 0 999999] [lrange $lpgid 1000000 end]] lpgid1 lpgid2
lassign [list [lrange $lpgt 0 999999] [lrange $lpgt 1000000 end]] lpgt1 lpgt2
	mysqlreceive $db "
		select page_id, count(pl_title)
		from page, pagelinks
		where pl_from = page_id and page_id in ([join $lpgid2 ,]) and page_namespace = 0 and pl_title in ([join $lpgt1 ,]) and pl_from_namespace = 0 and pl_namespace = 0
		group by page_id
		having count(pl_title) = 0
	;" {pgid plt} {
		puts $pgt:$plt
	}


#puts [llength $lpgid]
#puts [llength $lpgt]
puts [clock format [clock seconds] -format %T]


exit
mysqlreceive $db "
select page_id, page_title from (select page_id, page_title from page c where c.page_id not in (select page_id from page a, categorylinks b WHERE b.cl_from = a.page_id and b.cl_to IN ('Abkürzung', 'Begriffsklärung', 'Wikipedia:Falschschreibung', 'Wikipedia:Obsolete_Schreibung')) and c.page_namespace = 0 and c.page_is_redirect = 0) d, pagelinks where d.page_id = pl_from and pl_namespace = 0 and pl_from_namespace = 0 and (d.page_title = 'William_Hudson' or d.page_title = 'Zistrosengewächse') and pl_title in (select page_title from page g where g.page_id not in (select page_id from page e, categorylinks f WHERE f.cl_from = e.page_id and f.cl_to IN ('Abkürzung', 'Begriffsklärung', 'Wikipedia:Falschschreibung', 'Wikipedia:Obsolete_Schreibung')) and g.page_namespace = 0 and g.page_is_redirect = 0) group by page_id
;" {p t c} {puts $p:$t:$c}

exit

mysqlreceive $db "
SELECT page_title, cl_to
FROM (
   SELECT page_title, page_id, (
      SELECT COUNT((
         SELECT page_id
         FROM page X
         WHERE X.page_id = P.pl_from AND X.page_namespace = 0 AND X.page_is_redirect = 0
      ))
      FROM pagelinks P
      WHERE P.pl_title = A.page_title AND P.pl_namespace = 0 AND P.pl_from_namespace = 0
   ) AS pl_field
   FROM page A
   WHERE A.page_namespace = 0 AND A.page_is_redirect = 0
   HAVING pl_field = 0
) B, categorylinks Z
WHERE B.page_id NOT IN (
   SELECT page_id
   FROM page C, categorylinks D
   WHERE D.cl_from = C.page_id AND D.cl_to IN ('Abkürzung','Begriffsklärung','Wikipedia:Falschschreibung','Wikipedia:Obsolete_Schreibung')
) AND Z.cl_from = B.page_id
ORDER BY B.page_title
;" {pt ct} {dict lappend lpct $pt $ct}

puts $lpct
puts [llength $lpct]
puts [clock format [clock seconds] -format %T]
exit






mysqlreceive $db "select page_title from (select A.page_title, (select (SELECT page_id FROM page X WHERE X.page_id=P.pl_from and X.page_namespace=0 and X.page_is_redirect=0 LIMIT 1) from pagelinks P where P.pl_title=A.page_title and P.pl_namespace=0 and P.pl_from_namespace=0 limit 1) as pl_field from page A where A.page_namespace=0 and page_is_redirect=0 having pl_field IS NULL) B  ORDER BY B.page_title DESC;" pt {lappend lpt $pt}

puts $lpt
if {[string first !distain $lpt] > -1} {puts 1} else {puts 0}

exit

mysqlreceive $db "SELECT l.page_title FROM page l WHERE l.page_namespace = 0 AND l.page_is_redirect = 0 AND l.page_title NOT IN (       SELECT r.page_title       FROM page r, pagelinks       WHERE  r.page_id = pl_from AND r.page_namespace = 0 AND r.page_is_redirect = 0 AND pl_from_namespace = 0 AND pl_namespace = 0    )    ORDER BY l.page_title;" pt {puts $pt ; lappend lpt $pt}

puts $lpt
puts [llength $lpt]
puts [clock format [clock seconds] -format %T]
exit



mysqlreceive $db "
	SELECT DISTINCT l.page_title
	FROM page l
	WHERE NOT EXISTS (
   	SELECT r.page_title
     	FROM page r, pagelinks
      WHERE  r.page_title = l.page_title AND r.page_id = pl_from AND pl_title = l.page_title AND r.page_namespace = 0 AND r.page_is_redirect = 0 AND pl_from_namespace = 0 AND pl_namespace = 0
	) AND l.page_namespace = 0 AND l.page_is_redirect = 0
	ORDER BY l.page_title
;" pt {
	set pc [pagecat $pt]
	if {{Kategorie:Begriffsklärung} ni $pc && {Kategorie:Wikipedia:Falschschreibung} ni $pc && {Kategorie:Abkürzung} ni $pc && {Kategorie:Wikipedia:Obsolete Schreibung} ni $pc} {puts $pt ; lappend lpt $pt}
}
puts $lpt
puts [llength $lpt]
puts [clock format [clock seconds] -format %T]
exit




mysqlreceive $db "select l.page_title from page l where not exists (select r.page_title from page r, pagelinks where r.page_id = pl_from and pl_from_namespace = 0 and pl_namespace = 0 and r.page_namespace = 0 and r.page_is_redirect = 0 and r.page_id = l.page_id) and l.page_namespace = 0 and l.page_is_redirect = 0;" pt {puts $pt}




exit

mysqlreceive $db "select page_id, page_title from page, (select page_id as bkpage_id from page, categorylinks where cl_from = page_id and page_namespace = 0 and cl_to <> 'Begriffsklärung') as bkpage where page.page_id = bkpage.bkpage_id and page.page_namespace = 0 and page.page_is_redirect = 0;" {pgid pt} {lappend slpt '[sql <- $pt]' ; lappend lpt $pt}
puts [llength $lpt]
puts [llength [set lpt [lsort -unique $lpt]]]
puts [llength [set slpt [lsort -unique $slpt]]]
puts [clock format [clock seconds] -format %T]

foreach {A B} {0 999999 1000000 end} {

	mysqlreceive $db "select distinct page_title from page, pagelinks, (select page_id as bkpage_id from page, categorylinks where cl_from = page_id and page_namespace = 0 and cl_to <> 'Begriffsklärung') as bkpage where pl_from = page.page_id and bkpage.bkpage_id = page.page_id and page.page_namespace = 0 and pl_namespace = 0 and page.page_is_redirect = 0 and pl_title in ([join [lrange $slpt $A $B] ,]);" pt1 {lappend lpt1 $pt1}

puts [llength $lpt1]
puts [llength [set lpt1 [lsort -unique $lpt1]]]
puts [clock format [clock seconds] -format %T]


}

foreach pt $lpt1 {if {$pt ni $lpt} {lappend mpt $pt}
puts $mpt
puts [llength $mpt]
puts [clock format [clock seconds] -format %T]

exit
#select page_title, pl_title from page left join pagelinks on pl_from = page_id where page_namespace = 0 and pl_namespace = 0 and page_title not in ([join $lpt {, }])

mysqlreceive $db "select page_title from page where page_namespace = 0 and page_is_redirect = 0;" pt {lappend lpt $pt}
puts [llength $lpt]

mysqlreceive $db "select page_title from page, categorylinks where cl_from = page_id and page_namespace = 0 and cl_to = 'Begriffsklärung';" pt {lappend lbks $pt}
puts [llength $lbks]

foreach bks $lbks {
	lremove lpt $bks
}
puts [llength $lpt]


#select page_title from pagelinks, page where page_id = pl_from and pl_namespace = 0 and page_namespace = 0 and page_is_redirect = 0;

exit

set lcat [list {cl_to = 'Wikipedia:Defekte_Weblinks'}]
while {$lcat ne {}} {
	set lcat1 {}
	mysqlreceive $db "select page_title from page, categorylinks where cl_from = page_id and ([join $lcat { or }]) and page_namespace = 14;" pt {
		set lcat {}
		lappend lpt "cl_to = '$pt'"
		lappend lcat1 "cl_to = '$pt'"
	}
	set lcat $lcat1
}
mysqlreceive $db "select page_title from page, categorylinks where cl_from = page_id and (page_namespace = 0 or page_namespace = 1) and ([join $lpt { or }]) order by page_title;" pt {
	lappend lpt1 $pt
}
foreach pt1 $lpt1 {
	mysqlreceive $db "select page_title, cl_to from page, categorylinks where cl_from = page_id and (page_namespace = 0 or page_namespace = 1) and page_title = '[string map {' \\'} $pt1]';" {pt ct} {
		dict lappend wDWkat [string map {_ { }} $pt] Kategorie:[string map {_ { }} $ct]
	}
}
set t1 [clock format [clock seconds] -format %T]
puts $wDWkat
puts [llength $wDWkat]
puts $t1

exit

mysqlreceive $db "select page_title from page, categorylinks where cl_from = page_id and ([join $lpt { or }]) order by page_title;" pt {
	puts $pt
	lappend lpt2 "page_title = '$pt'"
	
#mysqlreceive $db "select page_title, cl_to from page, categorylinks where cl_from = page_id and (page_namespace = 0 or page_namespace = 0) and ([join $lpt { or }]) order by page_title;" {pt ct} {}
}
#puts $lpt
exit

mysqlreceive $db "select page_title from page, categorylinks where cl_from = page_id and page_namespace = 0 and cl_to = 'Mineral' order by page_title;" pt {
	lappend lpt $pt
}
foreach pt $lpt {
	if {$pt in {Graphit}} {continue}
	set c [conts t $pt x]
	set nc $c
	if {[string first \{\{Literatur\n $c] > -1} {
		puts \n$pt
		set lrx [regexp -all -inline -- {\{\{Literatur\n.*?\}\}} $c]
		foreach rx $lrx {
			set nrx {}
			if {[regexp -all -- {\{} $rx] > 2} {puts \a$rx\nerror ; exit}
#			puts $rx
			foreach line [split $rx \n] {
				regsub -- {(\||\| )} [string trim $line] { | } line
				append nrx $line
			}
#			puts $nrx
			set nc [string map [list $rx $nrx] $nc]
		}
#		puts $nc
		puts [edit $pt {Bot: Literaturvorlagen begradigt} $nc / minor]
		if {[incr i] < 5} {gets stdin}
	}
}

exit

set cl1 [clock format [clock seconds] -format %T]
set yr [clock format [clock seconds] -format %Y]
mysqlreceive $db "select page_title, cl_to from page, categorylinks where cl_from = page_id and page_namespace = 0 and (cl_to like 'Geboren%') order by page_title;" {pt ct} {
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
puts $lpt
mysqlreceive $db "select page_title, ll_lang, ll_title, cl_to from page left join langlinks on ll_from = page_id left join categorylinks on cl_from = page_id where page_namespace = 0 and ([join $lpt { or }]);" {pt lll llt ct} {
	dict lappend lwVVkat [string map {_ { }} $pt] [list $lll [string map {_ { }} $llt]]
	dict lappend cwVVkat [string map {_ { }} $pt] Kategorie:[string map {_ { }} $ct]
#	Kategorie:[string map {_ { }} $ct]
}
foreach {pt ll} $lwVVkat {lappend nlwVVkat $pt [join [lsort -unique $ll]]}
foreach {pt ct} $cwVVkat {lappend ncwVVkat $pt [lsort -unique $ct]}
set wVVkat [join [lmap pt [dict keys $nlwVVkat] ll [dict values $nlwVVkat] ct [dict values $ncwVVkat] {list [list $pt $ll] $ct}]]
set cl2 [clock format [clock seconds] -format %T]

puts $wVVkat
puts "$cl1 - $cl2"
exit

mysqlreceive $db "select page_title, cl_to from page, templatelinks, categorylinks where tl_from = page_id and page_namespace = 0 and tl_title = 'Personendaten' order by page_title;" {pt ct} {
#	puts [string map {_ { }} $pt]:[string map {_ { }} $ct]
}
puts [clock format [clock seconds] -format %T]
mysqlreceive $db "select page_title, cl_to from (select page_title, page_id from page, templatelinks where tl_from = page_id and page_namespace = 0 and tl_title = 'Personendaten') as page, categorylinks where cl_from = page_id order by page_title;" {pt ct} {
#	puts $pt:$ct
}
puts [clock format [clock seconds] -format %T]

exit

mysqlreceive $db "
	select page_title, page_is_redirect
	from page
	where page_namespace = 12
;" {pt pir} {
	puts $pt:$pir
#	if {$prt ne {}} {gets stdin}
}
#puts $l4

exit

set debug 1
set verbose 1
while 1 {
	if [catch {
		puts [clock format [clock seconds] -format %T]
		conts t {GP 1890} x
	}] {
		puts 502err:[incr i]
	}
}

exit

mysqlreceive $db "select page_namespace, page_title, cl_to from page, categorylinks, templatelinks where cl_from = page_id and tl_from = page_id and (tl_title = 'Portalhinweis' or tl_title = 'Projekthinweis' or tl_title = 'Redaktionshinweis') order by page_title;" {pns pt ct} {
	if {[set pt [nssort p $pns $pt]] ne {}} {dict lappend phkat $pt Kategorie:[string map {_ { }} $ct]}
}
puts $phkat

exit

foreach ei {Portalhinweis Projekthinweis Redaktionshinweis} {lappend ph [template $ei p]}
foreach ph [lsort -unique [join $ph]] {
	lappend phkat $ph [pagecat $ph]
}
puts $phkat


exit

	mysqlreceive $db 	"
		select page_id
		from page
		where page_namespace = 0 and page_title = 'Mainz'
	;" pgid {
		lappend lkeyid "page_id = $pgid"
	}

puts $lkeyid

exit

source QSWORKLIST/@qsdict.db
foreach key [dict keys $qsdict] {
	lappend lkey "tl_title = '[string map {{ } _ {\'} {\'} {'} {\'}} $key]'"
}
mysqlreceive $db "select page_title, tl_title, cl_to from page, templatelinks, categorylinks where tl_from = page_id and cl_from = page_id and page_namespace = 0 and ([join $lkey { or }]) order by page_title;" {pt tl ct} {
	dict lappend lsnak [list $pt $tl] Kategorie:[string map {_ { }} $ct]
}
foreach {pttl lcat} $lsnak {
	lappend qskat [string map {_ { }} [lindex $pttl 0]] [list pagecat $lcat qstempl [set key [string map {_ { }} [lindex $pttl 1]]] qsshort [lindex [set val [dict get $qsdict $key]] 0] qslong [lindex $val 1]]
}
puts $qskat
puts [clock format [clock seconds] -format %T]

	
exit
	
	mysqlreceive $db "select page_id from page where page_namespace = 10 and page_title = '$key';" pgid {
		lappend lkeyid "page_id = $pgid"
	}
#	lappend lkeyid [join [mysqlsel $db "select page_id from page where page_namespace = 10 and page_title = '$key';" -list]]
}

puts $lkeyid
exit


foreach key [dict keys $qsdict] {lappend lqs [templids $key 0]}
set fi [clock format [clock seconds] -format %T]
puts $lqs
puts $fi
exit


foreach rvid [catids Wikipedia:Reviewprozess -kat] {lappend lrvid "page_id = $rvid"}
mysqlreceive $db "select page_namespace, page_title, cl_to from page, categorylinks where cl_from = page_id and ([join $lrvid { or }]) order by page_title;" {pns pt ct} {
	if {[set pt [nssort -kat $pns $pt]] ne {}} {dict lappend rvkat $pt Kategorie:[string map {_ { }} $ct]}
}
puts [clock format [clock seconds] -format %T]
puts $rvkat
puts [llength $rvkat]

exit

lassign [list [catitems Wikipedia:Kategorienlöschung 14] [catitems Wikipedia:Kategorienumbenennung 14] [catitems Wikipedia:Kategorienzusammenführung 14] [catitems {Wikipedia:Qualitätssicherung Kategorien} 14] [catitems Wikipedia:Kategorienklassifizierung 14]] kdla kdub kdzf kdqs kdkl
lappend kdkat kdla $kdla kdub $kdub kdzf $kdzf kdqs $kdqs kdkl $kdkl
puts $kdkat
puts [clock format [clock seconds] -format %T]
exit


lassign [list [cat {Kategorie:Wikipedia:Kategorienlöschung} 14] [cat {Kategorie:Wikipedia:Kategorienumbenennung} 14] [cat {Kategorie:Wik
ipedia:Kategorienzusammenführung} 14] [cat {Kategorie:Wikipedia:Qualitätssicherung Kategorien} 14] [cat {Kategorie:Wikipedia:Kategorienk
lassifizierung} 14]] kdla kdub kdzf kdqs kdkl



foreach lkid [join "[catids Wikipedia:Löschkandidat -kat] [catids {Wikipedia:Löschkandidat/Benutzer- und Metaseiten} -kat] [catids Wikipedia:Löschkandidat/Vorlagen -kat] [catids {Wikipedia:Löschkandidat Bahn} -kat]"] {lappend llkid "page_id = $lkid"}
mysqlreceive $db "select page_namespace, page_title, cl_to from page, categorylinks where cl_from = page_id and ([join $llkid { or }]) order by page_title;" {pns pt ct} {
   if {[set pt [nssort -kat $pns $pt]] ne {}} {dict lappend lkkat $pt Kategorie:[string map {_ { }} $ct]}
}
puts "[clock format [clock seconds] -format %T]:lkkat komplett"
puts $lkkat
puts [llength $lkkat]




exit

foreach pgid [catids Wikipedia:Überarbeiten p] {lappend lnpgid "page_id = $pgid"}
#set lnpgid [join $lnpgid { or }]
mysqlreceive $db "select page_namespace, page_title, cl_to from page, categorylinks where cl_from = page_id and ([join $lnpgid { or }]) order by page_title;" {pns pt ct} {
	if {[set pt [nssort p $pns $pt]] ne {}} {dict lappend lwUE $pt Kategorie:[string map {_ { }} $ct]}
}
puts $lwUE


exit

mysqlreceive $db "select  page_id from page, categorylinks where cl_from = page_id and cl_to = 'Wikipedia:Überarbeiten';" pgid {lappend lpid "page_id = $pgid"} ; set lpid [join $lpid { or }]
mysqlsel $db "select page_namespace, page_title, cl_to from page, categorylinks where cl_from = page_id and ($lpid);" -list




exit

puts [clock format [clock seconds] -format %T]
set hidden [join [mysqlsel $db "select page_title from page, categorylinks where page_namespace = 14 and cl_from = page_id and cl_to = 'Kategorie:Versteckt';" -list]]
mysqlreceive $db "select page_id, cl_to from page left join categorylinks on cl_from = page_id where page_namespace = 0 and page_is_redirect = 0 order by page_title;" {pt cl} {
	if {$cl in $hidden} {set cl {}}
	dict lappend lwKAT $pt $cl
}
puts [clock format [clock seconds] -format %T]
foreach {pt cl} $lwKAT {
	foreach item $cl {
		if {$item eq {}} {lremove cl $item}
	}
	if {$cl eq {}} {lappend nlwKAT $pt}
}
unset hidden lwKAT
puts $nlwKAT
foreach item $nlwKAT {
	puts $item
	set lcat {}
	set conts [conts id $item 0]
	set lwlink [dict values [regexp -all -inline -- {\[\[(.*?)[|#\]]} $conts]]
	foreach wlink [lsort -unique $lwlink] {
		puts $wlink
		if [catch {if ![ns $wlink] {lappend lcat [pagecat $wlink]}}] {continue}
	}
	set lcat [lsort -unique [join $lcat]]
	set pt [string map {_ { }} [mysqlsel $db "select page_title from page where page_id = $item;" -list]]
	lappend wKATkat $pt $lcat
}
puts $wKATkat
exit

set allpageswc [lsort -unique $allpageswc]
foreach pt $allpages {
	puts [incr i]
	if {$pt in $allpageswc} {continue} else {lappend allpageswoc $pt}
}
puts [llength $allpages]
puts [llength $allpageswc]
puts [llength $allpageswoc]
#puts [llength $lwKAT]
puts [clock format [clock seconds] -format %T]

gets stdin

puts $allpageswoc

exit

foreach {pgid pgt} $lpg {
	lappend nlpg $pgt [pagecat $pgt]
}



exit

mysqlreceive $db "select page_title from page, categorylinks where page_namespace = 0 and page_id = 936587;" pt {
#	puts $pt
#   if {$cl in $hidden} {set cl {}}
#   dict lappend lwKAT $pt $cl
	puts $pt
}
puts $lwKAT

exit

set hidden [join [mysqlsel $db "select page_title from page, categorylinks where page_namespace = 14 and cl_from = page_id and cl_to = 'Kategorie:Versteckt';" -list]]
mysqlreceive $db "select page_title, cl_to from page, categorylinks where page_namespace = 0 and cl_from = page_id;" {pt cl} {
   if {$cl in $hidden} {set cl {}}
   dict lappend lwKAT $pt $cl
}
foreach {pt cl} $lwKAT {
   foreach item $cl {
      if {$item eq {}} {
         lremove cl $item
      }
   }
   if {$cl eq {}} {
      lappend nlwKAT [string map {_ { }} $pt]
   }
}
puts [lsort -unique $nlwKAT]

foreach page [lsort -unique $nlwKAT] {
	set conts [conts t $page 0]
	puts $conts
	gets stdin
}





exit

set hidden [join [mysqlsel $db "select page_title from page, categorylinks where page_namespace = 14 and cl_from = page_id and cl_to = 'Kategorie:Versteckt';" -list]]

mysqlreceive $db "select page_title, cl_to from page, categorylinks where page_namespace = 0 and cl_from = page_id;" {p c} {
	if {$c in $hidden} {set c {}}
	dict lappend b $p $c
}

#puts [lsort $b]

foreach {p c} $b {
	foreach item $c {
		if {$item eq {}} {
			lremove c $item
		}
	}
	if {$c eq {}} {
		puts [string map {_ { }} $p]
	}
}

exit

foreach {p c} $d {
	if {$c eq {}} {
		puts [string map {_ { }} $p]
	}
}


#puts [edit user:TaxonBota/Test1 test [lrange $d 1266 1367]]

#foreach {1 2} $b {
#	if {[string first Datei:\{ $1] > -1} {
#		puts $1:$2
#	}
#}

exit

puts [mysqlreceive $db "select page_title, cl_to from page, categorylinks where page_namespace = 0 and cl_from = page_id" -list]


exit

set db [get_db enwiki]
set db [get_db tools s51837__MerlBot]

set catlemma {Animated film stubs}
set catns 14
set lcat14 [format {{%s}} $catlemma]
lassign {0 1} olenlcat14 lenlcat14
while {$lenlcat14 != $olenlcat14} {
#	if {$lenlcat14 == $olenlcat14} {break}
	set olenlcat14 $lenlcat14
	set lcat14 [split $lcat14]
	foreach cat14 [join $lcat14] {lappend lcat14 [sqlcat $cat14 14]}
	set lcat14 [lsort -unique [join $lcat14]]
	set lenlcat14 [llength $lcat14]
}
#lremove lcat14 $catlemma
foreach cat14 $lcat14 {lappend lcat [sqlcat $cat14 $catns]}
puts [lsort -unique [join $lcat]]:[llength [lsort -unique [join $lcat]]]

exit

#set revc [mysqlsel $db "select count(*) from revision join page on rev_page = page_id where page_title = \"[join $src _]\" and page_namespace = 0" -list]

#puts [mysqlsel $db "select page_title from page, categorylinks where page_id = cl_from and cl_type = 'subcat' and cl_to = 'Mineralogie';" -list]

#puts [mysqlsel $db "select * from page where page_title = 'ABC';;" -list]

set data [mysqlsel $db "select page_title from page, categorylinks where page_id = cl_from and cl_to = 'Stage_actors' and page_namespace = 14 ;" -list]
puts $data\n[llength $data]


