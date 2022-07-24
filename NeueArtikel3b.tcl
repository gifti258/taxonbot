#!/usr/bin/tclsh8.7 
#!/usr/bin/tclsh8.6

#exit

catch {if {[exec pgrep -cxu taxonbot NeueArtikel3b.t] > 1} {exit}}

source api2.tcl
set lang dea ; source langwiki.tcl ; #set token [login $wiki]
source procs.tcl

while 1 {if [catch {set sqldb [get_db dewiki]}] {after 60000 ; continue} else {break}}

set tdiff [expr [utc -> seconds {} %k {}] - [utc ^ seconds {} %k {}]]

set db [get_db dewiki]
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
mysqlclose $sqldb

puts [join $ll \n]

set f [open rc/rc[utc ^ seconds {} %Y%m%d {-1 day}].b.db w] ; puts $f [join $ll \n] ; close $f

set f [open NeueArtikel3.out w] ; close $f

set lportal [cat {Kategorie:Wikipedia:MerlBot-Listen Typ (NeueArtikel)} x]
set dateformat {%Y %m %d}
set ty [utc -> seconds {} %Y%m%d {-1 day}]
set ctday [utc -> seconds {} $dateformat {}]
set tday [utc -> seconds {} %m%d {}]
set db [read [set f [open NeueArtikel.match/@NeueArtikel.db r]]] ; close $f
set idb [read [set f [open NeueArtikel.match/@iNeueArtikel.db r]]] ; close $f

#----
set lline [lrange [split [read [set f [open rc/rc$ty.b.db r]]] \n] 0 end-1] ; close $f
foreach line $lline {
	dict with line {
		dict lappend dline $pageid $line
	}
}
foreach {pageid lline} [lsort -integer -stride 2 $dline] {
	set jlline [join $lline]
	if {[lsearch -integer $jlline crea] > -1 || [lsearch -integer $jlline 2] > -1} {
		set line1 [lindex $lline 0]
		dict with line1 {
			lappend dnew [list pageid $pageid timestamp $timestamp]
		}
	}
}
#----

foreach new $dnew {
	dict with new {
		set ns 1
		set sqldb [get_db dewiki]
		set ns [mysqlsel $sqldb "select page_namespace from page where page_id = $pageid;" -flatlist]
		mysqlclose $sqldb
		if {$ns eq {0}} {
			set hitlist {}
			set pagecats [pagecatid $pageid]
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
			puts $new
			if ![empty hitlist] {
				foreach hitportal [lsort -unique $hitlist] {
					set listformat [dict get $db $hitportal param listformat]
					set title [page_title $pageid]
					set maxTage [dict get $db $hitportal param maxTage]
					if {$maxTage > 29} {set maxTage 29}
					set alt [utc ^ $ctday $dateformat $dateformat "-$maxTage days"]
					set neu [utc ^ $timestamp %Y-%m-%dT%TZ $dateformat {}]
					if {[clock scan $neu -format $dateformat] >= [clock scan $alt -format $dateformat]} {
						set match [list ts $timestamp portal $hitportal hit 1 listformat $listformat title $title alt $alt neu $neu]
						puts $match
						set f [open NeueArtikel.match/NeueArtikel-$tday-b a] ; puts $f $match ; close $f
					}
				}
			}
		}
	}
}

set xxx 0
set data [read [set f [open NeueArtikel.match/NeueArtikel-$tday-b r]]] ; close $f
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
	set f [open NeueArtikel.match/NeueArtikel-$tday-b a] ; puts $f $match ; close $f
}
puts $xxx

puts "\nend of task"
set lang test ; source langwiki.tcl ; #set token [login $wiki]
puts [edid 63277 {Log: MB3} {} / appendtext "\n* '''[clock format [clock seconds] -format %Y-%m-%dT%TZ] NeueArtikel3: Task finished!'''"]

exec ./NeueArtikel3vb.tcl &

exit
