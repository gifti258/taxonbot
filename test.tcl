#!/usr/bin/tclsh8.7
#exit

#set editafter 1

source api2.tcl
set lang de ; source langwiki.tcl
set token [login $wiki]
source procs.tcl
source library.tcl
#set db [get_db dewiki]

#package require http
#package require tls

package require tdom

#package require term::ansi::ctrl::unix
#term::ansi::ctrl::unix::import

#set dom [[[dom parse -html [getHTML https://www.wtatennis.com/players/190247/-]] documentElement] asList]

set html [join [regexp -inline -- {<section class="player-scores-overview widget".*?</section>} [getHTML https://www.wtatennis.com/players/190247/-]]]

set dom [[[dom parse -html $html] documentElement] asList]

set dom [[[dom parse -html [join [regexp -inline -- {<section class="player-scores-overview widget".*?</section>} [getHTML https://www.wtatennis.com/players/190247/-]]]] documentElement] asList]

puts [lindex $dom 2 0 1 end]

puts [lindex $dom 2 0 2 0 2 0 2 1 1 1]

puts \n\n\n$dom


exit

set i -1
puts [lindex $dom 2 1 2 8 2 0]
puts [split [lindex $dom 2 1 2 8 2 0 2 2 2 0 2 0 2 1 1 1] /] ; gets stdin
foreach line [lindex $dom 2 1 2 8 2 0 2 2 end] {
	puts [incr i]
	if {[string first {player-scores-overview widget} $line] > -1} {
		puts $line ; gets stdin
		break
	}
}

source test.tcl



exit

set body [d_query_raw {
   select ?item ?itemLabel_de ?sitelink_de ?itemLabel_en ?sitelink_en ?Tennis-Temple-ID
      where {
            ?item wdt:P4544 ?Tennis-Temple-ID.
                  optional {
                           ?sitelink_de ^schema:name ?article_de.
                                    ?article_de schema:about ?item; schema:isPartOf <https://de.wikipedia.org/>.
                                          }
                                                optional {
                                                         ?sitelink_en ^schema:name ?article_en.
                                                                  ?article_en schema:about ?item; schema:isPartOf <https://en.wikipedia.org/>.
                                                                        }
                                                                              optional {?item rdfs:label ?itemLabel_de. filter(lang(?itemLabel_de)="de")}
                                                                                    optional {?item rdfs:label ?itemLabel_en. filter(lang(?itemLabel_en)="en")}
                                                                                       }
                                                                                       }]
                                                                                       

puts $body


exit

set c [conts id 6012219 x]
set rex [dict values [regexp -all -inline -line -- {\| OT.*?\[\[(.*?)\|.*\n} $c]]

foreach pg $rex {
	puts $pg
	puts [lindex [mysqlsel $db "
		select rev_timestamp from revision join page on page_id = rev_page
		where !page_namespace and page_title = '[sql <- $pg]'
	" -list] 0]
}


exit

set html [getHTML https://www.projekt-gutenberg.org/info/texte/allworka.html]
#puts $html

set rex [regexp -all -inline -line -- {.*?<a href.*?.html} $html]

foreach line $rex {
	set sline [split $line /.]
	set word1 [lindex $sline end-2]
	set word2 [lindex $sline end-1]
	if {$word2 ne $word1} {
		puts $word1:$word2
	}
}


exit

set input {}
puts Suchwort:
exec stty -echo raw
while {[set in [read stdin 1]] ne "\n"} {
append input $in
puts "Suchwort: $input"
}
exec stty echo cooked


puts $input

exit

puts $ch
puts $ci
puts $a
exit

set pg1id 9741583
set pg2id 9819730

set conts1 [conts id $pg1id 1]
set conts2 [conts id $pg2id 14]
#puts $conts

set luser [regexp -all -inline -line -- {\[\[Benutzer.*?:(.*?)\|(.*?)\]\]} $conts1]

append conts2 "<br /><small>''Der Text wurde automatisch versandt mit ${~}''</small>"

foreach {-- user --} $luser {
#	puts [edit "user talk:$user" {} {} / appendtext \n\n$conts2]
}

exit

set largv [split $argv ,]
lassign [split $argv ,] de en

#puts [mysqlsel $db {select pp_value from page_props where pp_page = 24360;} -list]
#puts "Wrestler ($de)"

set db [get_db dewiki]
set qde [get_q "Wrestler ($de)" 14]
mysqlclose $db

set db [get_db enwiki]
set qen [get_q [sql <- "$en professional wrestlers"] 14]
mysqlclose $db

puts $de:$qde
puts $en:$qen

d_merge $qde $qen

#puts [get [post $wiki {*}$format {*}$token / action wbmergeitems / fromid $qde / toid $qen / ignoreconflicts description]]
#puts [get [post $wiki {*}$format {*}$token / action wbeditentity / id $qde / clear true / data {{}} / summary {Clearing item to prepare for redirect}]]
#puts [get [post $wiki {*}$format {*}$token / action wbcreateredirect / from $qde / to $qen]]


exit

read_file xmlframe.xml a
puts $a

exit

read_file xml1.xml oxml


set lrx [dict values [regexp -inline -- [format {(\<revision\>\n      \<id\>%s\</id\>.*?\</revision\>)} $argv] $oxml]]

set nxml [string map [list [join $lrx] {}] $oxml]


#puts $nxml
save_file xml1.xml $nxml


exit

proc jlindex {list index} {
	return [join [lindex $list $index]]
}

mysqlreceive $db {
	select page_title, pp_value
	from page, categorylinks, page_props
	where cl_from = page_id and pp_page = page_id and cl_to = 'Gambier'
	order by page_title
;} {pt ppv} {
	dict append lpt $pt " [list $ppv]"
}

foreach {pt ppv} $lpt {
	lappend lQ [set Q [lindex $ppv end]]
	lappend lpp [list -Q [string range $Q 1 end] Q $Q pn [sql -> $pt] np [lindex $ppv 0]]
}
lassign [list -10 -1 [expr [llength $lQ] / 10]] offset1 offset2 dlQ

while {[decr dlQ] >= -1} {
	set qresxml [encoding convertfrom [[[dom parse -html [d_query_raw [
		format {
			select
				?item
				(group_concat(distinct ?p21lLabel;	separator=", ") as ?p21Label)
				(group_concat(distinct ?p27lLabel;	separator=", ") as ?p27Label)
				?date_birth
				(group_concat(distinct ?p19lLabel;	separator=", ") as ?p19Label)
			where {
				hint:Query hint:optimizer "None".
				values ?item {%s}
				optional {?item wdt:P19		?p19_.}
				optional {?item wdt:P21		?p21_.}
				optional {?item p:P569/psv:P569 [
					wikibase:timeValue			?date_b;
					wikibase:timePrecision		?prec_b;
					wikibase:timeCalendarModel	?cal_b
				].}
				optional {?item wdt:P27		?p27_.}
				service wikibase:label {
					bd:serviceParam wikibase:language "de,[AUTO_LANGUAGE]".
					?p19_ rdfs:label ?p19_Label.
					?p21_ rdfs:label ?p21_Label.
					?p27_ rdfs:label ?p27_Label.
				} hint:Prior hint:runLast false.
				bind(coalesce(?p19_Label,"style=\"background:#ff0000;\" |"@en)	as ?p19lLabel)
				bind(coalesce(?p21_Label,"style=\"background:#ff0000;\" |"@en)	as ?p21lLabel)
				bind(coalesce(?p27_Label,"style=\"background:#ff0000;\" |"@en)	as ?p27lLabel)
				bind(if(bound(?date_b),concat(strbefore(str(?date_b),"T")," ",str(?prec_b)," ",strafter(str(?cal_b),"entity/")),"style=\"background:#ff0000;\" |"@en) as ?date_birth)
  				service wikibase:label {bd:serviceParam wikibase:language "de,[AUTO_LANGUAGE]".}
			}
			group by ?item ?date_birth
		} wd:[join [lrange $lQ [incr offset1 10] [incr offset2 10]] " wd:"]
	]]] documentElement] asList]]
	foreach res [lindex $qresxml 2 1 2] {
puts $offset1:$offset2:\n$res
		dict lappend dp [
			lindex [split [lindex [jlindex [jlindex [jlindex $res 2] 2] 2] 1] /] end
		] date_b	[lindex [jlindex [jlindex [jlindex $res 2] 5]	2] end
		] p21		[lindex [jlindex [jlindex [jlindex $res 2] 8]	2] end
		] p27		[lindex [jlindex [jlindex [jlindex $res 2] 11]  2] end
		] p19		[lindex [jlindex [jlindex [jlindex $res 2] 14]  2] end
		]
	}
}

puts $dp
puts [llength $dp]
save_file test.db $dp

exit

foreach pp [lsort -index end [lsort -index end-2 $lpp]] {
	dict with pp {
		lappend tpp "\n| style=\"text-align: right;\" | [incr lfd] || style=\"text-align: right;\" data-sort-value=\"${-Q}\" | \[\[:d:$Q|$Q\]\] || data-sort-value=\"$np\" | \[\[$pn\]\] || [dict get $dp $Q p27] || [dict get $dp $Q p21] || [expr {[catch {set d_b [d_get_lq $Q P569]}] ? {...} : $d_b}] || [dict get $dp $Q p19]"
	}
}

set th "\{| class=\"wikitable sortable\"\n|-\n! style=\"text-align: right;\" | lfd. !! Q !! Name !! Staatsangehörigkeit (P27) !! Geschlecht (P21) !! Geburtsdatum (P569) !! Geburtsort (P19)\n|-"

set t "$th[join $tpp "\n|-"]\n|\}"
puts $t


exit
set lang de ; source langwiki.tcl
set token [login $wiki]
puts [edit Benutzer:Atamari/Gambier-Check {Bot: +P21} $t]


exit

puts [llength [lsort -unique $lpt]]

puts [mysqlsel $db {
	select pp_value
	from page_props
	where pp_page = 10275497
} -list]

exit
set lpt [
	get [post $wiki {*}$format / action query / list categorymembers / cmtitle Kategorie:Gambier / cmprop title / cmlimit max] query categorymembers
]

foreach pt $lpt {
	puts [incr zzz2]:$pt
}

exit

mysqlreceive $db "
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
;" {pt pid} {lappend lpt $pt $pid}

save_file test.db $lpt


exit

read_file slub.db db

foreach {pgid oldid newid} $db {
	puts [incr i]
	unset -nocomplain rex
	set oconts [conts id $pgid x]
	set rex [regexp -all -inline -line -- {\{\{SächsBib.*?\}\}} $oconts]
	set pt [page_title $pgid]
	if {[string first GND= $rex] == -1} {
		puts $pt
		puts $rex
		set nconts [string map [list SächsBib|$oldid SächsBib|GND=$newid] $oconts]
		puts [edid $pgid {Bot: GND statt PPN nach [[WP:BA#Vorlagenanalyse für Sächsische Bibliothek]]} $nconts / minor]
		if {$i < 10} {gets stdin}
	}
}





exit

set lpt [mysqlsel $db "select page_title from page where page_title like 'Wikiolo_in_Liechtenstein%' and page_namespace = 6;" -flatlist]

puts $lpt

foreach pt $lpt {
	set c [conts t File:$pt x]
	if {[string first {{{WikiAlpenforum}}} $c] == -1} {
		puts \n[edit File:$pt {Bot: + {{WikiAlpenforum}}} {} / appendtext \n\{\{WikiAlpenforum\}\} / minor]
	}
}



exit

set lv0 {26913 26916 26917 26920 26921 26922 26932 26972 29701 29703 30453 30454 30455 30456 30457 33194 33195 34262 44471 44481}
for {set x 187481934} {$x <= 187481953} {incr x} {
	lappend lv $x
}
set zlv [join [lmap 1 $lv 2 $lv0 {list $1 $2}]]


set c [conts t user:Doc_Taxon/Richard_Grune 6]
set c [string map $zlv $c]
set c [string map {de> {} de.wikipedia.org/w kiel-wiki.de {[:user} http://kiel-wiki.de/user {[:de:} http://kiel-wiki.de/ {]]} {]} | { }} $c]
set c [string map {{:Anna } :Anna_ {:M. } :M._ {/2. } /2._ {/26. } /26._ /1903 {/1903 1903}} $c]

puts $c

puts [edit user:Doc_Taxon/Richard_Grune {} {} / appendtext \n\n$c]

exit

set lpt [mysqlsel $db {select page_title from page where !page_namespace;} -flatlist]

foreach pt $lpt {
	catch {
		puts \n$pt:
		set c [conts t $pt x]
		set nc [string map [list \u007f {} \u200b {} \u200e {} \u200f {} \u2028 {} \u2029 {} \u202a {} \u202d {} \ufeff {}] $c]
		if {$nc ne $c} {
			puts [edit $pt {Bot: obsolete Steuerzeichen entfernt} $nc / minor]
		}
	}
}






exit

puts $lpt


puts $c

exit

puts $argv0



exit

set db [getHTML https://www.bundesbank.de/resource/blob/602702/latest/mL/blz-neu-txt-data.txt]

#puts $db

#save_file blz.db $db

proc r {s e} {
	global d
	if {$s < 0} {set s end$s}
	if {$e < 0} {set e end$e}
	return [string range $d $s $e]
}

foreach d [split [string trim $db] \n] {
	unset -nocomplain ds blz bic pds
	set ds  [r -15 -10]
	set blz [r 0 7]
	set bic [r -28 -25]\ [r -24 -21]\ [r -20 -18]
	set pds [r -33 -29]
	lappend ld |$ds\BLZ=$blz|$ds\BIC=$bic|$pds\DS=$ds
}

set c [conts t {Vorlage:Infobox Kreditinstitut/DatenDE} x]
regsub -- {(<!--SUBSTER-DatenDE-->).*<!--SUBSTER-DatenDE-->} $c \\1[join $ld \n]\\1 c
puts [edit {Vorlage:Infobox Kreditinstitut/DatenDE} {Bot: Aktualisierung der Daten} $c / minor]





exit

set db [getHTML [set url https://de.wikipedia.org/wiki/Afg]]

puts $db




exit

puts [::http::geturl http://www.bundesbank.de/resource/blob/602702/latest/mL/blz-neu-txt-data.txt -type]

puts [curlHandle -url https://www.bundesbank.de/resource/blob/602702/latest/mL/blz-neu-txt-data.txt]





exit

proc rc u {
	global zq pt c
	set lrc [regexp -all -inline -- [format {.{0,40}\u%s.{0,40}} $u] $c]
	set crc [regexp -all -- [format {\u%s} $u] $c]
	if {$lrc ne {}} {
		switch $u {
			00a0 {set lu NoBackSpace}
			2004 {set lu ThreePerEmSpace}
			2005 {set lu FourPerEmSpace}
			2007 {set lu FigureSpace}
			200b {set lu ZeroWidthSpace}
			200e {set lu LeftToRightMark}
		}
		puts "----\n$crc $lu: $pt:\n"
		foreach rc $lrc {
			puts [regsub -all -- [format {\u%s} $u] $rc ʃ]
		}
		return {}
	} else {
		return {}
	}
}


set zq {Bot: Steuerzeichen ersetzt}
set nlist [list \u00a0 {&nbsp;} \u2004 {&nbsp;} \u2005 {&nbsp;} \u2007 {&nbsp;} \u200b {&nbsp;} \u200e {&nbsp;}]
set llist [list \u00a0 { } \u2004 { } \u2005 { } \u2007 { } \u200b { } \u200e { }]
set elist [list \u00a0 {} \u2004 {} \u2005 {} \u2007 {} \u200b {} \u200e {}]
set clist [list " \u00a0 " { } " \u2004 " { } " \u2005 " { } " \u2007 " { } " \u200b " { } " \u200e " { }]
set lpt [lrange [split [lindex [encoding convertfrom [[[dom parse -html [getHTML https://tools.wmflabs.org/checkwiki/cgi-bin/checkwiki.cgi?project=dewiki&view=bots&id=16]] documentElement] asList]] 2 1 2 0 2 0 1] \n] 1 end-1]

foreach pt $lpt {
	set c [conts t $pt x]

	foreach u {00a0 2004 2005 2007 200b 200e} {
		rc $u
	}

	input nl "\n&nbsp;/Leerzeichen/empty/cut? "

	switch $nl {
		n			{puts [edit $pt $zq [string map $nlist $c] / minor]\n}
		l			{puts [edit $pt $zq [string map $llist $c] / minor]\n}
		e			{puts [edit $pt $zq [string map $elist $c] / minor]\n}
		c			{puts [edit $pt $zq [string map $clist $c] / minor\n]}
		default	{}
	}

	getHTML https://tools.wmflabs.org/checkwiki/cgi-bin/checkwiki.cgi?project=dewiki&view=only&id=16&title=[::http::formatQuery $pt]
}

exit
}

exit

	set lrc [regexp -all -inline -- {.{30}[\u00a0\u200b].{30}} $c]
	set crc [regexp -all -- {\u00a0} $c]

	puts "$crc: $pt:\n"
	foreach rc $lrc {
		puts [string map [list \u00a0 ʃ] $rc]
	}

	input nl "\n&nbsp;/Leerzeichen/empty? "

	switch $nl {
		n			{puts [edit $pt $zq [string map [list \u00a0 {&nbsp;}] $c] / minor]}
		l			{puts [edit $pt $zq [string map [list \u00a0 { }] $c] / minor]}
		e			{puts [edit $pt $zq [string map [list \u00a0 {}] $c] / minor]}
		default	{continue}
	}

	getHTML https://tools.wmflabs.org/checkwiki/cgi-bin/checkwiki.cgi?project=dewiki&view=only&id=16&title=[::http::formatQuery $pt]
}

exit

set pt {18. Jahrhundert}
puts [edit $pt {} [string map [list \u00a0 { }] [conts t $pt x]] / minor]

exit

#set token [get [post $wiki {*}$format / action query / meta tokens] query tokens csrftoken]

#puts [post $wiki {*}$format {*}$token / action edit / title user:TaxonBot/Test / appendtext "\n\nte\u00a0st"]

#exit

set c [post $wiki {*}$format / action query / prop revisions / titles user:TaxonBot/Test / rvprop content / rvslots *]

puts $c

#set c [string map {{\u00a0} {&nbsp;}} $c]

puts [set text [regexp -inline -- {\[\{"slots":.*\]} $c]]
puts [regexp -all -inline -- {[^\\]".*?[^\\]"} $text]

exit

if {[string first \\u00a0 $c] > -1} {puts Treffer}



exit

set lsr [insource {[A-Za-z]d[ei][res] Countys/} 0]
puts $lsr
puts [llength $lsr]

foreach sr [lsort -unique $lsr] {
	puts $sr:
	set conts [conts t $sr x]
	set lt [regexp -all -inline -- {.{20}[A-Za-z]d[ei][res] Countys.{20}} $conts]
	foreach t $lt {
		puts $t
	}
	gets stdin
}


exit

foreach sr [lsort -unique $lsr] {
	set conts [conts t $sr x]
	set nconts [string map {{der Counties} {der Countys} {des Counties} {des Countys} {die Counties} {die Countys}} $conts]
	if {$nconts ne $conts} {
		puts $sr:\n[edit $sr {Bot: Counties → Countys} $nconts / minor]\n
	}
}

exit

read_file test.txt aqua

puts $aqua

exit

set l [mysqlsel $db {select page_title from page,templatelinks where tl_from = page_id and !page_namespace and tl_title = page_title;} -flatlist]

set j 0
foreach 1 $l {
	incr i
	if {$i == 200} {incr j ; set i 0}
	dict lappend dl $j $l
}

puts [llength $dl]

foreach {nr l} $dl {
	puts $nr
	get [post $wiki {*}$format / action purge / titles [join $l |] / forcerecursivelinkupdate]
}

exit

set hidden [scat Kategorie:Versteckt 14]
foreach 1 $hidden {
	puts $1
}
#set db [get_db dewiki]
#mysqlreceive $db "
#   select page_id, cl_to
#   from page left join categorylinks on cl_from = page_id
#   where page_namespace = 0 and page_is_redirect = 0
#   order by page_title
#;" {pt cl} {
#   if {[sql -> $cl] in $hidden} {set cl {}}
#   dict lappend lwKAT $pt $cl
#}
#mysqlclose $db
#save_file wkat_lwKAT $lwKAT



set lwKAT [read_file wkat_lwKAT]

set lwKAT [list 10683204 [dict get $lwKAT 10683204]]
#set lwKAT [list 10683204 Wikipedia:Artikel_ohne_Wikidata-Datenobjekt]
puts $lwKAT
foreach {pt cl} $lwKAT {
	puts $pt:$cl
   foreach item $cl {
		if {$item eq {}} {lremove cl $item}
   }
   puts $pt:$cl
   puts [regexp -nocase -all {#WEITERLEITUNG|#REDIRECT|\{\{URV} [conts id $pt x]]
   if {$cl eq {}} {
      if ![regexp -nocase -all {#WEITERLEITUNG|#REDIRECT|\{\{URV} [conts id $pt x]] {lappend nlwKAT $pt}
   }
}
puts $nlwKAT


exit

set hist [string map {http://de.wikipedia.org/w/index.php?oldid= https://youtube.fandom.com/de/w/index.php?oldid= de> {} {[[:user:} {[https://youtube.fandom.com/de/wiki/user:} {]]} { (YouTube Wiki)]} | { }} [conts t Benutzer:TaxonBot/Test 1]]
#puts $hist
set vf 185374097
set vl 185374188

for {set i $vf} {$i <= $vl} {incr i} {
	if {[string first $i $hist] > -1} {lappend loldid2 $i}
}

set dom [[[dom parse -html [getHTML https://youtube.fandom.com/de/wiki/Jay_%26_Arya?limit=100&action=history]] documentElement] asList]
#puts $dom

set loldid1 [dict values [regexp -all -inline -- {oldid=(\d.*?) } $dom]]
set loldid2 [lsort -unique -integer -decreasing $loldid2]
#puts [llength [lsort -unique $loldid2]]
set loldid1 [lsort -unique -integer -decreasing $loldid1]
#puts [llength [lsort -unique $loldid1]]

lmap 1 [lrange $loldid1 1 end] 2 $loldid2 {
	set hist [string map [list $2 $1] $hist]
}

set hist [string map {{  } { |}} $hist]

puts $hist

puts [edit user:TaxonBot/Test {} $hist]

exit



set conts [split [regsub -all {<!--.*?-->} [conts id 10665777 x] {}] \n]
foreach line $conts {
	if ![string first * [string trim $line]] {
		regexp -- {\[\[:(.*?)\]\]} $line -- cat
		set key [string index $line end-1]
		if {$key eq {0}} {set key -}
		dict lappend dcat $key [string range $cat 10 end]
	}
}
foreach {key lval} $dcat {
	switch $key {
		-			{
						lappend pcatdb $lval
					}
		+			{
						lappend pcatdb $lval
						foreach val $lval {
							lappend pcatdb [dcat list $val 14]
						}
					}
		default	{
						set i 0
						while {$key != $i} {
							lappend dpcatdb $lval
							incr i
							foreach val $lval {
								lappend dpcatdb [scat $val 14]
							}
							set lval [join $dpcatdb]
							set dpcatdb {}
						}
						lappend pcatdb $lval
					}
	}
}
foreach cat [lsort -unique [join $pcatdb]] {
	lappend catdb Kategorie:$cat
}

puts $catdb

#		-			{lappend catdb $val}



exit

set lc [scat Politische_Partei_nach_Staat 14]

foreach cat $lc {
	puts \n$cat
	input state {Staat: }
	if {$state ne {n}} {
		lappend clist [format {== Bot: [[:Kategorie:%s]] nach [[:Kategorie:Partei (%s)]] ==%ssiehe [[Wikipedia:WikiProjekt Kategorien/Diskussionen/2015/August/21|Diskussion]] %s} $cat $state \n ${~}]
	}
	puts [join $clist \n\n]
}

puts [edit Wikipedia:WikiProjekt_Kategorien/Warteschlange {Änderung der [[:Kategorie:Politische Partei nach Staat} {} / appendtext \n[join $clist \n\n]]

exit

mysqlreceive $db {
	select page_title
	from page
	where page_namespace = 14
;} pt {
	lappend lpt Kategorie:[sql -> $pt]
}
#puts $lpt
set offset 0
#set lpt [lrange [split [read_file test.db] \n] 0 end-2]
#set pt {Kategorie:Parlamentswahl in Litauen}
foreach pt [lsort $lpt] {
	puts $pt:
	if {$pt eq {Kategorie:Snookerverein}} {
		set offset 1
	}
	if !$offset {continue}
	set lline {}
	set lconts [split [set oconts [set conts [conts t $pt x]]] \n]
	foreach line $lconts {
		lassign {0 0} § °
		if {[string first '' $line] > -1} {
#			puts $lconts
#		puts $line
			set cline [string map {''' §§§ '' °°} $line]
#		puts $cline
			set § [regexp -all {§§§} $cline]
#		puts ${§}
#		if [expr ${§} % 2] {puts odd}
			set ° [regexp -all {°°} $cline]
#		puts ${°}
			if {[expr ${§} % 2] || [expr ${°} % 2]} {lappend lline $line $cline}
		}
	}
#	puts $lline
	foreach {line cline} $lline {
		if {[string range $cline 0 4] eq {§§§°°}} {
			puts \a$line
			puts $line'''''
			input q "j/n: "
			if {$q eq {j}} {
				set conts [string map [list $line $line'''''] $conts]
			}
		} elseif {[string range $cline 0 2] eq {§§§}} {
			puts \a$line
			puts $line'''
			input q "j/n: "
			if {$q eq {j}} {
				set conts [string map [list $line $line'''] $conts]
			}
		} elseif {[string range $cline 0 1] eq {°°}} {
			puts \a$line
			puts $line''
			input q "j/n: "
			if {$q eq {j}} {
				set conts [string map [list $line $line''] $conts]
			}
		} else {
			puts \a$line
			gets stdin
		}
	}
	if {$conts ne $oconts} {
		puts ****\n$oconts
		puts $conts\n****
		gets stdin
		puts [edit $pt {Bot: Lint-Fehler „Fehlendes End-Tag“ behoben} $conts / minor]
	}
	puts ----
#	gets stdin
}







exit

#set lpt [mysqlsel $db {select * from recentchanges where rc_new or rc_log_type = 'move' order by rc_timestamp;} -list]
#set lpt [mysqlsel $db {select rc_namespace, rc_timestamp, rc_cur_id, rc_title, rc_log_type from recentchanges where rc_new or rc_log_type = 'move' order by rc_timestamp;} -list]

set tt [utc ^ seconds {} %Y%m%d {-1 day}]235959
set ty [utc ^ seconds {} %Y%m%d {-30 days}]000000

puts $tt:$ty


set tdiff [expr [utc -> seconds {} %H {}] - [utc ^ seconds {} %H {}]]
set lpt [
	mysqlreceive $db "
		select log_type, log_timestamp, log_namespace, log_title, log_page, log_params
		from logging
		where		log_type in ('create', 'move')
			and	log_timestamp > [utc ^ seconds {} %Y%m%d {-30 days}][expr 24 - $tdiff]0000
			and	log_timestamp < [utc ^ seconds {} %Y%m%d {-1 day}][expr 23 - $tdiff]5959
			and	log_namespace in (0, 2) and log_page not in (
				select page_id
				from page
				where page_namespace in (0, 2) and page_is_redirect
			)
		order by log_timestamp
	;" {type ts ns pt pgid params} {
		set pt [sql -> $pt]
		set tgt [expr {$ns == 2 ? "Benutzer:$pt" : $pt}]
#		puts "$type $ts $ns $pgid $pt $params"
		if {$type eq {move}} {
			regexp -- {;(.*)} $params -- tgt1
			regexp -- {"(.*?)";s} $tgt1 -- tgt
		}
		if ![nstodns [lindex [split $tgt :] 0]] {
			lappend ll [
				list type [
					expr {$type eq {create} ? {crea} : $type}
				] ns $ns pageid $pgid timestamp [
					utc -> $ts %Y%m%d%H%M%S %Y-%m-%dT%TZ {}
				] title $tgt
			]
		}
	}
]

puts [join $ll \n]

set f [open rc/rc[utc ^ seconds {} %Y%m%d {-1 day}].b.db w] ; puts $f [join $ll \n] ; close $f






exit

foreach l [join $ll \n] {
	puts $l
}
puts [llength $ll]
puts \n[lindex $ll 0]















exit

set schwab {{{Information
|Beschreibung     = Beschreibung: siehe Fototitel – '''Beachte: die Titel sind weitgehend original und können zeitgenössische Begriffe oder Ansichten wiedergeben, sie sollten nicht unreflektiert in Texte übernommen werden.'''
|Quelle           = CD-ROM ''Deutsche Kolonien in Farbfotografien''  ISBN-13: 978-3-89853-344-7
|Urheber          = Fotograf im einzelnen unbekannt: Dr. Robert Lohmeyer (geb. 1879), Bruno Marquardt (1878-1916) und Eduard Kiewning (?)
|Datum            = vor 1910
|Genehmigung      = 
|Andere Versionen = 
|Anmerkungen      = Aus: ''Die deutschen Kolonien.'' Hrsg.: Kurt Schwab unter Mitwirkung von Dr. Fr. Böhme [et. al.] ; Unter künstlerischer Leitung von Bernhard Esch ; Farbenphotographische Aufnahmen von Dr. Robert Lohmeyer, Bruno Marquardt und Eduard Kiewning, Berlin, 1910
}}

{{Bild-PD-alt-100}}}

set xml [[[dom parse -html [getHTML https://de.wikipedia.org/wiki/Spezial:LintErrors/missing-end-tag?namespace=6&limit=5000]] documentElement] asList]
set ltr [lindex $xml 2 1 2 2 2 4 2 4 2 2 2 1 2]
foreach tr $ltr {
	set title [lindex $tr 2 0 2 0 1 3]
	lappend ltitle $title
}
set ltitle [lsort -unique $ltitle]
foreach title $ltitle {
	puts \n----\n$title\n
	set nc [conts t $title x]
	while 1 {
		unset -nocomplain i dsnc
		set snc [split $nc \n]
		unset -nocomplain i
		foreach line $snc {
			lappend dsnc [incr i] $line
		}
		foreach {i line} $dsnc {
			puts "$i: $line"
		}
		input q "\nNr.: "
		if {$q eq "s"} {
			regexp -- {\{\{.*\}\}} $nc oc
			set nc [string map [list $oc $schwab] $nc]
			break
		} elseif [empty q] {
			break
		}
		set q [dict get $dsnc $q]
		puts \n$q
		input c "\nc: "
		switch $c {
			rrf	{
						set c [string map [list " '''" {} ''' {}] [string trimright $q]]
					}
			rrk	{
						set c [string map [list " ''" {} '' {}] [string trimright $q]]
					}
			rmrf	{
						input m "m: "
						set c [string map [list $m''' $m] [string trimright $q]]
					}
			rmrk	{
						input m "m: "
						set c [string map [list $m'' $m] [string trimright $q]]
					}
			sfk	{
						set c ''[string trimright $q]
					}
			sff	{
						set c '''[string trimright $q]
					}
			sffk	{
						set c '''''[string trimright $q]
					}
			srk	{
						set c [string trimright $q]''
					}
			srkd	{
						set c [string trimright $q].''
					}
			smfk	{
						input m "m: "
						set c [string map [list $m ''$m] [string trimright $q]]
					}
			smff	{
						input m "m: "
						set c [string map [list $m '''$m] [string trimright $q]]
					}
			smffk	{
						input m "m: "
						set c [string map [list $m '''''$m] [string trimright $q]]
					}
			smrk	{
						input m "m: "
						set c [string map [list $m $m''] [string trimright $q]]
					}
			smrkc {
						input m "m: "
						set c [string map [list $m, $m.''] [string trimright $q]]
					}
		}
		set nc [string map [list $q $c] $nc]
		set nc [string map [list "\n\{\{subst:nld\}\}\n" {} "\n\{\{subst:nld\}\}" {}] $nc]
#		puts \n$nc
#		gets stdin
	}
	puts \n$nc
	gets stdin
	puts [edit $title {Bot: Lint-Fehler „Fehlendes End-Tag“ behoben} $nc / minor]
}

exit

		if ![empty Anmerkungen] {gets stdin}
		set batchline {Aus: ''Die deutschen Kolonien.'' Hrsg.: Kurt Schwab unter Mitwirkung von Dr. Fr. Böhme [et. al.] ; Unter künstlerischer Leitung von Bernhard Esch ; Farbenphotographische Aufnahmen von Dr. Robert Lohmeyer, Bruno Marquardt und Eduard Kiewning, Berlin, 1910}
		set batchline0 {Aus: ''Die deutschen Kolonien / Hrsg. Kurt Schwab unter Mitwirkung von Dr. Fr. Böhme [et. al.] ; Unter künstlerischer Leitung von Bernhard Esch ; Farbenphotographische Aufnahmen von Dr. Robert Lohmeyer, Bruno Marquardt und Eduard Kiewning, Berlin, 1910}
		set Beschreibung {siehe Fototitel – '''Beachte: die Titel sind weitgehend original und können zeitgenössische Begriffe oder Ansichten wiedergeben, sie sollten nicht unreflektiert in Texte übernommen werden.'''}
		set Beschreibung0 {siehe Fototitel - Beachte: die Titel sind weitgehend original und können zeitgenössische Begriffe oder Ansichten wiedergeben, sie sollten nicht unreflektiert in Texte übernommen werden.}
		set Beschreibung1 {siehe Fototitel - Beachte: die Titel sind weitgehend original und können zeitgenössische Begriffe oder Ansichten wiedergeben, sie sollten nicht unreflektiert in Texte übernommen werden.'''}
		if {[string first $batchline0 $oc] > -1} {
			set nc [string map [list {|Anmerkungen      = } "|Anmerkungen      = $batchline"] $nc]
		}
		if {[string first $Beschreibung1 $oc] > -1} {
			set nc [string map [list $Beschreibung1 $Beschreibung] $nc]
		}
		if {[string first $Beschreibung0 $oc] > -1} {
			set nc [string map [list $Beschreibung0 $Beschreibung] $nc]
		}
		set nc [string map [list "* batch: $batchline0\n\n" {} "\n\{\{subst:nld\}\}\n" {} "\n\{\{subst:nld\}\}" {}] $nc]
		puts $nc
		puts [edit $title {Bot: Lint-Fehler „Fehlendes End-Tag“ behoben + Kleinigkeiten} $nc / minor]
}



exit

set lp [dict values [regexp -all -inline -- {\{(Datei.*?)\}} $xml]]
puts [lsort $lp]
foreach p [lrange [lsort $lp] 1 end] {
	unset -nocomplain temp ptemp Anmerkungen
#	puts $p
	set oc [conts t $p x]
	if {{batch:} in $oc} {puts $p}
	continue
	regexp -- {\{\{ ?(Information[^\}]*?)\}\}} $oc -- temp
	set ptemp [parse_templ $temp]
	puts $ptemp
	set Anmerkungen [dict get $ptemp Anmerkungen]
	puts $Anmerkungen
	gets stdin
}













exit

set lvetopage [string tolower [dict values [regexp -all -inline -- {\[\[(.*?)\]\]} [conts id 3396115 1]]]]
set lspokencat [string tolower [cat {Kategorie:Wikipedia:Gesprochener Artikel} 0]]

if {$argv eq {e}} {set id 983688} elseif {$argv eq {l}} {set id 3352903}

set nconts [set conts [conts id $id x]]
set lline [split $conts \n]
foreach line [string map {{2002 AA29|2002 AA<sub>29</sub>} {2002 AA29} {2003 YN107|2003 YN<sub>107</sub>} {2003 YN107}} $lline] {
	if {[string index $line 0] eq {#}} {
		lassign {0 {} {} {}} dates talkconts ldate
		puts [incr i]:$line
		if {[string first {2002 AA29} $line] > -1} {
			set page {2002 AA29}
		} elseif {[string first {2003 YN107} $line] > -1} {
			set page {2003 YN107}
		} else {
			regexp -- {\[\[(.*?)\]\]} $line -- page
		}
		set dates [lindex [regexp -all -inline -- {<small>(.*?)</small>} $line] end]
		set nrs [regexp -all -- {\d} $dates]
		if {[string first | $page] > -1} {puts pipe ; gets stdin ; continue}
		if [redirect $page] {gets stdin ; continue}
		set talkconts [conts t Diskussion:$page 0]
		set lrex [lsort -decreasing [regexp -all -inline -- {\{\{.*?\}\}} $talkconts]]
		foreach rex $lrex {
			set parsetempl [parse_templ $rex]
			dict with parsetempl {
				switch $TEMPLATE {
					{War AdW} {
						switch [llength $1] {
							1 {set wdate1 "$1 [lrange $2 1 2]"}
							2 {set wdate1 "$1 [lindex $2 end]"}
							3 {set wdate1 $1}
						}
						lappend ldate [utc ^ $wdate1 {%e. %B %Y} {%d.%m.%Y} {}]−[utc ^ $2 {%e. %B %Y} {%d.%m.%Y} {}]
					}
					{War AdT} {
						if {[expr ([llength $parsetempl] - 2) / 2] != [expr $nrs / 8]} {
							puts "unterschiedliche Mengen"
						}
						foreach date [dict values [lrange $parsetempl 2 end]] {
							lappend ldate [utc ^ $date {%e. %B %Y} {%d.%m.%Y} {}]
						}
					}
					{AdT-Vorschlag Hinweis}	{
						lappend ldate ''[utc ^ $Datum {%e. %B %Y} {%d.%m.%Y} {}]''
					}
				}
			}
		}
		set lowpage [string tolower $page]
		set sveto { <small>([[WP:ADT/V/HAV|Veto]])</small>}
		if {$page eq {2002 AA29}} {
			set page {2002 AA29|2002 AA<sub>29</sub>}
		} elseif {$page eq {2003 YN107}} {
			set page {2003 YN107|2003 YN<sub>107</sub>}
		}
		set nline "#[expr {$lowpage in $lspokencat ? { {{Gesprochen}}} : {}}][expr {[empty ldate] ? " '''\[\[$page\]\]'''" : [string first ' $ldate] > -1 ? " ''\[\[$page\]\]''" : " \[\[$page\]\]"}][expr {$lowpage in $lvetopage ? $sveto : {}}][expr {![empty ldate] ? " − <small>[join $ldate { + }]</small>" : {}}]"
		puts $nline\n
		set nconts [string map [list $line $nline] $nconts]
	}
}
puts [edid $id {Bot: Aktualisierung} $nconts / minor]



exit

set lsect [get [post $wiki {*}$parse / pageid 3352903 / prop sections] parse sections]
for {set nr 1} {$nr <= 8} {incr nr} {
	foreach sect $lsect {
		dict with sect {
			if {[string first $nr. $number] > -1} {
				lappend lnsect [string map -nocase {ä a ö o ü u ß ss ( {} {der schweiz} schweiz} [string tolower $line]] [conts id 3352903 $index]
			}
		}
	}
	set lnsect [lsort -stride 2 $lnsect]
	puts \n
	foreach {1 2} $lnsect {puts $1}
	foreach sect $lsect {
		dict with sect {
			if {$number eq "$nr"} {
				set topline $line
			}
		}
	}
	lappend llsect $topline $lnsect
	unset -nocomplain lnsect
}



#puts $lnsect

exit

puts $lsect

exit

set conts [conts id 3352903 x]
set conts1 [conts id 3352903 1]


puts $conts1

#puts [edid 983688 {Bot: aufgeräumt} $conts / minor]

exit

set lpage [mysqlsel $db {select page_title from page join templatelinks on tl_from = page_id where !page_namespace and !tl_from_namespace and tl_title = 'Navigationsleiste_Flüsse_Albaniens' order by page_title;} -flatlist]

foreach page $lpage {
   set nc [conts t $page x]
   set nc [string map {{{{Navigationsleiste Fluss in der Zentralafrikanischen Republik}}} {}} $nc]
   set nc [string map {{{{Navigationsleiste Fluss im Tschad}}} {}} $nc]
   set nc [string map {{{{Navigationsleiste Fluss in Kamerun}}} {}} $nc]
   set nc [string map {{{{Navigationsleiste Flüsse Albaniens}}} {}} $nc]
   set nc [string map [list \n\n\n\n\n\n \n\n \n\n\n\n\n \n\n \n\n\n\n \n\n \n\n\n \n\n] $nc]
   puts [edit $page {Bot: Navigationsleiste(n) gelöscht, siehe [[Wikipedia:Löschkandidaten/11. November 2018#Fluss-Navis (gelöscht)|Löschdiskussion]]} $nc / minor]
}





exit

for {set jahr 1886} {$jahr <= 2023} {incr jahr} {}

set lpage [insource Carambolage/ 0]
puts $lpage


#set page $argv
#foreach page $lpage {}

#set lpage [mysqlsel $db {select page_title from page where page_title like 'Liste_der_Biografien/%' and !page_namespace order by page_title;} -flatlist]

#foreach page $lpage {}
#set page "Weltmeisterschaften $jahr"
#if [catch {set oc [conts t $page x]}] {continue}

foreach page $lpage {
puts $page
input jn "ja/nein? "
if {$jn ne {j}} {continue}
set oc [conts t $page x]
puts [regexp -all -- {Carambolage} $oc]

set nc [string map {{[[Carambolage]]-Billardspieler} {[[Karambolage (Billard)|Karambolagespieler]]} {[[Carambolage]]spieler} {[[Karambolage (Billard)|Karambolagespieler]]} {Infobox Carambolageturnier} {Infobox Karambolageturnier} {[[Carambolage#Dreiband|Dreiband]]-Turnier} {[[Karambolage (Billard)#Dreiband|Dreiband-Turnier]]} {[[Carambolage]]variante} {[[Karambolage (Billard)|Karambolagevariante]]} {[[Carambolage]]disziplinen} {[[Karambolage (Billard)|Karambolagedisziplinen]]} {[[Carambolage]]disziplin} {[[Karambolage (Billard)|Karambolagedisziplin]]} {[[Carambolage]]turnier} {[[Karambolage (Billard)|Karambolageturnier]]} Carambolage# {Karambolage (Billard)#} Carambolage-Begriffe Karambolage-Begriffe {Carambolage Legende} {Karambolage Legende} {Navigationsleiste Internationale Meisterschaften im Carambolage} {Navigationsleiste Internationale Meisterschaften im Karambolage} Kategorie:Vorlage:Carambolage Kategorie:Vorlage:Karambolage Kategorie:Carambolage Kategorie:Karambolage {-2017 Carambolage} {-2017 Carambolage} {[[Carambolage]]-Billards} {[[Karambolage (Billard)|Karambolagebillards]]} {[[Carambolage]]-Billard} {[[Karambolage (Billard)|Karambolagebillard]]} :Carambolage :Carambolage (Carambolage)\}\} (Carambolage)\}\} _Carambolage_ _Carambolage_ {[[Carambolage|} {[[Karambolage (Billard)|} {[[Carambolage]]} {[[Karambolage (Billard)|Karambolage]]} Carambolage Karambolage} $oc]

puts [edit $page {Bot: siehe [[Diskussion:Karambolage (Billard)#Schreibweise]]} $nc / minor]


}





exit

set title Vorlage:TabMenu/Doku/TMT/$argv
set oc [conts t $title x]

set old1 {könntest Du den unten stehen Quellcode kopieren nach:<br/><big><big>[{{fullurl:{{#special:MyPage/MyTabMenu}}|action=edit}} '''Benutzer:'''''<span style="background:#B0E2FF;">DeinBenutzername</span>'''''/MyTabMenu''']</big></big><br></noinclude><!--}
set old2 {<center><big><big>Hier ist der dazugehörende Quellcode, der für eine eigene Vorlage kopiert werden kann:</big></big></center><br>
<div style="font-family:Courier New; font-size:0.93em; background-color:#EEEED1; padding: 0em 1em 0em 1em; border-top:solid 1px #000000;border-right:solid 1px #000000; border-bottom:solid 1px #000000; border-left:solid 1px #000000;">}
set new1 {könntest Du den unten stehen Quellcode kopieren nach:<br /><span style="font-size:large;">[{{fullurl:{{#special:MyPage/MyTabMenu}}|action=edit}} '''Benutzer:'''''<span style="background:#B0E2FF;">DeinBenutzername</span>'''''/MyTabMenu''']</span><br /></noinclude><!--}
set new2 {{{center|1=<span style="font-size:larger;">Hier ist der dazugehörende Quellcode, der für eine eigene Vorlage kopiert werden kann:</span>}}<br />
<div style="font-family:Courier New; font-size:0.93em; background-color:#EEEED1; padding:0em 1em 0em 1em; border-top:solid 1px #000000; border-right:solid 1px #000000; border-bottom:solid 1px #000000; border-left:solid 1px #000000;">}

puts [edit $title {HTML-Validierung} [string map [list $old1 $new1 $old2 $new2] $oc] / minor]

exit

set offset {}
set cc 0
set lpt [mysqlsel $db "select page_title from page join templatelinks on page_id = tl_from where tl_from_namespace = 100 and tl_namespace = 10 and tl_title = 'Commonscat' order by page_title;" -flatlist]
set db [get_db commonswiki]
foreach pt $lpt {
	if {[string first /Archiv $pt] > -1} {continue}
	if {$pt eq $offset} {set offset {}}
	if {$offset eq {}} {
		set pt1 [sql -> $pt]
		set pt Portal:[sql -> $pt]
		if [catch {
			set rex [dict values [regexp -all -inline -nocase -- {\{\{(Commonscat.*?)\}\}} [set oc [conts t $pt x]]]]
		}] {set f [open test.err a] ; puts $f $pt ; close $f ; continue}
		if {[llength $rex] > 1} {
			set f [open test.err.db a] ; puts $f $pt:$rex ; close $f
			continue
		}
		puts $pt:[set templ [join $rex]]
		if {[string trim $templ] in {Commonscat commonscat}} {
			set c_templ $pt
			set cc 1
		} else {
			set c_templ [string trim [lindex [split $templ |] 1]]
		}
#	set res {}
#	lappend res $pt $c_templ
#	set lang commons ; source langwiki.tcl
		set c_c [mysqlsel $db "select page_title from page join categorylinks on page_id = cl_from and page_namespace = 14 and cl_to = 'Category_redirects' and page_title = '[sql <- $c_templ]' and page_namespace = 14;" -flatlist]
		puts c_c:$c_c
		if ![empty c_c] {
			if {[llength [split $templ |]] == 2} {set cc 2}
			set lang commons ; source langwiki.tcl
			if [catch {
				regexp -nocase -- {(redirect category.*?|category ?redirect.*?|catredir(ect)?.*?|see ?cat.*?)\}\}} [conts t Category:[sql -> $c_c] x] -- nc_templ
			}] {set f [open test.err a] ; puts $f $pt ; close $f ; continue}
			set nc_templ [lindex [split $nc_templ |] 1]
			set nc_templ [string trim [string trimright $nc_templ \}]]
			set nc_templ [string trim [string map {1= {} Category: {}} $nc_templ]]
			set nc_templ [sql -> $nc_templ]
			set lang de ; source langwiki.tcl
			if {$cc == 1} {
				set nc [string map [list Commonscat Commonscat|$nc_templ|$pt commonscat Commonscat|$nc_templ|$pt] $oc]
			} elseif {$cc == 2} {
				if {$pt1 eq $nc_templ} {
					set nc [string map [list Commonscat|$c_templ Commonscat|$nc_templ commonscat|$c_templ Commonscat|$nc_templ] $oc]
				} else {
					set nc [string map [list Commonscat|$c_templ Commonscat|$nc_templ|$pt1 commonscat|$c_templ Commonscat|$nc_templ|$pt1] $oc]
				}
			} else {
				set nc [string map [list Commonscat|$c_templ Commonscat|$nc_templ commonscat|$c_templ Commonscat|$nc_templ] $oc]
			}
			set c_templ [sql -> $c_templ]
			set summary "Bot: weiterleitende Kategorie in der Vorlage:Commonscat ersetzt: \[\[:c:Category:$c_templ\]\] → \[\[:c:Category:$nc_templ\]\]"
			puts \a$nc\n\n$pt:$templ\n$c_templ→$nc_templ
			if {$nc_templ eq {}} {set f [open test.err.db a] ; puts $f $pt:$rex ; close $f ; continue}
#gets stdin
			puts [edit $pt $summary $nc / minor]
		}
		set cc 0
	}
}



exit


set conts [conts t {Liste der Mitglieder des Württembergischen Landtages 1919 bis 1920} x]
set sconts [split $conts \n]

foreach line $sconts {
	lappend lline [regexp -inline -- {\[\[.*?\]\]} $line]
}

foreach item [lrange [join $lline] 1 end-2] {
	lappend links [dict values [regexp -inline -- {\[\[(.*?)[|\]]} $item]]
}
foreach item [join $links] {
	if ![missing $item] {lappend lblue $item}
}

foreach blue $lblue {
	if {$blue ni {{Laura Schradin} {Amélie von Soden}}} {
		set oconts [conts t $blue x]
		set kat1 [join [regexp -inline -- {\[\[Kategorie:.*?\]\]} $oconts]]
		set kat2 {[[Kategorie:Mitglied der Verfassunggebenden Landesversammlung (Württemberg)]]}
		set nconts [string map [list $kat1 $kat2\n$kat1] $oconts]
		puts [edit $blue {+ [[:Kategorie:Mitglied der Verfassunggebenden Landesversammlung (Württemberg)]]} $nconts / minor]
	}
}



#puts $sconts

exit


set litem [d_query {select ?item where {?item wdt:P27 wd:Q29999. ?item wdt:P569 ?dob. filter(year(?dob) < 1815).}}]
puts $litem
foreach item $litem {
	puts $item:
	set f [open rollback.out a] ; puts $f $item ; close $f
	after 500
	set rollbacktoken [get [post $wiki {*}$format / action query / meta tokens / type rollback] query tokens rollbacktoken]
	set f [open rollback.out a] ; puts $f [get [post $wiki {*}$format / token $rollbacktoken / action rollback / title $item / user TaxonBot / summary {Rollback: → [[Special:Diff/642947230/643410074|Diff]]} / markbot 1]] ; close $f
	if {[incr i] in {1 2 3 4 5}} {gets stdin}
}
exit

foreach item $litem {puts [incr i]:$item; if {$i == 2} {gets stdin}; catch {wb_change_value $item P27 Q29999 Q55}}


exit

set oq Q46856984
set nq Q17488363
set llhoq [d_llinkshere $oq]
foreach lhoq $llhoq {
	puts $lhoq:[wb_get_label $lhoq de]
	if [catch {
		if {$nq ni [wb_get_lq $lhoq P106]} {
			wb_change_value $lhoq P106 $oq $nq
		} else {
			puts Redundanz-Fehler ; exit
		}
	}] {puts Fehler! ; gets stdin}
}

exit

puts [d_query {
select ?item ?itemLabel ?num (count(?sitelink) as ?sitelinks) with {
  select distinct ?item where {
      values ?item_class {wd:Q34 wd:Q183}
          ?item wdt:P27 ?item_class; wdt:P21 wd:Q6581072; wdt:P31 wd:Q5.
            }
            } as %subquery where {
              include %subquery.
                bind(xsd:integer(substr(str(?item), 33)) as ?num).
                  optional {?sitelink schema:about ?item; schema:isPartOf [wikibase:wikiGroup 'wikipedia']}
                    service wikibase:label {bd:serviceParam wikibase:language "de,[AUTO_LANGUAGE]".}
                    } 
                    group by ?item ?itemLabel ?num
                    order by desc(?sitelinks) asc(?num)
                    }]


exit

set p P106
set oq Q985394
set nq Q482980

set lq [d_query [format {
SELECT ?Suffragetten ?SuffragettenLabel WHERE {
  SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en". }
    ?Suffragetten wdt:%s wd:%s.
    }
} $p $oq]]





foreach item $lq {
	puts $item
	wb_change_value $item $p $oq $nq
}


exit

#set query {SELECT ?item WHERE {?item wdt:P27 wd:Q34. ?item wdt:P21 wd:Q6581072. ?item wdt:P31 wd:Q5.}}

set lpt [d_query_wir {Q1037 Q889884}]
puts $lpt
exit
set lq {wd:Q1037 wd:Q889884}

puts [d_query [format {
	select ?item
	where {
		values ?item_class {%s}
		?item wdt:P27 ?item_class.
		?item wdt:P21 wd:Q6581072.
		?item wdt:P31 wd:Q5.
	}
} $lq]]

exit

puts [d_query $query]

exit

while 1 {if ![catch {
	puts [getHTML https://query.wikidata.org/sparql?query=[http::formatQuery $query]]
}] {break}}

exit

while 1 {if ![catch {
http::register https 443 ::tls::socket
set token [http::geturl https://query.wikidata.org/sparql?query=[http::formatQuery $query]]
puts [dict values [regexp -all -inline -- {entity/(Q\d{1,9})} [http::data $token]]]
http::cleanup $token
}] {break}
}



exit

#9306700
#8949000

#puts "[lindex $argv 0 1] - [lindex $argv 0 0]"

#8. Feb. 17:21 UTC

if 0 {
set lpage [dcat list {Liste (Kulturdenkmale in Sachsen)} 0]
foreach page [lsort -unique $lpage] {
	puts $page
	set scont [split [conts t $page x] \n]
	foreach line $scont {
		if {[string first |ID $line] > -1} {
			lappend ld [regexp -inline -- {\d{8}} $line]
		}
	}
}
set ld [lsort -unique $ld]
puts $ld
}



#puts [getHTML [join [dict values [regexp -inline -- {"(.*)"} [getHTML https://cardomap.idu.de/lfds/details.aspx?baseMapId=-1&themeId=3.1&layerName=L16&id=08950988]]]]]
#for {set podn [lindex $argv 0 0]} {$podn >= [lindex $argv 0 1]} {decr podn} {

set odn 0$argv
puts $odn

set link [format {https://denkmalliste.denkmalpflege.sachsen.de/CardoMap/Denkmalliste_Report.aspx?HIDA_Nr=%s&amp;CARDOMAP_TH_TITLE=Denkmale&amp;CARDOMAP_TH_ID=3.1&amp;CARDOMAP_TH_ALIAS=DENKMALE&amp;CARDOMAP_L_ID=L16} $odn]

while 1 {if ![catch {
http::register https 443 ::tls::socket
set token [http::geturl $link -channel [set f [open odnx/$odn.pdf wb]] ; close $f]
http::cleanup $token
}] {break}
}
#}

exit

if [catch {exec pdftotext -raw odnx/$odn.pdf}] {
#	puts "[lindex $argv 0 1] - [lindex $argv 0 0]"
	puts "Error: $odn"
	exec rm odnx/$odn.pdf
} else {
#	puts "[lindex $argv 0 1] - [lindex $argv 0 0]"
	set data [read [set f [open odnx/$odn.txt r]]] ; close $f
	puts Success:$odn
	exec rm odnx/$odn.pdf
}
#}

#http::geturl {https://denkmalliste.denkmalpflege.sachsen.de/CardoMap/Denkmalliste_Report.aspx?HIDA_Nr=08950988&amp;CARDOMAP_TH_TITLE=Denkmale&amp;CARDOMAP_TH_ID=3.1&amp;CARDOMAP_TH_ALIAS=DENKMALE&amp;CARDOMAP_L_ID=L16} -channel [set f [open denkmal.pdf wb]] ; close $f

exit

set wplk Wikipedia:Löschkandidaten
set db [get_db dewiki]
set llktitle [mysqlsel $db {
select page_id
from page join templatelinks on tl_from = page_id
where tl_from_namespace = page_namespace and tl_namespace = 10 and tl_title = 'Löschantragstext';} -flatlist]
mysqlclose $db
foreach pgid $llktitle {
set llkpgid {}
puts $pgid
regexp -line -- {\{\{Löschantragstext\|tag=(\d{1,2})\|monat=(.*?)\|jahr=(\d{4})\|titel=(.*?)\|text=} [conts id $pgid x] -- lkday lkmonth lkyear lklink
set lkpage "$wplk/$lkday. $lkmonth $lkyear"
set sqllkpage '[sql <- "Löschkandidaten/$lkday. $lkmonth $lkyear"]'
puts $lkpage
set db [get_db dewiki]
set llkpg [mysqlsel $db "
select pl_namespace, pl_title
from pagelinks join page on page_id = pl_from
where page_namespace = pl_from_namespace and page_namespace = 4 and page_title = $sqllkpage
;" -flatlist]
foreach {plns plt} $llkpg {
lappend llkpgid [mysqlsel $db "
select page_id
from page
where page_namespace = $plns and page_title = '[sql <- $plt]'
;" -flatlist]
}
mysqlclose $db
set llkpgid [lsort -unique $llkpgid]
lremove llkpgid {}
if {$pgid ni $llkpgid} {
lappend mlkpg [page_title $pgid] $lkpage $lklink
}
}
set lres {}
foreach {lkpgt lkpage lklink} $mlkpg {
lappend lres "* \[\[:$lkpgt\]\]<small> (\[\[$lkpage#$lklink|&#91;&#91;$lkpage&#93;&#93;\]\])</small>"
}
set fdcount [llength $lres]
set fdbranch ";\[\[Datei:Puzzled.svg|30x15px|text-unten|Eintragung fehlt|link=Benutzer:MerlBot/Nicht eingetragener Baustein\]\]&nbsp;Nicht eingetragener Baustein<small> ([tdot $fdcount])</small>"
if $fdcount {set fdblock $fdbranch\n[join $lres \n]} else {set fdblock {}}
set nneconts [set oneconts [conts t "$wplk/Nicht eingetragen" x]]
set mbqsw <!--MB-QSWORKLIST-->
regexp -- {<!--MB-QSWORKLIST-->.*<!--MB-QSWORKLIST-->} $oneconts one
set nneconts [string map [list $one $mbqsw\n$fdblock\n$mbqsw] $nneconts]
if {$nneconts ne $oneconts} {
	puts [edit "$wplk/Nicht eingetragen" "Bot: QSWORKLIST: [tdot $fdcount]" $nneconts / minor]
}
exit
}
mysqlclose $db
puts $llkpgid ; gets stdin
}

exit


set lktitle [sql -> [string trimleft [dnstons $lkns]:$lktitle :]]
puts [incr i]:$lktitle
regexp -line -- {\{\{Löschantragstext\|tag=(\d{1,2})\|monat=(.*?)\|jahr=(\d{4})\|titel=(.*?)\|text=} [conts t $lktitle x] -- lkday lkmonth lkyear lklink
set lkpage "$wplk/$lkday. $lkmonth $lkyear"
lappend lfdkat "* \[\[:$lktitle\]\]<small> (\[\[$lkpage#$lklink|&#91;&#91;$lkpage&#93;&#93;\]\])</small>"
}
puts [join $lfdkat \n]
puts [edit Benutzerin:TaxonBota/Test {} [join $lfdkat \n]]
exit

regexp -- {.*fzbot#ade} [conts t $wplk x] cwplk
set llkpage [dict values [regexp -inline -line -all -- {^\* (?:''')?\[\[/(.*?)\|.*} $cwplk]]
foreach lkpage $llkpage {
puts $wplk/$lkpage
set slkpage [split [conts t $wplk/$lkpage x] \n]
foreach line $slkpage {
if {![string first = $line] && ![blcheck $line]} {
set bltitle {}
set bltitle [bltitle $line]
if ![empty bltitle] {lappend llktitle $bltitle}
}
}
}
set llktitle [lsort -unique $llktitle]
foreach lktitle $llktitle {
puts [incr i]:$lktitle
}
set lwplktns [mysqlsel $db {
select page_title, page_namespace
from page join categorylinks on cl_from = page_id
where page_namespace != 14 and (cl_to = 'Wikipedia:Löschkandidat' or cl_to like 'Wikipedia:Löschkandidat/%')
;} -list]
foreach wplktns [lsort -unique $lwplktns] {
lappend clktitle [string trimleft [dnstons [lindex $wplktns 1]]:[sql -> [lindex $wplktns 0]] :]
}
foreach lktitle $clktitle {
puts [incr j]:$lktitle
}
foreach lktitle $clktitle {
if {$lktitle ni $llktitle} {
puts $lktitle
set dlkdata [lrange [split [regexp -inline -- {\{\{Löschantragstext.*?\}\}} [conts t $lktitle x]] |=] 1 8]
puts $dlkdata

}
}
exit

#puts [getHTML https://www.silbentrennung24.de/?term=Triebwerk/]

set f [open adt.db w] ; close $f
mysqlreceive $db {
	select page_title
	from page join templatelinks on tl_from = page_id
	where !page_namespace and !tl_from_namespace and tl_namespace = 10 and tl_title in ('Lesenswert','Exzellent')
	order by page_title
;} pt {
	lappend lpt $pt
}
foreach pt $lpt {
	catch {
		if {[string first $argv [conts t $pt x]] > -1} {
			puts [incr i]:$pt
			set f [open adt.db a] ; puts $f $i:$pt ; close $f
		}
	}
}

exit

set einl [conts t {Wikipedia:Kempten und Allgäu/Einladung} x]
set cluser {'Benutzer:aus_dem_Allgäu','Benutzer:aus_Oberschwaben','Benutzer:aus_Augsburg','Benutzer:aus_Ulm','Benutzer:aus_Neu-Ulm'}
append cluser ,[dcat sql Benutzer:aus_dem_Allgäu 14]
append cluser ,[dcat sql Benutzer:aus_Oberschwaben 14]
append cluser ,[dcat sql Benutzer:aus_Augsburg 14]
append cluser ,[dcat sql Benutzer:aus_Ulm 14]
append cluser ,[dcat sql Benutzer:aus_Neu-Ulm 14]
#lappend cluser $luser1 $luser2 $luser3 $luser4 $luser5
#set cluser [join $cluser]
set cluser [string trim $cluser ,]
mysqlreceive $db "
	select page_title
	from page join categorylinks on cl_from = page_id
	where page_namespace in (2,3) and cl_to in ([join $cluser ,])
	order by page_title
;" pt {
	if {$pt eq {Bene16/Baustelle_11}} {
		lappend lpt Bene16
	} elseif {[string first Vorlage/ $pt] == -1 && $pt ni {Tobias_"ToMar"_Maier}} {
		lappend lpt $pt
	}
}
set lpt [lsort -unique $lpt]
set einl [string map [list <pre>\n {} \n</pre> {}] $einl]
puts $einl
foreach pt $lpt {
	puts [edit BD:$pt {Bot: Einladung: Neujahrstreffen im [[Wikipedia:Kempten und Allgäu|Allgäu]] (13.01.2018)} {} / appendtext \n\n$einl]
}
exit



set portale [cat {Kategorie:Wikipedia:MerlBot-Listen Typ (NeueArtikel)} x]
foreach portal $portale {
#  if {$portal ne {Portal:Aargau/Bausteine} && !$aaaa} {continue} else {incr aaaa}
#  if {$portal ne {Benutzer:Olaf Kosinsky/Naumann-Stiftung}} {continue} else {set 1x 1}
   while 1 {
      try {
         if {[exec pgrep -cxu taxonbot NeueArtikel1.tc] < 1000} {
            exec ./NeueArtikel1.tcl "[list [list $portal]]" &
            after 1000
            break
         }
      } on 1 {} {exec ./NeueArtikel1.tcl "[list [list $portal]]" & ; after 1000 ; break}
#     if $1x {exit}
   }
}


exit

#set db [get_db dewiki]
#while 1 {if [catch {set db [get_db dewiki]}] {puts 1 ; after 10000 ; continue} else {break}}
set db [get_db dewiki]
puts 1
mysqlclose $db
set db [get_db dewiki]
puts 2
mysqlclose $db
set db [get_db dewiki]
puts 3
mysqlclose $db
set db [get_db dewiki]
puts 4
mysqlclose $db
set db [get_db dewiki]
puts 5
mysqlclose $db
set db [get_db dewiki]
puts 6
while 1 {if [catch {set db [get_db dewiki]}] {puts 6 ; after 10000 ; continue} else {break}}
#set db [get_db dewiki]
puts 7
mysqlclose $db
set db [get_db dewiki]
puts 8
mysqlclose $db
set db [get_db dewiki]
puts 9
mysqlclose $db
set db [get_db dewiki]
puts 10
mysqlclose $db
set db [get_db dewiki]
puts 11
mysqlclose $db
set db [get_db dewiki]
puts 12
mysqlclose $db
set db [get_db dewiki]
puts 13
mysqlclose $db


exit

for {set x 20} {$x <= 30} {incr x} {lappend na NeueArtikel.match/NeueArtikel-11$x}
for {set x 1} {$x <= 19} {incr x} {lappend na NeueArtikel.match/NeueArtikel-12[format %02d $x]}
set na [string map {1219 1219b} $na]
foreach a $na {
	lappend conts [read [set f [open $a r]]] ; close $f
}
set sconts [split $conts \n]
foreach l $sconts {
	if {[string first /leer/ $l] == -1} {
		lappend ll $l
	}
}
set nc [join [join $ll \n]]
set f [open NeueArtikel.match/NeueArtikel-1219 w] ; puts $f $nc ; close $f

exit

mysqlreceive $db1 {select page_title from page where page_title like '%(Zahnarzt%' and !page_namespace;} pt {lappend dcat [sql -> $pt]}

puts $dcat


#set dcat [dcat list Mediziner 0]
foreach page $dcat {
#	input q "$page: j/n"
#	if {$q eq {n}} {continue}
	if {[string first (Zahnarzt $page] > -1} {
		puts \n[incr i]:$page
		set npage [string map {(Zahnarzt (Zahnmediziner} $page]
		puts $npage
		puts \n[get [post $wiki {*}$format {*}$token / action move / from $page / to $npage / reason "Bot: \[\[$page\]\] → \[\[$npage\]\] laut \[\[WP:RM#Klammerlemmafrage\]\]" / movetalk 1 / noredirect 1 / movesubpages 1]]
		source rename.tcl
	}
}



exit

set pl [mysqlsel $db {
	select page_title
	from page
	where !page_namespace and !page_is_redirect
;} -flatlist]
set pl [lsort $pl]

foreach p $pl {
	puts $p
	if [missing $p] {continue}
	while 1 {
		if ![catch {
			set lconts [string tolower [set conts [conts t $p x]]]
			if {[string first masse $lconts] > -1 && ([string first gewicht $lconts] > -1 || [string first achslast $lconts] > -1) && ([string first kp $conts] > -1 || [string first Mp $conts] > -1)} {puts "----- $p" ; set f [open test.out a] ; puts $f $p ; close $f}
		}] {break}
	}
}

exit

set page Liste_der_Sektionen_des_Deutschen_Alpenvereins

set lrex [regexp -all -inline -line -nocase -- {Alpenverein.de: \[https://www.alpenverein.de/DAV-Services/Sektionen-Suche/Detail/\?sectionId=(.*?) Mitgliederzahl (.*?)\]} [set nconts [conts t $page x]]]
puts $lrex
puts [llength $lrex]
foreach {link id name} $lrex {
	set nconts [string map [list $link [format {{{DAV-Sektion|%s|NAME=%s}}} $id $name]] $nconts]
}
puts $nconts
puts [edit $page {Bot: Mitglieder-Links auf [[:Vorlage:DAV-Sektion]] umgestellt} $nconts]

exit

set lt [scat {Ort in Nordamerika} 0]
foreach t $lt {
	puts [edit $t {Bot: Linkkorrektur [[Kaukasische Rasse]] → [[White people]]} [string map [list "\[\[Kaukasische Rasse" "\[\[White people"] [conts t $t x]]]
}



exit

#set lt1 [dcat sqllist {Liste (Kulturdenkmale in Sachsen)} 0]
set lt2 [mysqlsel $db {
	select page_title
	from templatelinks join page on tl_from = page_id
	where !tl_from_namespace and tl_namespace = 10 and tl_title = 'Denkmalliste_Sachsen_Tabellenzeile' and !page_namespace
;} -list]
foreach t [lsort $lt2] {
	lassign {} nlc lsline res
	set lc [split [conts t $t x] \n]
	foreach c $lc {
		if {[string index [string trim $c] 0] eq {|}} {lappend nlc $c}
	}
	foreach c $nlc {
		lappend lsline [split $c |=]
	}
	foreach col $lsline {
		if {[string trim [lindex $col 1]] in {Name NS Datierung Beschreibung} && [string trim [lindex $col 2]] eq {}} {
			lappend res $col
			break
		}
	}
	if ![empty res] {lappend lt "* \[\[[sql -> $t]\]\]"}
}

puts [edit user:Z_thomas/Kulturdenkmallisten_Sachsen {alphabetisch} [join $lt \n]]

exit

set nconts [set oconts [conts t BD:Maimaid x]]
set tsformat {%Y-%m-%d %H:%M}
set 7days [utc <- seconds {} $tsformat {-7 days}]

for {set sect 1} {$sect < 100} {incr sect} {
if [catch {
set csect [conts t BD:Maimaid $sect]
if {[string first GiftBot/Ausrufer $csect] > -1} {
set ts [utc <- [string map {Mai Mai.} {*}[dict values [regexp -inline -- {– \[\[Benutzer:GiftBot\|GiftBot\]\].*?(\d\d.*?\d{4})} $csect]]] {%H:%M, %e. %b. %Y} $tsformat {}]
if {[clock scan $ts -format $tsformat] < [clock scan $7days -format $tsformat]} {
lappend lsect [lindex [split $ts -] 0] $csect
}
}
}] {break}
}

foreach {year sect} $lsect {
puts [edit BD:Maimaid/Archiv/$year {Bot: Archivierung des Ausrufers} {} / appendtext \n\n$sect]
puts [edit BD:Maimaid {Bot: Archivierung des Ausrufers} [set oconts [string map [list $sect {}] $oconts]]]}

exit

exec rm spiel.out
exit

set c [regexp -all -inline -line -- {^==.*$} [conts id 1912033 x]]
set d [dict values [regexp -all -inline -- {\[\[(.*?)\]\]} $c]]
foreach e $d {puts $e:\n[conts t Diskussion:$e x] ; gets stdin}

exit

foreach out [glob *.out] {
	set c [read [set f [open $out r]]] ; close $f
	if [catch {if {[string first recent $c] > -1} {puts $out}}] {puts $out}
}

exit

puts [mysqlsel $db "
	select *
	from aft_article_answer
;" -list]



exit

foreach l {B C D E F G H I J K L M N O P R S T U V W Y Z} {
	set title "Liste der Baudenkmale in Potsdam/$l"
	set lid [regexp -all -inline -- {\d{8}(?!,[tT])} [set c [conts t $title x]]]
	set i 0
	foreach id $lid {
		if {[string first {dynaXML Error: Invalid Document} [getHTML http://ns.gis-bldam-brandenburg.de/hida4web/view?docId=obj$id.xml]] > -1} {
			incr i
			set c [string map [list $id\n $id,T\n] $c]
		}
	}
	puts [edit $title "Bot: Replacement of $i broken database links" $c / minor]
}

exit

	puts [getHTML http://ns.gis-bldam-brandenburg.de/hida4web/view?docId=obj09155809.xml]
exit
}

exit

set oc [conts t [set title {Liste der Baudenkmale in Potsdam/Z}] x]
regexp -- {\|-[ ]?\n\|.*?\|\}} $oc otab
regsub -all -- {\|\|(siehe|data| Die)} $otab "\n| \\1" otab
#puts $otab
regsub -all -- {\n(?!\|)} $otab ~~ otab
set otab [string map {{[[Kolonist]]enhaus} {[[Kolonisation|Kolonistenhaus]]}} $otab]
set otab [string map {{[[Wissenschafts- und Restaurierungszentrum]]} {[[Liste der Baudenkmale in Potsdam/SPSG|Wissenschafts- und Restaurierungszentrum]]}} $otab]
set lotab [split $otab \n]
foreach {o1 o2 o3 o4 o5 o6 --} [lrange $lotab 1 end-1] {
	set tr {{Denkmalliste Brandenburg Tabellenzeile}}
	if {[regexp -all -inline -- {\d{8}} $o1] > 0} {
		lappend tr "| Id              = [regexp -inline -- {\d{8}} $o1]"
	} else {
		lappend tr "| Id              = "
	}
	regexp -- {\|(.*)(\{\{Coord.*)} $o3 -- o312 o33
	set o312 [lreverse [split $o312 |]]
	lappend tr "| Adresse         = [string trim [string trimleft $o2 |]]<br />[string trim [regsub -all -- {<.*?>} [lindex $o312 0] {}]]"
	lappend tr "| Lage-Sortierung = [string trim [join [dict values [regexp -inline -- {"(.*)"} [lindex $o312 1]]]]]"
	set bl {{Hermann Mattern} Finanzamt {Otto von Estorff (Architekt)} Stibadium {Otto Kerwien} {Neuer Garten Potsdam} {Karl Liebknecht} {Bernhard Kellermann} {Robert Neddermeyer} {Wilhelm Staab} Kolonisation {Kietz (Siedlung)} Kaserne UFA Kunstblume Chausseehaus {Bruno H. Bürgel} Krankenhaus {Richard Tauber} {Hans Marchwitza} {Carl Saltzmann} {Ernst Haeckel}}
	set art [join [dict values [regexp -inline -- {\[\[(.*?)[|\]]} $o4]]]
	if {$art in $bl} {set art {}}
#	if {[regexp -inline -- {\d{8}} $o1] eq {09156548}} {set art {}}
	lappend tr "| Artikel         = $art"
	lappend tr "| NS              = [string trim [join [dict values [regexp -inline -- {\|NS=(.*?)\|} $o33]]]]"
	lappend tr "| EW              = [string trim [join [dict values [regexp -inline -- {\|EW=(.*?)\|} $o33]]]]"
	if ![empty art] {
		set lno4 [dict values [regexp -all -inline -- {\[\[(.*?)\]\]} $o4]]
		foreach no4 $lno4 {
			set cno4 [lindex [lreverse [split $no4 |]] 0]
			set o4 [string map [list \[\[$no4\]\] $cno4] $o4]
		}
	}
	lappend tr "| Bezeichnung     = [string trim [string trimleft $o4 |]]"
	lappend tr "| Beschreibung    = [string trim [string trimleft $o5 |]]"
	lappend tr "| Bild            = [string trim [join [dict values [regexp -inline -- {\[\[.*?:(.*?)\|} $o6]]]]"
	if ![empty art] {
		set lcc [split [join [dict values [regexp -inline -- {\{\{([Cc]ommonscat.*?)\}\}} [conts t $art x]]]] |]
		if [empty lcc] {
			set cc {}
		} elseif {[lindex $lcc 1] eq {}} {
			set cc $art
		} else {
			set cc [lindex $lcc 1]
		}
	} else {
		set cc {}
	}
#	if {[regexp -inline -- {\d{8}} $o1] eq {09155120}} {set cc {Schauspielhaus Potsdam}}
	lappend tr "| Commonscat      = $cc"
	lappend tr {}
	lappend ltr \{\{[join $tr \n]\}\}
}
set ntab [string map [list ~~ \n] "== Baudenkmale ==\n\{\{Legende Baudenkmal Brandenburg\}\}\n\n\{\{Denkmalliste Brandenburg Tabellenkopf\|Gemeinde Potsdam\}\}\n[join $ltr \n]\n|\}"]
regexp -- {== Baudenkmale.*?\n\|\}} $oc otab
puts [edit $title {Bot: Baudenkmalliste in Vorlagen gepackt, nach [[WP:Bots/Anfragen#Denkmallisten in Potsdam von normaler Tabellensyntax auf Vorlagen umstellen]] vom 2017-04-18} [string map [list $otab $ntab] $oc]]

exit


foreach tr $lotab {
	set tr [string map [list \{ \\\{ \} \\\} \[ \\\[ \] \\\]] $tr]
	if {[string index $tr 0] eq {|}} {
		if [catch {lappend nlotab $ntr}] {lappend nlotab $tr}
		unset -nocomplain ntr
	} else {
		append ntr $tr
		set ntr [join $ntr]
	}
}

foreach tr $nlotab {
	puts \n$tr
}

puts $nlotab

exit

set datahtml [getHTML https://petscan.wmflabs.org/?psid=1251205]
#set ldata [[[dom parse -html $datahtml] documentElement] asList]
regexp -- {<table.*?</table>} $datahtml table

set xml [[[dom parse -html $table] documentElement] asList]

foreach tr [lindex $xml 2 1 2] {
	set title [lindex $tr 2 1 2 0 2 0 1]
	puts \n$title
	set lct {}
	mysqlreceive $db "
		select cl_to
		from categorylinks, page
		where page_id = cl_from and page_title = '[sql <- $title]' and !page_namespace
	;" ct {
		lappend lct $ct
	}
		if {{Theaterschauspieler} ni $lct} {
			set oc [conts t $title x]
			set nc [string map [list Kategorie:Filmschauspieler\]\] Kategorie:Filmschauspieler\]\]\n\[\[Kategorie:Theaterschauspieler\]\]] $oc]
			if {[incr i] < 10} {gets stdin}
			puts [edit $title {Bot: +[[:Kategorie:Theaterschauspieler]] nach [[WP:Bots/Anfragen#Kategorie:Theaterschauspieler]] vom 2017-08-30} $nc / minor]
		}
}



exit

mysqlreceive $db {
	select page_title
	from page, templatelinks
	where tl_from = page_id and page_namespace = 0 and tl_from_namespace = 0 and tl_namespace = 10 and tl_title = 'Infobox_Tennisspieler';} pt {
	lappend lpt $pt
}

foreach pt $lpt {
	puts [incr i]:$pt:
	regexp -line -- {^.*?Nation.*?=(.*)$} [conts t $pt 0] -- rnplayer
	if {[regexp -all -- {\{\{.*?\}\}} $rnplayer] > 1} {lappend spt "# \[\[[sql -> $pt]\]\]"}
}

set spt [join $spt \n]

set out "Auf folgende Tennisspieler trifft der Sachverhalt mehrerer Nationen zu:\n$spt\n\n== Vergangene Nacht"
set old [conts t user_talk:TaxonBot x]
set new [string map [list {== Vergangene Nacht} $out] $old]

puts [edit user_talk:TaxonBot {} $new]

exit

for {set sect 1} {$sect <= 508} {incr sect} {
	puts \n$sect:
	set sconts [conts id 85626 $sect]
	if {[string index $sconts 0] eq {=} && [string index $sconts 1] eq {=}} {
		puts $sconts
		switch $sect {
			405		{set fdate {08:02, 25. Sep. 2014 (CE}}
			450		{set fdate {20:37, 16. Nov. 2015 (CE}}
			490		{set fdate {20:46, 14. Dez. 2016 (CE}}
			default	{regexp -- {\d\d:\d\d, .*? \(CE} $sconts fdate}
		}
		puts $fdate
		regsub -- {(\. \w{3}) } $fdate {\1. } ndate
		puts $ndate
		set sdate [clock scan $ndate -format {%H:%M, %e. %b. %Y (CE} -timezone :Europe/Berlin -locale de]
		regexp -- {\d{4}} $ndate syear
		puts $sdate
		puts $syear
		lappend lsect $sdate $syear $sconts
	}
}
#puts $conts
set lsect [lsort -stride 3 -index 0 -integer $lsect]
foreach {sdate syear sconts} $lsect {
	lappend nconts $syear $sconts
}
set pconts [conts id 85626 0]\n\n
set oyear 2003
foreach {syear sconts} $nconts {
	if {[expr $syear - $oyear] == 1} {
		append pconts "= $syear =\n"
		set oyear $syear
	}
	append pconts $sconts\n\n
}
puts [string trim $pconts]
puts [edid 85626 {Bot: Seite aufgeräumt und zeitlich geordnet} [string trim $pconts] / minor]
exit

puts [conts id 9468216 4]





exit

set data [read [set f [open wikidata8incommonsinwikidata.out r]]] ; close $f
#set sdata [join [lrange [split $data \n] 0 end-1]]

#set sdata [lrange [split $data \n] 0 end-1]
#puts $sdata
foreach {1 2 3 4} [join [join $data]] {
	lappend ndata $3
#	lappend s1 [split $1 :]
	
}
#foreach item $ndata {lappend lkv "page_title = '$item'"}
#mysqlreceive $db "select page_title from page, templatelinks where tl_from = page_id and tl_title = 'Infobox_Kreditinstitut' and page_namespace = 0 and ([join $lkv { or }]) order by page_title;" pgt {
#	puts $pgt
#}




foreach item $ndata {
	if {$item in {Alte_Leipziger_–_Hallesche Bank_Julius_Bär Dexia Acer Boge_Kompressoren Bonava_Deutschland Böckmann_Fahrzeugwerke CHG-Meridian Colruyt_Group DIC_Asset DVV_Media_Group Euro_Cargo_Rail E_wie_einfach Evian_(Mineralwasser) Gerry_Weber Grass_Valley_(Elektronikunternehmen) Grass_Valley_Germany Hama_(Unternehmen) Host_Hotels_&_Resorts Hyosung_Group Jos._Schneider_Optische_Werke Knippers_Helbig Lloyd_Fonds Matrox_Imaging Monta_(Klebebandwerk) NBCUniversal NPO_«Digitale_Fernsehsysteme» Organismos_Sidirodromon_Ellados Piatnik RMI_Corporation RWE_Rhein-Ruhr_Netzservice Raschig_GmbH Reyher-Schrauben Samsung_C&T_Corporation Sky_Österreich Solar-Fabrik Stadtwerke_Düren Stadtwerke_Neumarkt_in_der_Oberpfalz Studio_Hamburg_Serienwerft_Lüneburg Synaptics Systems_on_Silicon_Manufacturing_Cooperation TEDi THK TeamWorx Telefónica_Europe }} {continue}

#	if {$item in {{Baltischer Lloyd} Haltermann {Lichte Porzellan} {Prisma (Handelsplattform)} {Rosenheimer Verlagshaus}}} {continue}
#	set item {Euro Cargo Rail}
#if {$item ne {Wendy’s} && !$aaa} {continue} else {incr aaa} ; if {$item eq {Wendy’s}} {continue}
	set oconts [conts t $item x]
	set conts [conts t $item 0]
	set lline [split $conts \n]
	foreach line $lline {
		unset -nocomplain df
		if {[string first | $line] > -1 && [string first = $line] > -1 && [string first Logo $line] > -1 && [string first : $line] > -1} {
#			puts $item:$line
#			puts $item ; gets stdin
#			regexp -- {\[\[.*?\:(.*?)[|\]]} $line -- df

			if {[lindex $line 1] ne {Logo} && [lindex $line 1] ne {Logo=} && [lindex $line 0] ne {|Logo}} {puts [list $item $line]}
		}
	}
}
exit
			regsub -line -- {(^.*?=).*$} $line "\\1 [string map {& {\&} _ { }} $df]" nline
#puts \n$item\n$nline
			set snline [split $nline =]
			foreach {1 2} $snline {
				puts [list $item [string trim $2]]
				set f [open wikidata6.out a] ; puts $f [list $item [string trim $2]] ; close $f
			}
#			set nconts [string map [list $line $nline] $oconts]
#			puts \n$item\n$nconts
		}
	}
#	input ers "Ersetzen? "
#	if {$ers eq {n}} {
#		continue
#	} else {
#		puts [edit $item {Bot: Anpassungen an neue Infobox Unternehmen} $nconts / minor]
#	}
#	puts $nconts ; gets stdin
#	puts $logoline
#	gets stdin
}



exit
puts $s1
set f [open wikidata8incommonsinwikidata.out w] ; puts $f [split $s1 \n] ; close $f
exit
foreach 1 $sdata {
	lappend lt [lindex [split $1 :] 2]
}
puts $lt

exit



foreach {1 2} $sdata {lappend lkv "page_title = '$1'"}

mysqlreceive $db "select page_id, page_title, pp_value from page, page_props where pp_page = page_id and ([join $lkv { or }]) and pp_propname = 'wikibase_item' and page_namespace = 0 order by page_title;" {pgid pt ppv} {
	lappend ps $pgid $pt $ppv
#	puts "$pgid $pt $ppv"
}
foreach {pgid pt ppv} $ps {
	catch {
		set claims [get [post $wiki {*}$format / action wbgetclaims / entity $ppv] claims]
		if {{P154} in [dict keys $claims]} {
			puts $pt
			set f [open wikidata8incommonsinwikidata.out a] ; puts $f $pgid:$ppv:$pt:[dict get $sdata $pt] ; close $f
		}
	}
}

exit




set data [read [set f [open wikidata6.out r]]] ; close $f
set sdata [join [lrange [split $data \n] 0 end-1]]
foreach {1 2} $sdata {
	puts $1
	if ![missing File:$2] {
		set f [open wikidata7incommons.out a] ; puts $f [list $1 $2] ; close $f
	} else {
		set f [open wikidata7nicommons.out a] ; puts $f [list $1 $2] ; close $f
	}
}


exit

mysqlreceive $db "select page_title from page, templatelinks where tl_from = page_id and tl_title = 'Infobox_Unternehmen' and page_namespace = 0 order by page_title;" pgt {
	lappend data $pgt
}

set aaa 0
#set data [sqlcat {Wikipedia:Infobox Unternehmen fehlerhaft} 0]
foreach item $data {
#	if {$item in {{Baltischer Lloyd} Haltermann {Lichte Porzellan} {Prisma (Handelsplattform)} {Rosenheimer Verlagshaus}}} {continue}
#	set item {Euro Cargo Rail}
if {$item ne {Wendy’s} && !$aaa} {continue} else {incr aaa} ; if {$item eq {Wendy’s}} {continue}
	set oconts [conts t $item x]
	set conts [conts t $item 0]
	set lline [split $conts \n]
	foreach line $lline {
		unset -nocomplain df
		if {[string first | $line] > -1 && [string first = $line] > -1 && [string first Logo $line] > -1 && [string first : $line] > -1} {
#			puts $item:$line
#			puts $item ; gets stdin
			puts $item
			regexp -- {\[\[.*?\:(.*?)[|\]]} $line -- df
			regsub -line -- {(^.*?=).*$} $line "\\1 [string map {& {\&} _ { }} $df]" nline
#puts \n$item\n$nline
			set snline [split $nline =]
			foreach {1 2} $snline {
				puts [list $item [string trim $2]]
				set f [open wikidata6.out a] ; puts $f [list $item [string trim $2]] ; close $f
			}
#			set nconts [string map [list $line $nline] $oconts]
#			puts \n$item\n$nconts
		}
	}
#	input ers "Ersetzen? "
#	if {$ers eq {n}} {
#		continue
#	} else {
#		puts [edit $item {Bot: Anpassungen an neue Infobox Unternehmen} $nconts / minor]
#	}
#	puts $nconts ; gets stdin
#	puts $logoline
#	gets stdin
}
exit
puts $problems

exit

while 1 {
catch {puts [exec pgrep -c -u taxonbot test.tcl]}
catch {puts [exec pgrep -c -u taxonbot test]}
catch {puts [exec pgrep -c -u taxonbot tes]}
catch {puts [exec pgrep -c -u taxonbot tett]}
#puts exec1:[exec pgrep -c -u taxonbot test.tcl]
#puts exec2:[exec pgrep -c -u taxonbot test]
#puts exec3:[exec pgrep -c -u taxonbot tes]
#puts exec4:[exec pgrep -c -u taxonbot tett]
puts [edit user:TaxonBot/Test8 {} [conts t {user:Doc Taxon/Test8} x]]
after 120000
}
exit

