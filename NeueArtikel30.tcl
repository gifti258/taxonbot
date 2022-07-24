#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

#exit

source api2.tcl
set lang de ; source langwiki.tcl
source procs.tcl

set token [login $wiki]

set lportal [cat {Kategorie:Wikipedia:MerlBot-Listen Typ (NeueArtikel)} x]
set ty [clock format [clock add [clock seconds] -1 days] -format %Y%m%d]
set tday [clock format [clock seconds] -format %m%d]
set db [read [set f [open NeueArtikel.match/@NeueArtikel.db r]]] ; close $f
set idb [read [set f [open NeueArtikel.match/@iNeueArtikel.db r]]] ; close $f
set rcdb [read [set f [open rc/rc$ty.db r]]] ; close $f

#Arbeitsbereich
#dict with db {
#set xx 0
set rcdb [string map [list \npageid ¶pageid] $rcdb]
set srcdb [split $rcdb ¶]
foreach lrcdb $srcdb {
#continue
#if {[dict get $lrcdb timestamp] eq {2016-08-02T12:15:44Z}} {set xx 1} else {if !$xx {continue}}
#		puts $lrcdb
#		regexp -- {^(.*Z comment) (.*)} $lrcdb -- lrcdb app ; lappend lrcdb [list $app]
#		puts $lrcdb
#		if {[string first 156623489 $lrcdb] > -1} {gets stdin}
	dict with lrcdb {
		if !$ns {
			set t1 [clock seconds]
			if {[catch {set tfirst [dict get [join [
				page [post $wiki {*}$query / prop revisions / titles $title / rvdir newer / rvlimit 1] revisions
			]] timestamp]}] == 1} {
				continue
			}
			set t2 [clock scan $tfirst -format %Y-%m-%dT%TZ -timezone :Europe/Berlin]
			if {[string first {verschob die Seite} $comment] > -1 || [expr $t1 - $t2] < 2592000} {
puts \n$title
				set hitlist {}
				set pagecats [pagecat $title]
puts $pagecats
				foreach {portal iportaldb} $idb {
					set ignore 0
					foreach cat $pagecats {
						if {$cat in $iportaldb} {
							set ignore 1
							break
						}
					}
					if !$ignore {
						foreach cat $pagecats {
							if {$cat in [dict get $db $portal catdb]} {
								puts $portal
								lappend hitlist $portal
							}
						}
					}
				}
				if ![empty hitlist] {
#puts \n$title:$hitlist
					foreach hitportal [lsort -unique $hitlist] {
#puts \n[lsort -unique $hitlist]
#puts $title\n$hitportal
						if {[set listformat [dict get $db $hitportal param listformat]] eq {LIST}} {
							set dateformat {%d. %b}
						} else {
							set dateformat %d.%m.
						}
						set maxTage [dict get $db $hitportal param maxTage]
						set tloc1 [clock format $t1 -format $dateformat -timezone :Europe/Berlin -locale de]
#						set tday [clock format $t1 -format %d]
#			set tloc1l [clock format $t1 -format {%d. %b} -timezone :Europe/Berlin -locale de]
						set tloc2 [clock format [clock add $t1 -$maxTage days] -format $dateformat -timezone :Europe/Berlin -locale de]
						set tlocmin [clock scan $tloc2 -format $dateformat -locale de]
						set tdiff [clock add $t1 -$maxTage days]
						if {[string first {verschob die Seite} $comment] > -1} {
							lassign {} src tgt
							set nssrc [dict get [page [post $wiki {*}$query / prop info / titles [
								set src [join [dict values [regexp -inline -- {\[\[(.*?)\]\]} $comment]]]
							]]] ns]
#				puts :moved:$timestamp
							set ts [clock format [clock scan $timestamp -format %Y-%m-%dT%TZ] -format $dateformat -locale de]
							if !$nssrc {
								regexp -- {\[\[(.*?)\]\].*?\[\[(.*?)\]\]} $comment -- src tgt
								if {[catch {set t2 [clock scan [dict get [join [
									page [post $wiki {*}$query / prop revisions / titles $tgt / rvdir newer / rvlimit 1] revisions
								]] timestamp] -format %Y-%m-%dT%TZ -timezone :Europe/Berlin]}] == 1} {
									continue
								}
#					set olist [string map [list \[\[:$src\]\] \[\[:$tgt\]\]] $olist]
								set hit 3
								if {[expr $t1 - $t2] < [expr $t1 - $tdiff] && {Kategorie:Begriffsklärung} ni [pagecat $tgt]} {
									set ts [clock format $t2 -format $dateformat -locale de]
									set title [list $src $tgt]
								} else {
									set hit 0
								}
							} else {
								set hit 2
							}
						} elseif {[expr $t1 - $t2] < [expr $t1 - $tdiff]} {
#				puts :new:$tfirst
							set ts [clock format $t2 -format $dateformat -locale de]
							set hit 1
						} else {
#				puts :old:$tfirst
							set hit 0
						}
						if $hit {
							set match [list ts $timestamp portal $hitportal hit $hit listformat $listformat title $title alt $tloc2 neu $ts]
							puts $match
							set f [open NeueArtikel.match/NeueArtikel-$tday a] ; puts $f $match ; close $f
						}
					}
				}
			}
		}
	}
}
set data [read [set f [open NeueArtikel.match/NeueArtikel-$tday r]]] ; close $f
foreach matchportal [split $data \n] {dict with matchportal {lappend lmatchportal $portal}}
set lmatchportal [lsort -unique $lmatchportal]
set restportal $lportal
foreach matchportal $lmatchportal {lremove restportal $matchportal}
#puts $restportal ; puts [llength $restportal] ; gets stdin
set timestamp [clock format [clock add [clock scan $ty -format %Y%m%d] 12 hours] -format %Y-%m-%dT%TZ]
foreach portal $restportal {
	if {$portal eq {Benutzer:Wartungsstube/Kulturdenkmal (Sachsen-Anhalt)} || $portal eq {Benutzer:Wartungsstube/Magdeburg} || $portal eq {Benutzer:Wartungsstube/Familienrecht} || $portal eq {Vorlage:Wartung-DC}} {continue}
	if {[set listformat [dict get $db $portal param listformat]] eq {LIST}} {
		set dateformat {%d. %b}
	} else {
		set dateformat %d.%m.
	}
	set maxTage [dict get $db $portal param maxTage]
	set tloc2 [clock format [clock add [clock seconds] -$maxTage days] -format $dateformat -timezone :Europe/Berlin -locale de]
	set ts [clock format [clock scan $timestamp -format %Y-%m-%dT%TZ -timezone :Europe/Berlin] -format $dateformat -locale de]
	set match [list ts $timestamp portal $portal hit 0 listformat $listformat title /leer/ alt $tloc2 neu $ts]
	puts $match ; incr xxx
	set f [open NeueArtikel.match/NeueArtikel-$tday a] ; puts $f $match ; close $f
}
puts $xxx
#set f [open NeueArtikel.match/NeueArtikel$tday a+]
#seek $f 0
#set lline [split [read $f] \n]
#foreach line [lrange $lline 1 end-1] {
#	lappend lportal [dict get $line portal]
#}
#puts $lportal
#close $f

#Arbeitsbereich
exit
puts {initializing extraBrasil.tcl ...}
source extraBrasil.tcl
puts "[clock format [clock seconds] -format %T]:end of task"
