#!/usr/bin/tclsh8.7
#exit

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]
source library.tcl

set yd [utc -> seconds {} %Y%m%d {-1 day}]
set srcdb [split [read [set f [open rc/rc$yd.b.db r]]] \n] ; close $f
foreach rc [lrange $srcdb 0 end-1] {
	lappend rclpid [dict get $rc pageid]
}
set db [get_db dewiki]
set ndlpid [mysqlsel $db "
	select page_id, page_title
	from page join templatelinks on tl_from = page_id
	where page_id in ([join $rclpid ,]) and !page_namespace and !tl_from_namespace and tl_namespace = 10 and tl_title = 'Normdaten'
;" -flatlist]
set pdlpid [mysqlsel $db "
	select page_id
	from page join templatelinks on tl_from = page_id
	where page_id in ([join $rclpid ,]) and !page_namespace and !tl_from_namespace and tl_namespace = 10 and tl_title = 'Personendaten'
;" -flatlist]
set catlpid [mysqlsel $db "
	select page_id
	from page join categorylinks on cl_from = page_id
	where page_id in ([join $rclpid ,]) and !page_namespace and cl_to in ('Frau','Mann','Intersexueller','Transgender-Person','Transsexuelle_Person','Geschlecht_unbekannt')
;" -flatlist]
mysqlclose $db

foreach {ndpid ndpt} $ndlpid {
	if {$ndpid ni $pdlpid && $ndpid ni $catlpid} {
		lassign {} sparam lparam
		while 1 {if ![catch {set oconts [conts id $ndpid x]}] {break}}
		set soconts [split $oconts \n]
		set lnd [lindex $soconts [set lnd0 [lsearch -glob -nocase $soconts *Normdaten*TYP*]]]
		regexp -nocase -- {\{\{ ?(Normdaten[^\}]*?)\}\}} $lnd -- tpnd
		if {[string first \{ $tpnd] > -1 || [string first \} $tpnd] > -1} {set f [open normdaten.err a] ; puts $f $ndpt:Klammerfehler! ; close $f ; continue}
		set stpnd [split $tpnd |]
		foreach param $stpnd {
			lappend sparam [split $param =]
		}
		foreach param $sparam {
			if {[llength $param] == 2} {
				if {[string first TYP $param] > -1 || [string first GNDfehlt $param] > -1 || [string first GNDCheck $param] > -1} {continue}
				lappend lparam $param
			}
		}
		set offset 0
		foreach {key value} [join $lparam] {
			set value [string trim $value]
			if ![empty value] {set offset 1}
		}
		if !$offset {
			set lndm [lindex $soconts [expr $lnd0 - 1]]
			set lnd1 [lindex $soconts [expr $lnd0 + 1]]
			set lnd2 [lindex $soconts [expr $lnd0 + 2]]
			set tlndm [string trim $lndm]
			set tlnd1 [string trim $lnd1]
			set tlnd2 [string trim $lnd2]
			if {$tlndm eq {} && $tlnd1 eq {} && $tlnd2 eq {}} {
				set nconts [string map [list $lndm\n$lnd\n$lnd1\n$lnd2 {}] $oconts]
			} elseif {$tlndm ne {} && $tlnd1 eq {} && $tlnd2 eq {}} {
				set nconts [string map [list $lnd\n$lnd1\n$lnd2 {}] $oconts]
			} elseif {$tlndm eq {} && $tlnd1 eq {} && $tlnd2 ne {}} {
				set nconts [string map [list $lndm\n$lnd\n$lnd1 {}] $oconts]
			} elseif {$tlndm eq {} && $tlnd1 ne {} && $tlnd2 ne {}} {
				set nconts [string map [list $lndm\n$lnd {}] $oconts]
			} elseif {$tlndm ne {} && $tlnd1 eq {} && $tlnd2 ne {}} {
				set nconts [string map [list $lnd\n$lnd1 {}] $oconts]
			} elseif {$tlndm ne {} && $tlnd1 ne {} && $tlnd2 ne {}} {
				set nconts [string map [list $lnd {}] $oconts]
			} else {
				set f [open normdaten.err a] ; puts $f $ndpt:Trefferfehler! ; close $f
				continue
			}
			puts [edid $ndpid {Bot: leere Normdatenvorlage entfernt} $nconts / minor]
		}
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

