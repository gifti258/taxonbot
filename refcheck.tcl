#!/usr/bin/tclsh8.7
#exit

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]
source library.tcl

set c [set o [conts id $argv x]]
set match {references responsive=""}
set match0 {references responsive="0"}
set match1 {references responsive="1"}
if {[string first $match $c] > -1 || [string first $match0 $c] > -1 || [string first $match1 $c] > -1} {
	set c [string map [list $match {references responsive} $match0 {references responsive} $match1 {references responsive}] $c]
	after 300000
	if {[conts id $argv x] eq $o} {
		puts \n[page_title $argv]:\n[edid $argv {Bot: Korrektur der Wiki-Syntax nach [[phabricator:T101841]]} $c / minor]
	}
}












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

