#!/usr/bin/tclsh8.7
#exit

source api.tcl ; set lang dea ; source langwiki.tcl ; #set token [login $wiki]

proc expandtemp page {
	global wiki format
	set offset 0
	while 1 {if ![catch {
		set contents [dict values [regexp -inline -- {<onlyinclude>(.*?)</onlyinclude>} [conts t $page x]]]
		set expanded [get [post $wiki {*}$format / action expandtemplates / text $contents / prop wikitext] expandtemplates wikitext]
	}] {break} else {after 10000 ; if {[incr offset] == 5} {puts Fehler! ; exit}}}
	return [join $expanded]
}

set wphsar Wikipedia:Hauptseite/Archiv
set archive $wphsar/[utc -> seconds {} {%e. %B %Y} {}]
set archivetemp \{\{$wphsar/Vorlage[utc -> seconds {} {|Tag=%d|Monat=%m|Jahr=%Y} {}]\}\}
set deny \{\{bots|denyscript=delinker\}\}

set zuq "Bot: Abbild der heutigen \[\[Wikipedia:Hauptseite|Hauptseite\]\]"
set hsarconts $archivetemp\n$deny\n[expandtemp Wikipedia:Hauptseite/!layout]

puts [edit $archive $zuq $hsarconts]

set lang test ; source langwiki.tcl ; #set token [login $wiki]
puts [edid 63277 {Log: HS} {} / appendtext "\n* '''[
	clock format [clock seconds] -format %Y-%m-%dT%TZ
] HS-Snapshot: Task finished!'''"]

exit

#set day [utc -> seconds {} %d {}]
#set year [utc -> seconds {} %m {}]
#set wday [utc -> seconds {} %A {}]
#set emonth [utc -> seconds {} %B {}]

puts [edit $archive "Bot: Abbild der heutigen \[\[$wphs|Hauptseite\]\]" $hsarconts]

set lang test ; source langwiki.tcl ; #set token [login $wiki]
puts [edid 63277 {Log: HS} {} / appendtext "\n* '''[
	clock format [clock seconds] -format %Y-%m-%dT%TZ
] HS-Snapshot: Task finished!'''"]


exit

lassign {Wikipedia:Hauptseite Vorlage:Hauptseite} wphs ths
set archive $wphs/Archiv/[utc -> seconds {} {%e. %B %Y} {}]
set day [utc -> seconds {} %e {}]
set year [utc -> seconds {} %Y {}]
set wday [utc -> seconds {} %A {}]
set emonth [utc -> seconds {} %B {}]

set strmap [format {
{{{LOCALDAY}}} %s
{{{LOCALYEAR}}} %s
{{{LOCALDAYNAME}}} %s
{{{LOCALMONTHNAME}}} %s
{{{FormatZahlLokal|{{ARTIKELANZAHL:R}}}}} {{{ers:zahlenformat:{{ers:ARTIKELANZAHL:R}}}}}
{{{/Wikipedia aktuell}}} %s
{{{/Artikel des Tages/{{LOCALDAYNAME}}}}} %s
{{{/Artikel des Tages/Links}}} %s
{{{/Jahrestage/{{LOCALMONTHNAME}}/{{LOCALDAY}}}}} %s
{{{/Aktuelles}}} %s
{{{Hauptseite Verstorbene}}} %s
{{{/Schon gewusst/{{LOCALDAYNAME}}}}} %s
} $day $year $wday $emonth [expandtemp "$wphs/Wikipedia aktuell"] [expandtemp "$wphs/Artikel des Tages/$wday"] [expandtemp "$wphs/Artikel des Tages/Links"] [expandtemp "$wphs/Jahrestage/$emonth/$day"] [expandtemp "$ths Aktuelles"] [expandtemp "$ths Verstorbene"] [expandtemp "$wphs/Schon gewusst/$wday"]]

set hsconts [set nhsconts [conts t $wphs x]]
set nhsconts $hsconts
set hsday [utc -> seconds {} |Tag=%d|Monat=%m|Jahr=%Y {}]
set nhsconts [string map $strmap [format {{{%s/Archiv/Vorlage%s}}
{{bots|denyscript=delinker}}
%s} $wphs $hsday $nhsconts]]
set nhsconts [regsub -all -- {\n<!--.*?-->} $nhsconts {}]
set spans [dict values [regexp -all -inline -- {\n(<span class="plainlinks".*?</span>)} $nhsconts]]
foreach span $spans {
	set offset 0
	while 1 {if ![catch {
		set expanded [get [post $wiki {*}$format / action expandtemplates / text $span / prop wikitext] expandtemplates wikitext]
	}] {break} else {after 10000 ; if {[incr offset] == 5} {puts Fehler! ; exit}}}
	set nhsconts [string map [list $span $expanded] $nhsconts]
}
regsub -- {\[\[Kategorie.*?\}\} } $nhsconts {} nhsconts

puts [edit $archive "Bot: Abbild der heutigen \[\[$wphs|Hauptseite\]\]" $nhsconts]

set lang test ; source langwiki.tcl ; #set token [login $wiki]
puts [edid 63277 {Log: HS} {} / appendtext "\n* '''[
	clock format [clock seconds] -format %Y-%m-%dT%TZ
] HS-Snapshot: Task finished!'''"]
