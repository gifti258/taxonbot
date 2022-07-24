#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

#exit

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]

if {[utc -> seconds {} %k {}] % 2 == 1} {exit}

set content_orig [contents t [set page Wikipedia:Vandalismusmeldung] x]
set tsm [clock scan [lrange [split $t { :}] 0 2] -format {%d.%m.%Y %H %M}]
set 0content [content [post $wiki {*}$get / titles $page / rvsection 0]]
foreach levels [get [post $wiki {*}$parse / page $page / prop sections] parse sections] {
	dict with levels {if {$level == 2} {lappend items [list index $index line $line]}}
}
foreach item $items {
	dict with item {
		dict append item content [contents t $page $index]
		set tss {}
		foreach ts [lsearch -all -regexp [set splits [split $contents]] {^[:]?\d{2}:\d{2},$}] {
			if [catch {
				lappend tss [clock scan [
					set tsv [string map {Mai Mai. \) {}} [lrange $splits $ts $ts+3]]
				] -format "[expr {[string first : $tsv] == 0 ? {:} : {}}]%H:%M, %d. %b. %Y" -timezone :Europe/Berlin -locale de]
			}] {continue}
		}
		lassign {0 1 0 1} erl remains countdown mind
		if {[llength $tss] == 0} {
			lassign [list $tsm $tsm] tsstart tsstop
		} elseif {[llength $tss] < 2} {
			lassign [list $tss $tss] tsstart tsstop
			decr mind
		} else {
			foreach var1 {tsstart tsstop} var2 [list [lindex $tss 0] [lindex [lsort -integer $tss] end]] {set $var1 $var2}
		}
		if [string match -nocase {*\{\{nicht archivieren*} $contents] {
			puts "index $index nicht archivieren"
		} elseif {[expr $tsm - $tsstop] > 86400} {
			decr remains
#			incr countdown
		} elseif {[expr $tsm - $tsstop] > 7200} {
			decr remains
		}
		set archivepage [clock format $tsstart -format $page/Archiv/%Y/%m/%d -timezone :Europe/Berlin -locale de]
		if {[string match -nocase *\(erl* $line] || [string match -nocase *\{\{erledigt|* $contents]} {incr erl}
		lappend item archivepage $archivepage countdown $countdown remains $remains erl $erl mind $mind
		lappend itemlists $item
	}
}
set staylist [list $page $0content\n\n]
foreach itemlist $itemlists {
	dict with itemlist {
      if {($countdown && $mind) || (!$remains && $erl)} {
			dict append archivepages $archivepage $content\n\n
			dict incr archivecount $archivepage
		} else {
			dict append staylist $page $content\n\n
		}
	}
}
if [exists archivepages] {
	if {[contents t $page x] eq $content_orig} {
		foreach c [dict values $archivecount] {incr cs $c}
		lassign [list [join [dict values $staylist]] [lindex [dict info $archivepages] 0]] staylist archives
		if {$archives == 1} {
#puts "Archivierung von $cs Abschnitt[expr {$cs > 1 ? {en} : {}}] nach \[\[[dict keys $archivepages]\]\]"
			set e [edit $page "Bot: Archivierung von $cs Abschnitt[expr {$cs > 1 ? {en}:{}}] nach \[\[[dict keys $archivepages]\]\]" $staylist]
		} else {
#puts "Archivierung von $cs Abschnitt[expr {$cs > 1 ? {en} : {}}] in $archives Archive"
			set e [edit $page "Bot: Archivierung von $cs Abschnitt[expr {$cs > 1 ? {en}:{}}] in $archives Archive" $staylist]
		}
		puts $e
		if [string match *editconflict* $e] {
			puts "Bearbeitungskonflikt!"
			exit
#			unset -nocomplain -- archivecount archivepages items itemlists staylist e
#			source aa-vm.tcl
		}
		foreach key [dict keys $archivepages] {
			set csa [dict get $archivecount $key]
			set val \n\n[dict get $archivepages $key]
#puts "Archivierung von $cs Abschnitt[expr {$csa > 1 ? {en} : {}}]"
			if [dict exists [page [post $wiki {*}$get / titles $key / prop info]] missing] {
				puts [edit $key "Bot: Archivierung von $csa Abschnitt[expr {$csa > 1 ? {en}:{}}]" \{\{Archiv|$page\}\}$val]
			} else {
				puts [edit $key "Bot: Archivierung von $csa Abschnitt[expr {$csa > 1 ? {en}:{}}]" {} / appendtext $val]
			}
		}
	} else {
		puts "Bearbeitungskonflikt!"
		exit
#		unset -nocomplain -- archivecount archivepages items itemlists staylist
#		source aa-vm.tcl
	}
}
puts {end of task}
