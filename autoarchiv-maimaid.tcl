#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

#exit

#catch {if {[exec pgrep -cxu taxonbot autoarchiv0.tcl] > 1} {exit}}

set editafter 2000
package require math::roman
package require unicode

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]

#set cal(hour) 04

#set data [read [set fl [open aan.out r]]] ; close $fl

#if [regexp -- {end of task} $data] {exit}
#set offset [lindex [regexp -all -inline -- {\.\.\.\n(.*?)\:} $data] end]
#puts $offset

#set offset 8800000

#set cal(hour) 03
#set cal(wday) montags
#set cal(day) 01

#cont {ret1 {
#	foreach item [embeddedin $ret1] {
		set item {pageid 8770412 title {Benutzerin Diskussion:Maimaid}}
		dict with item {if {[catch {
#set title {Wikipedia:Auskunft}
#puts $title
			lassign {{} 0} fb ts1bl
			set rvtitle $title
			if [string match {*edit level sysop*} [
				page [post $wiki {*}$get / titles $title / prop info / inprop protection] protection
			]] {
				puts "\n...\npage $pageid:$title vollgeschützt"
				continue
			}
			lassign {1 {}} ec rvtslist
			while {$ec == 1} {if [catch {
				puts \n...\n$pageid:$title
				lassign {{} 0 {} {} {} 0 {} {} {} {}} props sects paramlists ts0 arcount complarcount arlist rmlist nrlist tgts
				set tsm [clock scan [lrange [split $t { :}] 0 2] -format {%d.%m.%Y %H %M}]
				set ts1 [string trim [clock format [clock seconds] -format {%e. %B} -timezone :Europe/Berlin -locale de]]
				set content_orig [contents t $title x]

				set 0content [contents t $title 0]
				set templates [dict values [
					regexp -all -inline -- {\{\{(Autoarchiv(?!-).*?)\}\}[ ]{0,}[\n]?} [regsub -all -- {\[\[.*?\]\]} [
						string map {{{FULLPAGENAME}} {}} $0content
					] {}]
				]]
				foreach levels [get [post $wiki {*}$parse / page $title / prop sections] parse sections] {
					dict with levels {
						if [string is digit $index] {
							if {$level == 1} {
								set text [join [dict values [regexp -inline -- {^(=.*?)[\n]?\n=} [contents t $title $index]]]]
							}
							if {$level > 1 || [empty text]} {set text [contents t $title $index]}
							if {$level < 3} {lappend props [list lv $level nr $number id $index ln $line tx $text]}
						}
					}
				}
				if [empty props] {
					decr ec
					continue
				}
				foreach prop $props {if {[dict get $prop lv] == 2} {incr sects}}
				foreach template_orig $templates {
					unset -nocomplain Mindestabschnitte Mindestbeiträge Frequenz Kopfvorlage
					regsub -all -- {\[\[.*?\]\]} [string map {\\ {}} $template_orig] {} template
					regsub -all -- {\[.*?\]} $template {} template
					set paramlist_orig [list title $title]
					foreach param [lreplace [split $template |=] 0 0] {lappend paramlist_orig [string trim $param]}
					dict with paramlist_orig {
						if ![exists Mindestabschnitte] {dict set paramlist_orig Mindestabschnitte [set Mindestabschnitte 0]}
						if {$Mindestabschnitte >= $sects} {continue}
						if ![exists Mindestbeiträge] {dict set paramlist_orig Mindestbeiträge 2}
						if [exists Frequenz] {
							set freqs [split $Frequenz ,]
							foreach freq [string trim $freqs] {
								unset -nocomplain daytime
								if [empty freq] {set freq ständig}
								switch -glob $freq {
									*ständig*	{if {$cal(hour) in {00 01 02 03 04 05 12 13 14 15 16 17}} {incr daytime}}
									*morgens*	{if {$cal(hour) in {00 01 02 03 04 05		             }} {incr daytime}}
									*mittags*	{if {$cal(hour) in {               	  12 13 14 15 16 17}} {incr daytime}}
									 default		{if {$cal(hour) in {00 01 02 03 04 05   	             }} {incr daytime}}
								}
								if ![exists daytime] {continue}
								switch -glob $freq [list 																							\
									*$cal(wday)*																				{incr daytime}		\
									*halbmonatlich*	{if {$cal(day) in {01 15}}										{incr daytime}}	\
									*monatlich*			{if {$cal(day) eq {01}}											{incr daytime}}	\
									*halbjährlich*		{if {$cal(day) eq {01}		&& $cal(month) in {01 07}}	{incr daytime}}	\
									*jährlich*			{if {$cal(day) eq {01}		&& $cal(month) eq {01}}		{incr daytime}}	\
									 ständig																						{incr daytime} 	\
									 morgens																						{incr daytime} 	\
									 mittags																						{incr daytime} 	\
								]
								if {$daytime == 2} {
									if ![exists Kopfvorlage] {
										dict set paramlist_orig Kopfvorlage \{\{Archiv|$title\}\}
									} else {
										dict set paramlist_orig Kopfvorlage \{\{$Kopfvorlage\}\}
									}
									lappend paramlists $paramlist_orig
									break
								} else {
									continue
								}
							}
						} else {
							if ![exists Kopfvorlage] {
								dict set paramlist_orig Kopfvorlage \{\{Archiv|$title\}\}
							} else {
								dict set paramlist_orig Kopfvorlage \{\{$Kopfvorlage\}\}
							}
							lappend paramlists $paramlist_orig
						}
					}
				}
				if [empty paramlists] {
					decr ec
					continue
				}
				set p -1
				foreach prop $props {
					incr p
					dict with prop {
						lassign {} tsrs tss
						set tsrs [string map {Mai Mai.} [regexp -all -inline -- {\d{2}:\d{2}, \d{1,2}\. \w{3,4}\.? \d{4}} $tx]]
#						foreach ts [lsearch -all -regexp [set splits [split [regsub -all -- {[\s>]} $tx { }]]] {\d{2}:\d{2},$}] {
#							lappend tsrs [regexp -inline -- {\d{2}:\d{2}, \d{1,2}\. .*? \d{4}} [
#								string map {\u200e {} \) {}} [lrange $splits $ts $ts+3]
#							]]
#						}
						foreach tsr $tsrs {
							if ![empty tsr] {
								if [catch {lappend tss [clock scan $tsr -format {%R, %d. %b. %Y} -timezone :Europe/Berlin -locale de]}] {
									continue
								}
							}
						}
						foreach ts $tss {if ![empty ts0] {if {$ts < $ts0} {set ts0 $ts}} else {set ts0 $ts}}
					}
					lassign {0 0} el na
					if [string match -nocase {*\{\{erledigt|*} $tx] {incr el}
					if {		[string match -nocase {*\{\{nicht archivieren*} $tx]
							|| [string match -nocase {*\{\{Defekter Weblink Bot*} $tx]} {
						incr na
					}
					lset props $p [dict set prop el $el]
					lset props $p [dict set prop na $na]
					lset props $p [dict set prop ts $tss]
				}
				if [empty rvtslist] {
					if {$title eq $rvtitle} {set titlist [list $title]} else {set titlist [list $rvtitle $title]}
					foreach tit $titlist {
						cont {rh {
							foreach rvhist [page $rh revisions] {lappend rvtslist [clock scan [dict values $rvhist] -format %Y-%m-%dT%R:%SZ]}
						}} {*}$get / titles $tit / prop revisions / rvprop timestamp / rvend [expr $ts0 - 3600] / rvlimit max
					}
				}
				set p -1
				foreach prop $props {
					incr p
					dict with prop {
						foreach tst $ts {
							set v 0
							foreach rvts $rvtslist {if {$tst > [expr $rvts - 120] && $tst < [expr $rvts + 60]} {incr v}}
							if !$v {lremove ts $tst}
						}
					}
					set tscount [llength $ts]
					if {$tscount == 0 && [dict get $prop lv] != 1} {
						puts "$title:$ln: Fehler: kein ts"
						lassign [list $tsm $tsm] tsa tse
					} elseif {$tscount < 2} {
						lassign [list $ts $ts] tsa tse
					} else {
						foreach var1 {tsa tse} var2 [list [lindex $ts 0] [lindex [lsort -integer $ts] end]] {set $var1 $var2}
					}
					lset props $p [dict set prop ts [list $tsa $tse]]
					lset props $p [dict set prop tc $tscount]
				}
				foreach paramlist $paramlists {
					lassign {{} 0 0} Modus moderl modalt
					dict with paramlist {
						if [dict exists $paramlist Klein] {set Klein [string tolower $Klein]} else {set Klein nein}
						if [string match -nocase *erledigt* $Modus] {incr moderl}
						if [string match -nocase *alter* $Modus] {incr modalt}
						foreach prop $props {
							dict with prop {
								if {$lv == 1} {continue}
								lassign [list [lindex $ts end] 0 0 0 0] tsend age lock a rsects
								set Alter 0
								if {[expr $tsm - $tsend] > [expr $Alter * 86400]} {incr age}
								if {[string match -nocase *Autoarchiv-Erledigt* $0content] && $el} {lassign {1 0} lock el}
								if {($tc >= ${Mindestbeiträge} || ($moderl && $el)) && !$na && !$lock} {
									set tsstart [lindex $ts 0]
									set m [string trimleft [clocks %m] 0]
									regsub -nocase -- {\(\(Lemma\)\)|\(\(FULLPAGENAME\)\)} [string trim $Ziel '] $title							nZiel
									if {[string first ((Woche $nZiel] > -1 && [clocks %V] > 50 && [clocks %m] eq {01}} {
										regsub -- {\(\(Jahr\)\)}			$nZiel					[expr	 [clocks %Y] - 1]								nZiel
										regsub -- {\(\(Jahr:##\)\)}		$nZiel [format %02d  [expr	 [clocks %y] - 1]]							nZiel
									} else {
										regsub -- {\(\(Jahr\)\)}			$nZiel							 [clocks %Y]									nZiel
										regsub -- {\(\(Jahr:##\)\)}		$nZiel 							 [clocks %y]									nZiel
									}
									regsub -- {\(\(Semester\)\)}			$nZiel					[expr { $m			 <  7 ?	{1}:{2}}]			nZiel
									regsub -- {\(\(Semester:##\)\)}		$nZiel [format %02d	[expr { $m			 <  7 ?	{1}:{2}}]]			nZiel
									regsub -- {\(\(Semester:(i|I)\)\)}	$nZiel					[expr { $m			 <  7 ?	"\\1":"\\1\\1"}]	nZiel
									regsub -- {\(\(Halbjahr\)\)}			$nZiel					[expr { $m			 <  7 ?	{1}:{2}}]			nZiel
									regsub -- {\(\(Halbjahr:##\)\)}		$nZiel [format %02d	[expr { $m			 <  7 ?	{1}:{2}}]]			nZiel
									regsub -- {\(\(Halbjahr:(i|I)\)\)}	$nZiel					[expr { $m			 <  7 ?	"\\1":"\\1\\1"}]	nZiel
									regsub -- {\(\(Quartal\)\)}			$nZiel					[expr { $m			 <= 3 ?	{1}
																														: $m			 <= 6 ?	{2}
																														: $m			 <= 9 ?	{3}:{4}}]			nZiel
									regsub -- {\(\(Quartal:##\)\)}		$nZiel [format %02d	[expr { $m			 <= 3 ?	{1}
																														: $m			 <= 6 ?	{2}
																														: $m			 <= 9 ?	{3}:{4}}]]			nZiel
									regsub -- {\(\(Quartal:i\)\)}			$nZiel					[expr { $m			 <= 3 ?	{i}
																														: $m			 <= 6 ?	{ii}
																														: $m			 <= 9 ?	{iii}:{iv}}]		nZiel
									regsub -- {\(\(Quartal:I\)\)}			$nZiel					[expr { $m			 <= 3 ?	{I}
																														: $m			 <= 6 ?	{II}
																														: $m			 <= 9 ?	{III}:{IV}}]		nZiel
									regsub -- {\(\(Monat\)\)}				$nZiel [string trim			 [clocks %N]			]						nZiel
									regsub -- {\(\(Monat:##\)\)}			$nZiel							 [clocks %m]									nZiel
									regsub -- {\(\(Monat:Kurz\)\)}		$nZiel							 [clocks %b]									nZiel
									regsub -- {\(\(Monat:KURZ\)\)}		$nZiel [string toupper		 [clocks %b]			]						nZiel
									regsub -- {\(\(Monat:kurz\)\)}		$nZiel [string tolower		 [clocks %b]			]						nZiel
									regsub -- {\(\(Monat:Lang\)\)}		$nZiel							 [clocks %B]									nZiel
									regsub -- {\(\(Monat:LANG\)\)}		$nZiel [string toupper		 [clocks %B]			]						nZiel
									regsub -- {\(\(Monat:lang\)\)}		$nZiel [string tolower		 [clocks %B]			]						nZiel
									regsub -- {\(\(Woche\)\)}				$nZiel [string trimleft		 [clocks %V]	 0		]						nZiel
									regsub -- {\(\(Woche:##\)\)}			$nZiel							 [clocks %V]									nZiel
									regsub -- {\(\(Tag\)\)}					$nZiel [string trim			 [clocks %e]			]						nZiel
									regsub -- {\(\(Tag:##\)\)}				$nZiel							 [clocks %d]									nZiel
									regsub -- {\(\(Tag:Kurz\)\)}			$nZiel							 [clocks %a]									nZiel
									regsub -- {\(\(Tag:KURZ\)\)}			$nZiel [string toupper		 [clocks %a]			]						nZiel
									regsub -- {\(\(Tag:kurz\)\)}			$nZiel [string tolower		 [clocks %a]			]						nZiel
									regsub -- {\(\(Tag:Lang\)\)}			$nZiel							 [clocks %A]									nZiel
									regsub -- {\(\(Tag:LANG\)\)}			$nZiel [string toupper		 [clocks %A]			]						nZiel
									regsub -- {\(\(Tag:lang\)\)}			$nZiel [string tolower		 [clocks %A]			]						nZiel
									if {	($moderl && $modalt && $el && $age)
										|| ($moderl && !$modalt && $el)
										|| (!$moderl && $age)} {
										set erltx {:<small>Archivierung dieses Abschnittes wurde gewünscht von: \1</small>}
										if [string match *erledigt|~~~~* $tx] {
											dict append arlist $nZiel \n\n$tx$fb
										} else {
											dict append arlist $nZiel \n\n[string map [list \n\n:<small>Archivierung \n:<small>Archivierung] [
												regsub -nocase -all -- {\{\{erledigt\|(?:1=)?(.*?)\}\}} $tx \n$erltx
											]]$fb
										}
										dict incr arcount $nZiel
										lremove props $prop
										incr complarcount
										incr a
									}
								}
							}
							foreach prop $props {if {[dict get $prop lv] == 2} {incr rsects}}
							if {$Mindestabschnitte >= $rsects} {break}
						}
					}
				}
				if !$ts1bl {
					foreach prop $props {dict with prop {if {$lv == 2} {lappend nrlist $nr}}}
					foreach prop $props {
						set nrdel 0
						dict with prop {
							if {$lv == 1} {
								foreach nr2 $nrlist {if {$nr eq [regsub -- {^(.*)\..*$} $nr2 \\1]} {incr nrdel}}
								if {!$nrdel && ![string match *$ts1* $ln]} {lremove props $prop}
							}
						}
					}
				}
				if {$content_orig eq [contents t $title x]} {
					if {$arlist ne {}} {
						set arprotect 0
						foreach artgt [lsort -unique [dict keys $arlist]] {
							if [catch {
								if {[dict get {*}[
									page [post $wiki {*}$get / titles $artgt / prop info / inprop protection] protection
								] level] eq {sysop}} {
									incr arprotect
								}
							}] {}
							lappend tgts \[\[$artgt\]\]
						}
						if $arprotect {
							puts "\n...\nArchivseite vollgeschützt"
							decr ec
							continue
						}
						set last {*}[page [post $wiki {*}$get / titles $title / prop revisions / rvprop user|timestamp] revisions]
						dict with last {
							set lastrev [clock format [
								clock scan $timestamp -format %Y-%m-%dT%R:%SZ
							] -format "– letzte Bearbeitung: \[\[user:$user|$user\]\] (%d.%m.%Y %R:%S)" -timezone :Europe/Berlin]
						}
						foreach prop $props {lappend rmlist \n\n[dict get $prop tx]}
						set rmsumm "$complarcount Abschnitt[expr {$complarcount > 1 ? {e} : {}}] nach [join $tgts {, }] archiviert $lastrev"
#						puts $rmlist
						puts [set rml [edit $title $rmsumm $0content[join $rmlist {}] {*}[expr {$Klein eq {ja} ? {/ minor} : {}}]]]
						if [string match *editconflict* $rml] {
							continue
						} else {
							decr ec
						}
						foreach {arti artx} $arlist {
							set arct [dict get $arcount $arti]
							set arsumm "$arct  Abschnitt[expr {$arct > 1 ? {e} : {}}] aus \[\[$title\]\] archiviert"
#							puts $arti:\n$artx
							puts [edit $arti $arsumm {} / appendtext [
								expr {[dict exists [page [post $wiki {*}$get / titles $arti / prop info]] missing] == 1 ? "$Kopfvorlage" : {}}
							]$artx]
						}
					}
					decr ec
				}
#				exit
			}] {continue}}
		}] == 1} {
			set lang test ; source langwiki.tcl ; #set token [login $wiki]
			puts [edid 63277 {Log: AA} {} / appendtext "\n* '''[clock format [clock seconds] -format %Y-%m-%dT%TZ] AutoArchiv-Maimaid: Fehler in \[\[:w:de:$title\]\]!'''" / minor]
			set lang de ; source langwiki.tcl ; #set token [login $wiki]
		}}
#	}
#}} {*}$embeddedin / eititle Template:Autoarchiv / eicontinue 1|$offset

puts {end of task}
set lang test ; source langwiki.tcl ; #set token [login $wiki]
puts [edid 63277 {Log: AA} {} / appendtext "\n* '''[clock format [clock seconds] -format %Y-%m-%dT%TZ] AutoArchiv-Maimaid: Task finished!'''" / minor]

exit
