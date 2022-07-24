#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

catch {if {[exec pgrep -cxu taxonbot review.tcl] > 1} {exit}}

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]

proc varsubst {var val} {
	global line5 line6 line7 line8 line9 line10 line11 line12
	return [subst $[subst $var$val]]
}
lassign [list [utc -> seconds {} %A {}] [utc -> seconds {} %d.%m.%Y {}] [utc -> seconds {} %d.%m. {}] [utc -> seconds {} %Y-%m-%d {}]] tday tdaydate tdate sqldate
lassign [list [utc <- [utc -> seconds {} %Y%m%d {}]000000 %Y%m%d%H%M%S %Y%m%d%H%M%S {}] [utc -> seconds {} %H:%M {}]] sqltime listtime
while 1 {
	regexp -- {(\d.\.\d.\.\d{4}).*?'''\[\[(.*?)[|\]]} [conts t "Wikipedia:Review/Review des Tages/$tday" x]] -- revdate revlemma
	set revlemma [string toupper $revlemma 0]
	if {$revdate eq $tdaydate} {break} else {puts {Warteschleife "falsches RdT-Datum"} ; after 600000}
}
set listconts [conts t Wikipedia:Review/Liste x]
catch {if {$argv == 0} {set listtime 00:00}}
if {[string first 00:0 $listtime] > -1} {
	set solist [regexp -all -line -inline -- {^\* \d.\.\d.\..*} $listconts]
	set olist [join $solist \n]
	set nlist "* $tdate: \[\[$revlemma\]\]\n[join [lrange $solist 0 end-1] \n]"
	set oconts [string map [list $olist $nlist] $listconts]
} else {
	set oconts $listconts
}
set db [get_db dewiki]
mysqlreceive $db "
	select page_title, page_namespace
	from page, templatelinks
	where tl_from = page_id and page_namespace in (0,100) and tl_from_namespace in (0,100) and tl_namespace = 10 and tl_title = 'Review'
;" {pt pns} {
	if {$pns == 100} {
		lappend lpt [sql -> Portal:$pt]
	} else {
		lappend lpt [sql -> $pt]
	}
}
mysqlclose $db
regexp -- {(\{\{!\}\}-.*?\}\})\}} $oconts -- otab
set lline [split $otab \n]
foreach {line1 line2 line3 line4 line5 line6 line7 line8 line9 line10 line11 line12} [lrange $lline 0 end-1] {
	lappend dtr [join [dict values [regexp -inline -- {\[\[(.*?)\]\]} $line3]]] [
		list line1 $line1 line2 $line2 line3 $line3 line4 $line4 line5 $line5 line6 $line6 line7 $line7 line8 $line8 line9 $line9 line10 $line10 line11 $line11 line12 $line12
	]
}
foreach {trkey trval} $dtr {
	dict with trval {
		if {$trkey in $lpt} {
			if {[string first 00:0 $listtime] > -1 && $trkey eq $revlemma} {
				if {[lindex [set srevlemma [split $revlemma :]] 0] eq {Portal}} {
					lassign [list [lindex $srevlemma 1] 100] strkey ns
				} else {
					lassign [list $trkey 0] strkey ns
				}
				for {set nr 5} {$nr <= 12} {incr nr} {
					if {[string length [varsubst line $nr]] == 5} {
						set db [get_db dewiki]
						mysqlreceive $db "
							select rev_id
							from revision, page
							where page_id = rev_page and rev_timestamp < $sqltime and page_title = '[sql <- $strkey]' and page_namespace = $ns
							order by rev_id desc
							limit 1
						;" rvid {
							dict set trval line$nr "\{\{!\}\} \[\[Spezial:Permalink/$rvid|$sqldate\]\]"
						}
						mysqlclose $db
						break
					}
				}
			}
			lappend drvintab $trkey $trval
		}
	}
}
set lnewrev {}
foreach pt $lpt {
	if {$pt ni [dict keys $drvintab]} {lappend lnewrev $pt}
}
foreach newrev $lnewrev {
puts $newrev
	lassign {0 {}} br revgrv
	cont {revs {
		foreach revision [page $revs revisions] {
			dict with revision {
				set grv [join [dict values [regexp -inline -- {\{\{[Rr]eview\|(\w{1,2}) ?\}\}} [string map {/LP LP} ${*}]]]]
				if ![empty grv] {
					lassign [list $revid $timestamp] revrevid revtimestamp
					if [empty revgrv] {set revgrv $grv}
				} else {
					set revtimestamp [utc -> $revtimestamp %Y-%m-%dT%TZ %Y-%m-%d {}]
					lappend drvintab $newrev [
						list line1 {{{!}}-} line2 "\{\{!\}\} \[\[Spezial:Permalink/$revrevid|$revtimestamp\]\]" line3 "\{\{!\}\} \[\[$newrev\]\]" line4 "\{\{!\}\} \[\[WP:RV$revgrv\#$newrev|RV$revgrv\]\]" line5 {{{!}}} line6 {{{!}}} line7 {{{!}}} line8 {{{!}}} line9 {{{!}}} line10 {{{!}}} line11 {{{!}}} line12 {{{!}}}
					]
					incr br
				}
			}
		}
		if $br {break}
	}} {*}$query / prop revisions / titles $newrev / rvprop ids|timestamp|content / rvlimit 1 / utf8 1
}
foreach {trkey trval} $drvintab {
	lappend ltr [dict values $trval]
	set strval [split [lindex $trval 7] {#|]}]
	dict lappend dtoc [lindex $strval 2] "\n* \[\[[lindex $strval 1]\]\]"
}
lappend ltr {{{{!}}}}
set nconts [string map [list $otab [join [join $ltr] \n]] $oconts]
if {[string first 00:0 $listtime] > -1} {
	set summary {Bot: Review des Tages eingetragen}
} else {
	set summary {Bot: Aktualisierung}
}
set ctoc [conts t Wikipedia:Review x]
set sctoc [regexp -all -inline -- {\| Liste \=\n(.*?)\n\}\}} $ctoc]
set themekey {
	RVG	 Geschichte
	RVS	{Sozial- und Geisteswissenschaft}
	RVK	{Kunst und Kultur}
	RVSP	 Sport
	RVE	 Erdwissenschaften
	RVN	{Naturwissenschaft und Technik}
	RVV	 Verkehr
	RVLP	{Listen und Portale}
}
regexp -- {<!-- THEMENTABELLE -->\n(.*?)\n</div>} $ctoc -- olist
foreach {key theme} $themekey {
	if {$key ni [dict keys $dtoc]} {
		set themeitem "| Liste = \n* "
	} else {
		set themeitem "| Liste = [join [lsort [dict get $dtoc $key]]]"
	}
	lappend themelist \{\{/Themenliste "| Thema = $theme" $themeitem \}\}
}
lappend themelist \{\{/Themenliste "| Thema = QS" \}\}
set nctoc [string map [list $olist [join $themelist \n]] $ctoc]
if {$nctoc ne $ctoc} {
	puts [edit Wikipedia:Review {Bot: Inhaltsaktualisierung} $nctoc / minor]
}
if {$nconts ne $listconts} {
	puts [edit Wikipedia:Review/Liste $summary $nconts / minor]
}
if {[string first 00:0 $listtime] > -1} {
	set lang test ; source langwiki.tcl ; #set token [login $wiki]
	puts [edid 63277 {Log: Review} {} / appendtext "\n* '''[
		clock format [clock seconds] -format %Y-%m-%dT%TZ
	] Review: Task finished!'''"]
}
