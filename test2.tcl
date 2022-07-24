#!/usr/bin/tclsh8.7
#exit

set editafter 1

source api.tcl
set lang de ; source langwiki.tcl
set token [login $wiki]
#source procs2.tcl

#source library.tcl
#package require http
#package require tls
#package require tdom
#package require htmlparse

set lins [insource {\>...bRUMMfUß!\]\]\</span\>/} $argv]

#lappend lins $lins1 $lins2


puts $lins


puts [llength [lsort -unique $lins]]

foreach ins [lsort -unique $lins] {
	puts $ins
	set cins [string map {{>...bRUMMfUß!]]</span>} {>...bRUMMfUß!</span>]]}} [conts t $ins x]]
	set zuq {Bot: Tony Award → Tony Awards, siehe [[Portal Diskussion:Theater#Tony Award 20XX oder Tony Awards 20XX?|Portaldiskussion]]}
	puts [edit $ins $zuq $cins / minor]
#	if {[incr i] < 4} {gets stdin}
}



exit

set ltemp [template2 Vorlage:Ff 0]

foreach temp [lsort $ltemp] {
	puts \n$temp
	set conts [conts t $temp x]
	set lrex  [regexp -nocase -all -inline -- {\{\{f.*?\}\}} $conts]
	foreach rex $lrex {
		puts $rex
		puts [set dpt [parse_templ $rex]]
		dict with dpt {
			if {$TEMPLATE in {f ff}} {
				puts Treffer
				if {1 in [dict keys $dpt]} {
					set conts [string map [list $rex "S. $1&nbsp;$TEMPLATE."] $conts]
				} else {
					set conts [string map [list $rex "&nbsp;$TEMPLATE."] $conts]
				}
			}
		}
	}
	puts $conts\n$temp\n$lrex
	gets stdin
	puts [edit $temp {Bot: [[Vorlage:f]] und [[Vorlage:ff]] werden laut Löschdiskussion gelöscht} $conts / minor]
#	gets stdin
}



exit

set lins [insource {\> \'\'Jerchel\'\'\]\] \<\/span\> /} x]

puts [llength $lins]

#exit

set summ {Bot: Überarbeitung veralteter Syntax}
set summ1 {Überarbeitung veralteter Syntax}
set old {> ''Jerchel'']] </span> }
set new {> ''Jerchel'' </span>]] }

foreach ins [lreverse $lins] {
	puts \n$ins:
	set out [edit $ins $summ [string map [list $old $new] [conts t $ins x]] / minor]
	puts $out
	if {{protectedpage} in [split $out]} {
		source api2.tcl ; set lang de1 ; source langwiki.tcl ; #set token [login $wiki]
		puts [edit $ins $summ1 [string map [list $old $new] [conts t $ins x]] / minor]
		after 5000
		source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]
	}
	if {[incr c] <= 5} {gets stdin}
}


exit

set lcat [dcat list {Welterbestätte nach Staat} 14]
puts [lsort $lcat]

foreach cat $lcat {
	if {[string first England $cat] > -1 || [string first Wales $cat] > -1 || [string first Schottland $cat] > -1} {continue}
	set catconts [conts t Kategorie:$cat x]
	set catconts [string map {{Kategoriebeschreibung Weltkulturerbe} {Kategoriebeschreibung Welterbestätte} {Kategoriebeschreibung Weltnaturerbe} {Kategoriebeschreibung Welterbestätte} {Kategorie:Welterbekonvention in Mauritius| Kulurerbe} {Kategorie:Welterbekonvention in Mauritius}} $catconts]
	puts $catconts\n[string length $catconts]
	set scatconts [split $catconts \n]
	foreach line $scatconts {
		if {[string first Kategorie:Welterbekonvention $line] > -1} {
			if {[string first Mauritius $line] > -1} {continue}
#			puts \n$line
			set sline [split $line |]
#			puts $sline
			if {[llength $sline] > 1} {
				set catconts [string map [list $line [lindex $sline 0]\]\]] $catconts]
			}
		}
		if {[string first {Kategorie:Welterbestätte nach Staat} $line] == -1 && [string first Kategorie:Welterbekonvention $line] == -1 && [string first \[\[Kategorie: $line] > -1} {
			set catconts [string map [list \n$line {}] $catconts]
		}
	}
	puts $cat:\n$catconts
	puts [string length $catconts]\n\n\n
	puts [edit Kategorie:$cat {kleine Anpassungen: siehe [[Spezial:Permalink/203153257#Welterbekategorien|Diskussion]]} $catconts / minor]
	if {[incr xxx] < 5} {gets stdin}
}


exit

----

set db [get_db dewiki]
set lpt [mysqlsel $db {
	select page_title from page
	where !page_namespace and page_title like '%)'
;} -flatlist]
mysqlclose $db

#puts $lpt

foreach pt $lpt {
	set lept [string length [string range $pt [string first ( $pt] end]]
#	puts $lept:$pt
	dict lappend dpt $lept $pt
}

set sdpt [lsort -stride 2 -index 0 -integer -decreasing $dpt]

foreach {1 2} $sdpt {
	puts $1:$2
	gets stdin
}

exit
puts [conts t Gaubahn x]




#set lei [embeddedin {Vorlage:Navigationsleiste Deutsche Dampfloks} 0]
set lei [template0 GRC-1822 0]
puts $lei
puts [llength $lei]

foreach ei [lsort $lei] {
	puts $ei
#	puts [edit $ei {Bot: [[:Vorlage:GRC-1828]] → [[:Vorlage:GRC-1822]]} [string map {GRC-1828 GRC-1822} [conts t $ei x]] / minor]
}


exit

proc hls url {
	catch {set c [getHTML $url]} errorlog
	if {[string first https://hls-dhs-dss.ch/de/404 $errorlog] == -1} {
		set html [getHTML https://hls-dhs-dss.ch[lindex $errorlog 3]]
#		set slog [split $errorlog /]
#		set line [lindex $slog 3]:[lindex $slog 4]
#		append_file test2.db $i:$line
	}
	regexp -- {<meta name="description" content="(.*?\. .*?\. .*?\. )} $html -- html
	return $html
}

set t1 Wikipedia:Positivlisten/HLS-Register_00001-08000
set t2 Benutzer:Informationswiedergutmachung/HLS-Register_10001-20000
set t3 Benutzer:Informationswiedergutmachung/HLS-Register_20001-30000
set t4 Benutzer:Informationswiedergutmachung/HLS-Register_30001-40000

if {[lindex $argv 0] eq {r}} {
	set o [conts id 10963622 [lindex $argv 1]]
	set o0 [conts id 10963622 x]
	read_file test3.db n
	puts [edid 10963622 {Bot: Artikel mit Vorlage HLS gestrichen} [string map [list $o $n] $o0]]
	exit
}



set db [get_db dewiki]
mysqlreceive $db {
	select page_title from page join templatelinks on tl_from = page_id
	where !page_namespace and !tl_from_namespace and tl_namespace = 10 and tl_title = 'HLS'
;} pt {
	lappend lpt [sql -> $pt]
}
mysqlclose $db

#foreach t [list $t1 $t2 $t3 $t4] {
#if {$t eq $t1} {
	
	set ln {}
	set so [split [conts t $t1 $argv] \n]
	set npt {}
	foreach line $so {
		if {[string first HLS| $line] > -1 && $npt ne {x}} {
			regexp -- {https.*?.php} $line url
			puts [hls $url]
			puts $line
			input npt {npt: }
			if {$npt eq {}} {
				set nline $line
			} else {
				regexp -- {<span.*} $line rline
				regexp -- {= \[\[(.*?)\]\]} $line -- pt
				if {[lindex $npt 0] eq {..}} {
					set npt "$pt [lrange $npt 1 end]"
				}
				if {$npt in $lpt} {
					set nline [string map [list $rline \[\[$npt|$pt\]\]] $line]
				} else {
					set nline $line
				}
			}
			lappend ln $nline
			puts $nline\n
			append_file test3.db $nline
		} else {
			set nline $line
			lappend ln $nline
			puts $nline\n
			append_file test3.db $nline
		}
	}
	set n [join $ln \n]
	puts $n
	gets stdin
	puts [edit $t {Bot: Artikel mit Vorlage HLS gestrichen} $n]
#}
#}

exit

https://hls-dhs-dss.ch/textes/d/D$i.php

	set n $o
	set so [split $o \n]
	foreach line $so {
		regexp -- {\|.*?\|(.*?)\|} $line -- rline
		if {[string first \[ $rline] > -1} {
			puts $line
			puts $rline
			set nrline [string map {{]], [[} {, }} $rline]
			puts $nrline\n
			set n [string map [list $rline $nrline] $n]
		}
	}
	set n[incr i] $n
	puts $so
}

set summary {Leerzeichen aus Vorlagenparameter geschmissen}

puts [edit $t1 "Bot: $summary" [string map [list {Autor = } Autor= {Autor =} Autor= {Autor= } Autor=] [conts t $t1 x]]]
puts [edit $t2 "Bot: $summary" [string map [list {Autor = } Autor= {Autor =} Autor= {Autor= } Autor=] [conts t $t2 x]]]
puts [edit $t3 "Bot: $summary" [string map [list {Autor = } Autor= {Autor =} Autor= {Autor= } Autor=] [conts t $t3 x]]]
puts [edit $t4 "Bot: $summary" [string map [list {Autor = } Autor= {Autor =} Autor= {Autor= } Autor=] [conts t $t4 x]]]




exit






set o5 [conts t Benutzer:Informationswiedergutmachung/HLS-Register_08001-10000 x]
set o6 [conts t Benutzer:Informationswiedergutmachung/HLS-Register_10001-12000 x]
set o7 [conts t Benutzer:Informationswiedergutmachung/HLS-Register_12001-14000 x]
set o8 [conts t Benutzer:Informationswiedergutmachung/HLS-Register_14001-16000 x]
set o9 [conts t Benutzer:Informationswiedergutmachung/HLS-Register_16001-18000 x]
set oa [conts t Benutzer:Informationswiedergutmachung/HLS-Register_18001-20000 x]
set ob [conts t Benutzer:Informationswiedergutmachung/HLS-Register_20001-22000 x]
set oc [conts t Benutzer:Informationswiedergutmachung/HLS-Register_22001-24000 x]
set od [conts t Benutzer:Informationswiedergutmachung/HLS-Register_24001-26000 x]
set oe [conts t Benutzer:Informationswiedergutmachung/HLS-Register_26001-28000 x]
set of [conts t Benutzer:Informationswiedergutmachung/HLS-Register_28001-30000 x]
set og [conts t Benutzer:Informationswiedergutmachung/HLS-Register_30001-32000 x]
set oh [conts t Benutzer:Informationswiedergutmachung/HLS-Register_32001-34000 x]
set oi [conts t Benutzer:Informationswiedergutmachung/HLS-Register_34001-36000 x]
set oj [conts t Benutzer:Informationswiedergutmachung/HLS-Register_36001-36322 x]

set oall1 $o1\n$o2\n$o3\n$o4\n$o5
set oall2 $o6\n$o7\n$o8\n$o9\n$oa
set oall3 $ob\n$oc\n$od\n$oe\n$of
set oall4 $og\n$oh\n$oi\n$oj


puts [edit user:Informationswiedergutmachung/HLS-Register_00001-10000 {Bot: Liste 1} $oall1]
puts [edit user:Informationswiedergutmachung/HLS-Register_10001-20000 {Bot: Liste 2} $oall2]
puts [edit user:Informationswiedergutmachung/HLS-Register_20001-30000 {Bot: Liste 3} $oall3]
puts [edit user:Informationswiedergutmachung/HLS-Register_30001-40000 {Bot: Liste 4} $oall4]

exit



set o [conts t Benutzer:Informationswiedergutmachung/HLS-Register_36001-36322 x]
set li [dict values [regexp -all -inline -- {\|(\d{5})\|} $o]]
#set li [lrange $li 1245 end]



#set i 6453
foreach i $li {
	catch {set c [getHTML https://hls-dhs-dss.ch/textes/d/D$i.php]} errorlog
	if {[string first https://hls-dhs-dss.ch/de/404 $errorlog] == -1} {
#		set html [getHTML https://hls-dhs-dss.ch[lindex $errorlog 3]]
		set slog [split $errorlog /]
		set line [lindex $slog 3]:[lindex $slog 4]
		puts $line
		append_file test2.db $i:$line
	}
}

exit


#puts $html
		set rauthor [htmlparse::mapEscapes [split [join [dict values [regexp -all -inline -- {<span class="hls-article-author-function">Autorin/Autor:</span>\n(.*?)\n<} $html]] ,] ,]]
puts rauthor:$rauthor
		set lauthor {}
		foreach author $rauthor {
			set author [string trim $author]
			if {$author ne {La rédaction}} {
				if {{[[$author]]} ni $lauthor} {
					lappend lauthor \[\[$author\]\]
				}
			}
		}
		if [empty lauthor] {puts {Error: empty lauthor} ; exit}
		set author [join $lauthor {, }]
		set title [htmlparse::mapEscapes [join [dict values [regexp -inline -- {<title>(.*?)</title>} $html]]]]
		puts $i:$author:$title
exit
		append_file test2.db $i:$author:$title
	}
	incr i
	after 500
}

exit


if {[catch {
set c [getHTML https://hls-dhs-dss.ch/textes/d/D2506.php]
} msg]} {puts "Error: $msg"}
#puts [lindex $c 3]
#set c [getHTML https://www.hls-dhs-dss.ch[lindex $c 3]]
#puts $c

puts 1
#puts $d


exit

proc supercat cat {
	set db [get_db dewiki]
	set lcat [
		mysqlsel $db "
			select cl_to from categorylinks join page on page_id = cl_from
			where page_title = '$cat' and page_namespace = 14
		;" -flatlist
	]
	mysqlclose $db
	return $lcat
}

set ll0 0
set lcat0 [list {Chemie}]

foreach cat0 [lsort $lcat0] {
	lappend lcat [sql <- $cat0]
}
set lcat [list $lcat]
set ll [llength $lcat]

#set i 1
while 1 {
#incr j
foreach cat [join [lrange $lcat $ll0 $ll]] {
	lappend lcat [supercat $cat]
}
set lll [llength $lcat]
set ll0 $ll
if {$ll != $lll} {
	set ll $lll
} else {
	break
}
#if {$j == 3} {set i 0}
}

foreach cat [lsort -unique [join $lcat]] {
	puts [sql -> $cat]
}

exit

set i 0
foreach ll $lcat {
	set lll [llength $ll]
	if {$lll > 1} {
		puts $i:$ll
	} else {
		puts $i:$ll
	}
}
puts $lcat

#foreach cat [join [lrange $lcat $ll0 $ll]] {
#	lappend lcat [supercat $cat]
#}
#set ll0 $ll
#set ll [llength $lcat]


#foreach cat [lindex $lcat end] {
#	lappend lcat [supercat $cat]
#}


#puts $lcat











exit

#exec ./test.tcl "8949000 8949410" &

set db [read [set f [open rc/rc20190109.b.db r]]] ; close $f
set lline [lrange [split $db \n] 0 end-1]

#puts $lline
foreach line $lline {
	dict with line {
		dict lappend dline $pageid $line
	}
}

foreach {pageid lline} [lsort -integer -stride 2 $dline] {
	set jlline [join $lline]
	if {[lsearch -integer $jlline crea] > -1 || [lsearch -integer $jlline 2] > -1} {
		puts $lline
		set line1 [lindex $lline 0]
		dict with line1 {
			puts $pageid:$timestamp
		}
	}
}


#puts $dline


exit

lassign {
	2053793 10293407 10293412 10297181 10293413 10297615 7713988 10297617
} id_f_all id_f_allgemein id_f_fuf id_f_musik id_f_sport id_fuf id_musik id_sport
lassign [
	list [
		regexp -all -inline -line -- {(• <small>\d.\.\d.\.</small>).*} [conts id $id_f_all x]
	] [regexp -all -inline -line -- {•.*} [conts id $id_f_allgemein x]
	] [regexp -all -inline -line -- {•.*} [conts id $id_fuf x]
	] [regexp -all -inline -line -- {•.*} [conts id $id_musik x]
	] [regexp -all -inline -line -- {•.*} [conts id $id_sport x]
	]
] oc_f_all oc_f_allgemein c_fuf c_musik c_sport
foreach {c res f_branch} [list $oc_f_allgemein res_f_allgemein '''Allgemein:''' $c_fuf res_fuf {'''Film und Fernsehen:'''} $c_musik res_musik '''Musik:''' $c_sport res_sport '''Sport:'''] {
	if {$res eq {res_f_allgemein}} {
		if ![empty c] {
			lappend lp $f_branch\n[join $c \n]\n
		}
		continue
	}
	set p {}
	foreach {line date} [join [list $oc_f_all $oc_f_allgemein]] {
		set lart [regexp -all -inline -- {\[\[:.*?\]\]} $line]
		set nlart {}
		foreach art $lart {
			if {[string first $art $c] > -1} {lappend nlart $art}
		}
		if ![empty nlart] {lappend p "$date [join $nlart { - }]"}
	}
	if ![empty p] {
		lappend lp $f_branch\n[join $p \n]\n
#		set nconts <!--MB-NeueArtikel-->\n[join [set $res] \n]\n<!--MB-NeueArtikel-->
#	} else {
#		set nconts <!--MB-NeueArtikel-->\n<--MB-NeueArtikel-->
	}
}
#	puts [join $lp \n]
#	exit
set summary "Bot: NeueArtikel: [regexp -all -- {\[\[:} $lp]"
puts [edid 10299091 $summary [join $lp \n] / minor]

