#!/usr/bin/tclsh8.7

set editafter 1

#exit

catch {if {[exec pgrep -cxu taxonbot spielwiese.tcl] > 1} {exit}}

source api.tcl ; set lang dea ; source langwiki.tcl ; #set token [login $wiki]

set greetz	{{{Bitte erst NACH dieser Zeile schreiben! (Begrüßungskasten)}}}
set new		{{{subst:Bitte erst NACH dieser Zeile schreiben! (Begrüßungskasten)/Text}}}
set ws Wikipedia:Spielwiese
set creset {Spielwiese gemäht (zurückgesetzt)}
set ts0	[clock scan [utc ^ seconds {} %Y%m%d%H%M {}] -format %Y%m%d%H%M]

read_file spielwiese.db dbl

foreach {ts comment} $dbl {
	if {{Spielwiese} in $comment && {gemäht} in $comment && {(zurückgesetzt)} in $comment} {
		set ts60 [clock scan [
			utc ^ [string range [lindex $dbl 0] 0 end-4] %Y-%m-%dT%H:%M %Y%m%d%H%M {}
		] -format %Y%m%d%H%M]
		if {[expr $ts0 - $ts60] >= 3600 && [conts t $ws x] ne [conts t $ws/Vorlage x]} {
			puts [edit $ws "Bot: $creset" $greetz$new]
			exit
		} elseif {[expr $ts0 - $ts60] >= 3600} {
			set sts [utc ^ seconds {} %Y-%m-%dT%H:%M:%SZ {}]
			prepend_file spielwiese.db [list $sts "-s $creset"]
			exit
		}
		break
	}
}
set ts15 [clock scan [
	utc ^ [string range [lindex $dbl 0] 0 end-4] %Y-%m-%dT%H:%M %Y%m%d%H%M {1 minute}
] -format %Y%m%d%H%M]
if {[expr $ts0 - $ts15] >= 900 && [conts t $ws x] ne [conts t $ws/Vorlage x]} {
	puts [edit $ws "Bot: $creset" $greetz$new]
}
exit


#set leer {<noinclude>{{Dokumentation/Unterseite}}</noinclude>$$$$<noinclude>
#{{Kasten|Diese Zahl ist die Revisions-ID zu einer Revision der leeren Spielwiese, die nur den Begrüßungskasten enthält. Sie wird nach dem Löschen der Spielwiese automatisch von [[Benutzerin:TaxonBota|TaxonBota]] aktualisiert.}}</noinclude>}

#set reset {<noinclude>{{Dokumentation/Unterseite}}</noinclude>$$$$<noinclude>
#{{Kasten|Diese Zahl ist die Revisions-ID zu einer unveränderten Revision der Spielwiese (<code><nowiki>{{Bitte erst NACH dieser Zeile schreiben! (Begrüßungskasten)}}{{subst:Bitte erst NACH dieser Zeile schreiben! (Begrüßungskasten)/Text}}</nowiki></code>). Sie wird nach dem Löschen der Spielwiese automatisch von [[Benutzerin:TaxonBota|TaxonBota]] aktualisiert.}}</noinclude>}

set c {{{Bitte erst NACH dieser Zeile schreiben! (Begrüßungskasten)}}

== Die Spielwiese ==
[[Datei:Blumenwiese bei Obermaiselstein05.jpg|miniatur|Die Spielwiese – viel Freiraum für Experimente]]

Die '''Wikipedia-Spielwiese''' ist eine [[Sandbox|Testseite]] für alle Nutzer der [[deutschsprachige Wikipedia|deutschsprachigen Wikipedia]]. Hier kann man zum Beispiel mit der ''Textformatierung'' spielen, die Seite wird regelmäßig „gemäht“ (gelöscht). Klicke einfach oben auf {{Taste|Bearbeiten}} und verändere diesen Text!

{{Zitat
 | Text  = Ich habe keine besondere Begabung, sondern bin nur leidenschaftlich neugierig.
 | Autor = [[Albert Einstein]]
 | ref   = <ref>in einem Brief an [[Carl Seelig]], 1952, zitiert nach [[Ulrich Weinzierl]]: „Carl Seelig, Schriftsteller“, Wien, 1982, Seite 135</ref>
}}

Helfen können dir die Hinweise zur [[Hilfe:Textgestaltung|Textgestaltung]] und zur [[Wikipedia:Formatierung‎|Formatierung‎]]. Weiterführendes findest du unter [[Hilfe:Seite bearbeiten|Seiten bearbeiten]] und im [[Wikipedia:Tutorial|Tutorial]]. [[Wikipedia:Sei mutig|Sei mutig]], aber achte bitte darauf, dass von hier aus verlinkte Seiten ''nicht mehr'' zur Spielwiese gehören.

=== Die Wikipedia ===
{{Hauptartikel|Wikipedia}}
Das Ziel der Wikipedia ist der Aufbau einer [[Enzyklopädie]] durch freiwillige und ehrenamtliche Autoren. Der Name Wikipedia setzt sich zusammen aus ''Wiki'' (dem [[Hawaiische Sprache|hawaiischen]] Wort für „schnell“), und ''encyclopedia'', dem englischen Wort für „Enzyklopädie“. Ein [[Wiki]] ist ein Webangebot, dessen Seiten jeder leicht und ohne technische Vorkenntnisse direkt im Webbrowser bearbeiten kann.

Anders als herkömmliche Enzyklopädien ist die Wikipedia frei. Es gibt sie nicht nur kostenlos im Internet, sondern jeder darf sie unter Angabe der Autoren und der [[Wikipedia:Lizenzbestimmungen|freien Lizenz]] frei kopieren und verwenden.

=== Der erste eigene Artikel ===
{{Hauptartikel|Hilfe:Neuen Artikel anlegen}}
Wenn du ernsthaft vorhast, einen Artikel zu schreiben, solltest du dich als Benutzer [[Hilfe:Benutzerkonto anlegen|bei Wikipedia anmelden]] und dann deinen Artikel auf einer eigenen [[Hilfe:Artikelentwurf|Entwurf-Seite]] vorbereiten. 

Die Spielwiese wird automatisch nach einiger Zeit gemäht (zurückgesetzt), in der {{Taste|Versionsgeschichte}} findest du ''deine'' Version der Spielwiese wieder. In größeren Zeitabständen wird die Spielwiese allerdings komplett gelöscht, so dass auf ihre Versionen nicht mehr zugegriffen werden kann.

=== Weitere Experimente ===
Tests, die über einfache Schreibexperimente hinausgehen, beispielsweise mit [[Hilfe:Kategorien|Kategorien]] oder [[Hilfe:Weiterleitung|Weiterleitungen]], kannst du auf der [[Wikipedia:Spielwiese/Unterseite|Spielwiesenunterseite]] erproben. Um mit [[Hilfe:Vorlagen|Vorlagen]] zu experimentieren, nutze die dafür vorgesehene [[Vorlage:Spielwiese]] oder beachte [[Hilfe:Vorlagenspielwiese]]. Für Tests mit [[Wikipedia:Wikidata|Wikidata]] kannst du die [[Wikipedia:Wikidata/Wikidata-Spielwiese|Wikidata-Spielwiese]] verwenden.

== Einzelnachweise ==
<references />
__KEIN_INHALTSVERZEICHNIS__}

while 1 {
#	set db [get_db dewiki]
#	set revc [
#		mysqlsel $db {
#			select count(rev_timestamp)
#			from revision join page on rev_page = page_id
#			where page_title = 'Spielwiese' and page_namespace = 4
#		;} -list
#	]
#	mysqlclose $db
#	if {$revc >= 4500} {
#		set lang de1 ; source langwiki.tcl ; #set token [login $wiki]
#		puts [get [post $wiki {*}$token {*}$format / action delete / title Wikipedia:Spielwiese / reason {Spielwiese wegen hoher Versionsmenge und URV-Einträgen gelöscht}]]
#		puts [edit Wikipedia:Spielwiese {Leere Spielwiese} {{{Bitte erst NACH dieser Zeile schreiben! (Begrüßungskasten)}}}]
#		puts [edit Wikipedia:Spielwiese {Neue Spielwiese} $c]
#		puts [get [post $wiki {*}$token {*}$format / action protect / title Wikipedia:Spielwiese / protections move=sysop]]
#		set lang dea ; source langwiki.tcl ; #set token [login $wiki]
#		set db [get_db dewiki]
#		set lrev [
#			mysqlsel $db {
#				select rev_id
#				from revision join page on rev_page = page_id
#				where page_title = 'Spielwiese' and page_namespace = 4
#				limit 2
#			;} -list
#		]
#		mysqlclose $db
#		puts [edid 8014867 {Bot: neue Revisions-ID} [string map [list {$$$$} [lindex $lrev 0]] $leer] / minor]
#		puts [edid 8014868 {Bot: neue Revisions-ID} [string map [list {$$$$} [lindex $lrev 1]] $reset] / minor]
#	}
	set i 0
	set t0  [clock scan $t -format {%d.%m.%Y %T +0000}]
	set t60 [clock format [clock add $t0 -61 minutes] -format %Y%m%d%H%M%S]
	if [catch {set lrv [dict get [
   	page [post $wiki {*}$get / titles Wikipedia:Spielwiese / prop revisions / rvprop timestamp|comment / rvend $t60 / rvlimit max]
	] revisions]}] {exit}
	set t15 [clock scan [lindex $lrv 0 1] -format %Y-%m-%dT%TZ]
	foreach rv $lrv {
   	if {[dict get $rv comment] eq {Spielwiese gemäht (zurückgesetzt)}} {
      	incr i
 	   }
	}
	if {[conts t Wikipedia:Spielwiese/Vorlage x] ne [conts t Wikipedia:Spielwiese x]} {
   	if {[expr $t0 - $t15] >= 899} {
#   		set token [login $wiki]
	      puts [edit Wikipedia:Spielwiese {Spielwiese gemäht (zurückgesetzt)} $greetz$new]
   	} elseif {[expr $t0 - $t15] < 899} {
      	exit
	   } else {
   	   if !$i {
#      		set token [login $wiki]
      		puts [edit Wikipedia:Spielwiese {Spielwiese gemäht (zurückgesetzt)} $greetz$new]
	      }
   	}
	}
}

