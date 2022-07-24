#!/usr/bin/tclsh8.7 
#!/usr/bin/tclsh8.6

#exit

catch {if {[exec pgrep -cxu taxonbot NeueArtikel3.tc] > 1} {exit}}

source api2.tcl
set lang dea ; source langwiki.tcl ; #set token [login $wiki]
source procs.tcl

while 1 {if [catch {set sqldb [get_db dewiki]}] {after 60000 ; continue} else {break}}

set f [open NeueArtikel3.out w] ; close $f

set lportal [cat {Kategorie:Wikipedia:MerlBot-Listen Typ (NeueArtikel)} x]
set ty [clock format [clock add [clock seconds] -1 day] -format %Y%m%d -timezone :Europe/Berlin]
set tday [clock format [clock seconds] -format %m%d -timezone :Europe/Berlin]
set db [read [set f [open NeueArtikel.match/@NeueArtikel.db r]]] ; close $f
set idb [read [set f [open NeueArtikel.match/@iNeueArtikel.db r]]] ; close $f
set rcdb [read [set f [open rc/rc$ty.a.db r]]] ; close $f
set srcdb [lrange [split $rcdb \n] 0 end-1]
set lastline [lindex $srcdb end]

while 1 {if ![catch {
incr zyx
set f [open NeueArtikel.match/NeueArtikel-$tday w] ; close $f

foreach lrcdb $srcdb {
	dict with lrcdb {
puts lrcdb:$lrcdb
		set sqldb [get_db dewiki]
		set titletest [sql -> [mysqlsel $sqldb "select page_title from page where page_id = $pageid and !page_namespace;" -flatlist]]
		mysqlclose $sqldb
		if {$titletest eq {}} {continue}
		set t1 [clock scan [clock format [clock seconds] -format %Y-%m-%dT%TZ] -format %Y-%m-%dT%TZ -timezone :Europe/Berlin]
		set sqldb [get_db dewiki]
		set rev_list [
			lsort -stride 3 -integer -decreasing [
				mysqlsel $sqldb "
					select rev_id, rev_timestamp, rev_comment
					from revision
					where rev_page = $pageid
				;" -flatlist
			]
		]
		mysqlclose $sqldb
		foreach {rev_id rev_ts rev_comment} $rev_list {
			set t2 [clock scan $rev_ts -format %Y%m%d%H%M%S -timezone :Europe/Berlin]
			if {[string first { verschob die Seite } $rev_comment] > -1 && $ns != 0} {
				regexp -- {(\[\[.*?\]\]).*?(\[\[.*?\]\])} $rev_comment -- rev_src rev_tgt
				if {([string first \[\[Benutzer: $rev_src] > -1 || [string first \[\[Benutzerin: $rev_src] > -1) && ([string first \[\[Benutzer: $rev_tgt] == -1 && [string first \[\[Benutzerin: $rev_tgt] == -1)} {
					break
				}
			}
		}
		if {[expr $t1 - $t2] < 2505600} {
			set hitlist {}
			set pagecats [pagecat $title]
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
							lappend hitlist $portal
						}
					}
				}
			}
			if ![empty hitlist] {
				foreach hitportal [lsort -unique $hitlist] {
					set listformat [dict get $db $hitportal param listformat]
					set dateformat {%Y %m %d}
					set maxTage [dict get $db $hitportal param maxTage]
					if {$maxTage > 29} {set maxTage 29}
					set tloc1 [clock format $t1 -format $dateformat -locale de]
					set tloc2 [clock format [clock add $t1 -$maxTage days] -format $dateformat -locale de]
					set tlocmin [clock scan $tloc2 -format $dateformat -locale de]
					set tdiff [clock add $t1 -$maxTage days]
					if {[string first { verschob die Seite } $rev_comment] > -1 && $ns != 0} {
						lassign {} src tgt
						if {$pageid == 9956898} {set nssrc 0} else {}
						set nssrc [dict get [page [post $wiki {*}$query / prop info / titles [
							set src [join [dict values [regexp -inline -- {\[\[(.*?)\]\]} $rev_comment]]]
						]]] ns]
						set ts [clock format [clock scan $timestamp -format %Y-%m-%dT%TZ] -format $dateformat -locale de]
						if !$nssrc {
							regexp -- {\[\[(.*?)\]\].*?\[\[(.*?)\]\]} $rev_comment -- src tgt
							if {[catch {set t2 [clock scan [dict get [join [
								page [post $wiki {*}$query / prop revisions / titles $tgt / rvdir newer / rvlimit 1] revisions
							]] timestamp] -format %Y-%m-%dT%TZ -timezone :Europe/Berlin]}] == 1} {
								continue
							}
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
						set ts [clock format $t2 -format $dateformat -locale de]
						set hit 1
					} else {
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
puts zyx:$zyx
puts $lrcdb:$lastline
puts [string length $lrcdb]:[string length $lastline]
if {$lrcdb eq $lastline} {puts lastlinebreak}
}] {
	if {$lrcdb eq $lastline} {puts lastlinebreak2}
	puts endbreak ; break
}}
#exit

set xxx 0
set data [read [set f [open NeueArtikel.match/NeueArtikel-$tday r]]] ; close $f
foreach matchportal [split $data \n] {dict with matchportal {lappend lmatchportal $portal}}
set lmatchportal [lsort -unique $lmatchportal]
set restportal $lportal
foreach matchportal $lmatchportal {lremove restportal $matchportal}
set timestamp [clock format [clock add [clock scan $ty -format %Y%m%d] 12 hours] -format %Y-%m-%dT%TZ]
foreach portal $restportal {
	set listformat [dict get $db $portal param listformat]
	set dateformat {%Y %m %d}
	set maxTage [dict get $db $portal param maxTage]
	if {$maxTage > 29} {set maxTage 29}
	set tloc2 [clock format [clock add [clock seconds] -$maxTage days] -format $dateformat -timezone :Europe/Berlin -locale de]
	set ts [clock format [clock scan $timestamp -format %Y-%m-%dT%TZ -timezone :Europe/Berlin] -format $dateformat -locale de]
	set match [list ts $timestamp portal $portal hit 0 listformat $listformat title /leer/ alt $tloc2 neu $ts]
	puts $match ; incr xxx
	set f [open NeueArtikel.match/NeueArtikel-$tday a] ; puts $f $match ; close $f
}
puts $xxx

puts "\nend of task"
set lang test ; source langwiki.tcl ; #set token [login $wiki]
puts [edid 63277 {Log: MB3} {} / appendtext "\n* '''[clock format [clock seconds] -format %Y-%m-%dT%TZ] NeueArtikel3: Task finished!'''"]

exec ./NeueArtikel3v.tcl &

exit
