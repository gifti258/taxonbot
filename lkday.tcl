#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

#exit

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]

set nextday [string map [list {/ } / "\{ " "\{" {= } =] [
	clock format [
		clock add [clock seconds] 2 days
	] -format {nextday1 {%e. %B %Y} nextday2 {%Y/%B/%e} nextday3 {Tag=%e|Monat=%N|Jahr=%Y}} -timezone :Europe/Berlin -locale de
]]
dict with nextday {
	set targetlk "Wikipedia:Löschkandidaten/$nextday1"
	set targetkat "Wikipedia:WikiProjekt Kategorien/Diskussionen/$nextday2"
	set targetqs "Wikipedia:Qualitätssicherung/$nextday1"
	if [missing $targetkat] {
		set contentsnewkatday "<noinclude>\n\{\{Wikipedia:WikiProjekt Kategorien/Überschrift|$nextday3\}\}\n</noinclude>\n\n= \[\[$targetkat|Kategorien\]\] =\n"
		puts [edit $targetkat {Bot: Tagesseite angelegt} $contentsnewkatday]
	}
	if [missing $targetlk] {
		for {set add -2} {$add < 4} {incr add} {
			append lday [string map {{/ } / {> } >} \n[clock format [clock add [clock seconds] $add days] -format {|style="background:#EBEBEB; width:14%;"|[[Wikipedia:Löschkandidaten/%e. %B %Y|%e. %B]]} -timezone :Europe/Berlin -locale de]]
		}
		set contentsnewlkday "\{| class=\"centered\" cellpadding=\"0\" cellspacing=\"1\" style=\"background:#FFDEAD; text-align:center; width:90%; font-size:smaller;\"$lday\n|style=\"background:#EBEBEB; width:14%;\"|\[\[Wikipedia:Löschkandidaten/\{\{LOCALDAY\}\}. \{\{LOCALMONTHNAME\}\} \{\{LOCALYEAR\}\}|Heute\]\]\n|\}\n\{\{Löschkandidaten|erl=\}\}\n<!--<nowiki> Hinweis an den letzten Bearbeiter: Wenn alles erledigt ist, hinter \"erl=\" mit --~~~~ signieren. </nowiki>-->\n\n\{\{$targetkat\}\}\n\n= Benutzerseiten =\n\n= Metaseiten =\n\n= Vorlagen =\n\n= Listen =\n\n= Artikel =\n"
		puts [edit $targetlk {Bot: Tagesseite angelegt} $contentsnewlkday]
	}
	if [missing $targetqs] {
		for {set add -2} {$add < 4} {incr add} {
			append lqsday [string map {{/ } / {> } >} \n[clock format [clock add [clock seconds] $add days] -format {|style="background:#EBEBEB; width:14%;"|[[Wikipedia:Qualitätssicherung/%e. %B %Y|%e. %B]]} -timezone :Europe/Berlin -locale de]]
		}
		set contentsnewqsday "\{\{Autoarchiv-Erledigt|Alter=2|Ziel='Wikipedia:Qualitätssicherung/$nextday1/erledigt'|Zeigen=Nein\}\}\n\{| class=\"centered\" cellpadding=\"0\" cellspacing=\"1\" style=\"background:#FFDEAD; text-align:center; width:90%; font-size:smaller;\"$lqsday\n|style=\"background:#EBEBEB; width:14%;\"|\[\[Wikipedia:Qualitätssicherung/\{\{LOCALDAY\}\}. \{\{LOCALMONTHNAME\}\} \{\{LOCALYEAR\}\}|Heute\]\]\n|\}\n\n\{\{QS-Kandidaten\}\}\n__NEWSECTIONLINK__\n<div style=\"text-align:center;\">Die Qualitätssicherung der unten aufgeführten Artikel ist noch nicht abgeschlossen:</div>\n<!-- Hinweis an den letzten Bearbeiter: Wenn alles erledigt ist, obige Zeile durch folgende<nowiki>\n\{\{Wikipedia:Qualitätssicherung/QS erledigt|-- ~~~~\}\}<br />\n</nowiki>ersetzen. Anschließend bitte die Abschnitte aus der /erledigt-Unterseite als Ganzes hierher kopieren und auf die Unterseite einen SLA stellen.-->\n\n"
		puts [edit $targetqs {Bot: Tagesseite angelegt} $contentsnewqsday]
	}
}
for {set x 1} {$x >= -7} {decr x} {
	switch $x {
		0			{
						lappend laufende [clock format [
							clock add [clock scan [lrange $t 0 1] -format {%d.%m.%Y %T}] $x day 1 hour
						] -format {* '''[[/%e. %B %Y|%e. %B]]'''} -timezone :Europe/Berlin -locale de]
					}
		-7			{
						set adate [clock format [
							clock add [clock scan [lrange $t 0 1] -format {%d.%m.%Y %T}] $x day 1 hour
						] -format {* [[/%e. %B %Y|%e. %B]]} -timezone :Europe/Berlin -locale de]
					}
		default	{
						lappend laufende [clock format [
							clock add [clock scan [lrange $t 0 1] -format {%d.%m.%Y %T}] $x day 1 hour
						] -format {* [[/%e. %B %Y|%e. %B]]} -timezone :Europe/Berlin -locale de]
					}
	}
}
set laufende [string map {{/ } / {| } |} $laufende]
set adate [string map {{/ } / {| } |} $adate]
set pageconts [string map [
	list -TODO-->\n\n -TODO-->\n
] [conts t Wikipedia:Löschkandidaten x]]
set sectlaufende [conts t Wikipedia:Löschkandidaten 1]
set sectabarbeit [string map [
	list -TODO-->\n\n -TODO-->\n
] [conts t Wikipedia:Löschkandidaten 2]]
regexp -- {\*.*\]} $sectlaufende lauftab
set nsectabarbeit [string map [list -TODO-->\n -TODO-->\n$adate\n] $sectabarbeit]
set pageconts [string map [
	list $lauftab [join $laufende \n] $sectabarbeit $nsectabarbeit
] $pageconts]
puts [edit Wikipedia:Löschkandidaten {Bot: automatische Aktualisierung} $pageconts / minor]
unset -nocomplain laufende
for {set x 1} {$x >= -7} {decr x} {
	switch $x {
		0			{
						lappend laufende [clock format [
							clock add [clock scan [lrange $t 0 1] -format {%d.%m.%Y %T}] $x day 1 hour
						] -format {* '''[[/Diskussionen/%Y/%B/%e|%e. %B]]'''} -timezone :Europe/Berlin -locale de]
					}
		-7			{
						set adate [clock format [
							clock add [clock scan [lrange $t 0 1] -format {%d.%m.%Y %T}] $x day 1 hour
						] -format {* [[/Diskussionen/%Y/%B/%e|%e. %B]]} -timezone :Europe/Berlin -locale de]
					}
		default	{
						lappend laufende [clock format [
							clock add [clock scan [lrange $t 0 1] -format {%d.%m.%Y %T}] $x day 1 hour
						] -format {* [[/Diskussionen/%Y/%B/%e|%e. %B]]} -timezone :Europe/Berlin -locale de]
					}
	}
}
contents t {Wikipedia:WikiProjekt Kategorien} x
regsub -- {(== Lauf.*?)\*.*?(==.*?TODO-->\n)(\*|\n;)} $contents [string map {{/ } / {| } |} \\1[join $laufende \n]\n\n\\2$adate\n\\3] ncont
puts [edit {Wikipedia:WikiProjekt Kategorien} {Bot: automatische Aktualisierung} $ncont / minor]

set lang dea ; source langwiki.tcl ; #set token [login $wiki]
set t [utc -> seconds {} {%d. %B %Y} {-1 day}]
set qst [sql <- Qualitätssicherung/$t]
set lpt [scat Wikipedia:Qualitätssicherung 0]
set sign ":<small>vergessenen QS-Eintrag nachgetragen ${~}</small>"
set db [get_db dewiki]
mysqlreceive $db "
	select pl_title from pagelinks, page where page_id = pl_from
	and pl_from_namespace = 4 and !pl_namespace
		and page_namespace = 4 and page_title = '$qst'
;" plt {
	lappend ll [sql -> $plt]
}
mysqlclose $db
foreach pt $lpt {
	regexp -- {\{\{QS.*?\}\}} [conts t $pt x] templ
	set ptempl [parse_templ $templ]
	if {[dict get $ptempl 1] eq $t && $pt ni $ll} {
		puts [edit Wikipedia:$qst \[\[$pt\]\] $sign\n[dict get $ptempl 2] / section new]
	}
}
