#!/usr/bin/tclsh8.7
#!/shared/tcl/bin/tclsh8.6

#set editafter 1
source api2.tcl
input srclang "\nslang: "
set lang $srclang ; source langwiki.tcl ; #set token [login $wiki]

input src "source: "
input rvend "rvend: "
input ns "tgtns: "
input tgt0 "target: "
input rvtgt "tgtrv: "
input reason "reason: "
switch $ns {
	2			{
					set tgt0 [string map -nocase {Benutzer: {} User: {}} $tgt0]
					lassign [list Benutzer:$tgt0 "Benutzer Diskussion:$tgt0"] tgt dtgt
				}
	4			{
					set tgt0 [string map -nocase {Wikipedia: {}} $tgt0]
					lassign [list Wikipedia:$tgt0 "Wikipedia Diskussion:$tgt0"] tgt dtgt
				}
	default	{lassign [list $tgt0 Diskussion:$tgt0] tgt dtgt}
}
if {$srclang eq {commons}} {
	set presrcurl http://commons.wikimedia.org/w/index.php?
	set srclang c
} else {
	set presrcurl http://$srclang.wikipedia.org/w/index.php?
}
set pretgturl http://de.wikipedia.org/w/index.php?
cont {revs {
	foreach revision [page $revs revisions] {
	dict with revision {
		if {[incr i] == 1} {
			set sdate [clock format [
				clock scan [string range $timestamp 0 9] -format %Y-%m-%d
			] -format {%e. %B %Y} -timezone :Europe/Berlin -locale de]
		}
		set stamp [string map {T { } Z { (UTC)}} $timestamp]
		if ![empty comment] {
			set comment_ ''[
				string map {
					/* {<span class="autocomment">/*} */ */</span> [[ [[: '' <nowiki>''</nowiki>
					"{{" "<nowiki>{{</nowiki>" "}}" "<nowiki>}}</nowiki>" < <nowiki><</nowiki> > <nowiki>></nowiki>
				} ([regsub -all -- {\[\[(.*?\|.*?)\|(.*?\|.*?)\]\]} [
					regsub -all -- {\[\[(.*?)\]\]} $comment \[\[$srclang:\\1|\\1\]\]
					] \[\[$srclang:\\1\]\]])
			]''
			set comment_ [string map "\[\[:$srclang:$srclang \[\[:$srclang" $comment_]
		} else {
			set comment_ {}
		}
		lappend versions "* \[$presrcurl\oldid=$revid $stamp\] (\[$presrcurl\oldid=$revid&diff=prev diff\])\
			\[\[:[expr {$srclang ne {de}?"$srclang:":{}}]user:$user|$user\]\] $comment_"
	}
}
}} {*}$get / titles $src / prop revisions / rvprop ids|user|timestamp|comment / rvstartid $rvend / rvlimit max / utf8 1

set lang de1 ; source langwiki.tcl ; #set token [login $wiki]

set tdate [clock format [clock scan [string range [
	page [post $wiki {*}$get / titles $tgt / prop revisions / rvprop timestamp / rvstartid $rvtgt / rvlimit 1] revisions
] 11 20] -format %Y-%m-%d] -format {%e. %B %Y} -timezone :Europe/Berlin -locale de]

set prelicence "== Lizenzhinweis ==\n\{\{Nicht archivieren|Zeigen=nein\}\}\
	\n<div style=\"border: 3px solid grey; margin: 2px;\"><div style=\"margin: 10px;\">\
	\n<p style=\"width: 100%; font-size: 0.8em; text-align: center;\">\Diesen\
	Hinweis nicht entfernen oder archivieren und immer an erster Stelle auf dieser Diskussionsseite belassen.</p>"
set endlicence "\n\nDamit werden die Lizenzbestimmungen der \[\[GNU-Lizenz für freie Dokumentation\]\] (GNU FDL)\
	und der \[\[Creative Commons#Die_sechs_aktuellen_Lizenzen|CC-BY-SA 3.0\]\] gewahrt.<br />~~~~\
	</div></div>\{\{Nicht archivieren|Zeigen=nein\}\}\n----\n\n"
switch $reason {
	a	{set tbox "\{\{Kasten|1=Durch eine Auslagerung\
			aus dem Artikel [expr {$srclang eq {de} ? "\[\[:$src\]\]" : "\[\[:$srclang:$src\]\]"}]\
			in der Fassung vom \[$presrcurl\oldid=$rvend $sdate\] wurden diesem Artikel am \[$pretgturl\diff=$rvtgt\&prev $tdate\]\
			umfangreiche Textabschnitte hinzugefügt.\
			Im Folgenden wird zur Wahrung der Lizenzbestimmungen am Ende des Artikels die Versionsgeschichte angehängt.\}\}"
		 set summary "Einfügung der Versionsgeschichte nach umfangreicher Umformulierung durch eine Auslagerung\
			aus dem Artikel [expr {$srclang eq {de} ? "\[\[:$src\]\]" : "\[\[:$srclang:$src\]\]"}] am Ende des Artikeltextes"
      }
	c	{set tbox "\{\{Kasten|1=Durch eine Kopie\
			aus dem Artikel [expr {$srclang eq {de} ? "\[\[:$src\]\]" : "\[\[:$srclang:$src\]\]"}]\
			in der Fassung vom \[$presrcurl\oldid=$rvend $sdate\] wurden diesem Artikel am \[$pretgturl\diff=$rvtgt\&prev $tdate\]\
			umfangreiche Textabschnitte hinzugefügt.\
			Im Folgenden wird zur Wahrung der Lizenzbestimmungen am Ende des Artikels die Versionsgeschichte angehängt.\}\}"
		 set summary "Einfügung der Versionsgeschichte nach umfangreicher Umformulierung durch eine Kopie\
			aus dem Artikel [expr {$srclang eq {de} ? "\[\[:$src\]\]" : "\[\[:$srclang:$src\]\]"}] am Ende des Artikeltextes"
      }
	e	{set tbox "\{\{Kasten|1=Durch eine etappenweise Übersetzung des Artikels \[\[:$srclang:$src\]\]\
			in der Fassung vom \[$presrcurl\oldid=$rvend $sdate\] wurde dieser Artikel\
			ab dem \[$pretgturl\diff=$rvtgt\&prev $tdate\] umformuliert.\
			Im Folgenden wird zur Wahrung der Lizenzbestimmungen am Ende des Artikels die Versionsgeschichte angehängt.\}\}"
		 set summary "Einfügung der Versionsgeschichte nach etappenweiser Übersetzung\
		 	des Artikels \[\[:$srclang:$src\]\] am Ende des Artikeltextes"
      }
	t	{set tbox "\{\{Kasten|1=Durch eine Teilübersetzung des Artikels \[\[:$srclang:$src\]\]\
			in der Fassung vom \[$presrcurl\oldid=$rvend $sdate\] wurde dieser Artikel\
			am \[$pretgturl\diff=$rvtgt\&prev $tdate\] umformuliert.\
			Im Folgenden wird zur Wahrung der Lizenzbestimmungen am Ende des Artikels die Versionsgeschichte angehängt.\}\}"
		 set summary "Einfügung der Versionsgeschichte nach Teilübersetzung\
		 	des Artikels \[\[:$srclang:$src\]\] am Ende des Artikeltextes"
		}
	ü	{set tbox "\{\{Kasten|1=Durch eine Übersetzung des Artikels \[\[:$srclang:$src\]\]\
			in der Fassung vom \[$presrcurl\oldid=$rvend $sdate\] wurde dieser Artikel\
			am \[$pretgturl\diff=$rvtgt\&prev $tdate\] umformuliert.\
			Im Folgenden wird zur Wahrung der Lizenzbestimmungen am Ende des Artikels die Versionsgeschichte angehängt.\}\}"
		 set summary "Einfügung der Versionsgeschichte nach umfangreicher Übersetzung\
		 	des Artikels \[\[:$srclang:$src\]\] am Ende des Artikeltextes"
      }
	z	{set tbox "\{\{Kasten|1=Dieser Artikel wurde am \[$pretgturl\diff=$rvtgt\&prev $tdate\]\
			mit dem Artikel [expr {$srclang eq {de} ? "\[\[:$src\]\]" : "\[\[:$srclang:$src\]\]"}]\
			in der Fassung vom \[$presrcurl\oldid=$rvend $sdate\] zusammengeführt.\
			Im Folgenden wird zur Wahrung der Lizenzbestimmungen am Ende des Artikels die Versionsgeschichte angehängt.\}\}"
		 set summary "Einfügung der Versionsgeschichte nach Zusammenführung\
			mit dem Artikel [expr {$srclang eq {de} ? "\[\[:$src\]\]" : "\[\[:$srclang:$src\]\]"}] am Ende des Artikeltextes"
		}
}
#puts [llength $versions]
#set f [open ct.out w] ; puts $f $versions ; close $f
set newcontent "$tbox\n\n[contents t $tgt x]\n\n== Versionsgeschichte ==\n[join [encoding convertfrom $versions] \n]"
puts \n[edit $tgt $summary $newcontent]
set newrevid [revision [post $wiki {*}$query / titles $tgt / prop revisions] revid]
puts \n[edit $tgt {- Versionsgeschichte} $contents]
switch $reason {
	a	{set licence "\n\nIn den Artikel \[\[\{\{HAUPTSEITE\}\}\]\] wurden Textabschnitte\
			aus dem Artikel [expr {$srclang eq {de} ? "\[\[:$src\]\]" : "\[\[:$srclang:$src\]\]"}] ausgelagert.\
			Daher wird lizenzrechtlich auf die Versionsgeschichte dieses Artikels wegen Überschneidung beider\
			Versionsgeschichten wie folgt verwiesen:\n\n\* \[$presrcurl\oldid=$rvend hier\] findet sich\
			der Artikel [expr {$srclang eq {de} ? "\[\[:$src\]\]" : "\[\[:$srclang:$src\]\]"}] zum Zeitpunkt\
			der Auslagerung\n* \[$pretgturl\oldid=$newrevid hier\] findet sich\
			die zusammengefasste Versionsgeschichte des Artikels [expr {$srclang eq {de} ? "\[\[:$src\]\]" : "\[\[:$srclang:$src\]\]"}]"
		}
	c	{set licence "\n\nIn den Artikel \[\[\{\{HAUPTSEITE\}\}\]\] wurden Textabschnitte\
			aus dem Artikel [expr {$srclang eq {de} ? "\[\[:$src\]\]" : "\[\[:$srclang:$src\]\]"}] kopiert.\
			Daher wird lizenzrechtlich auf die Versionsgeschichte dieses Artikels wegen Überschneidung beider\
			Versionsgeschichten wie folgt verwiesen:\n\n\* \[$presrcurl\oldid=$rvend hier\] findet sich\
			der Artikel [expr {$srclang eq {de} ? "\[\[:$src\]\]" : "\[\[:$srclang:$src\]\]"}] zum Zeitpunkt\
			der Kopie\n* \[$pretgturl\oldid=$newrevid hier\] findet sich\
			die zusammengefasste Versionsgeschichte des Artikels [expr {$srclang eq {de} ? "\[\[:$src\]\]" : "\[\[:$srclang:$src\]\]"}]"
		}
	e	{set licence "\n\nDer Artikel \[\[\{\{HAUPTSEITE\}\}\]\] wurde mittels einer etappenweisen Übersetzung\
			des Artikels \[\[:$srclang:$src\]\] überarbeitet.\
			Daher wird lizenzrechtlich auf die Versionsgeschichte dieses Artikels wegen Überschneidung beider\
			Versionsgeschichten wie folgt verwiesen:\n\n* \[$presrcurl\oldid=$rvend hier\] findet sich\
			der Artikel \[\[:$srclang:$src\]\] zum Zeitpunkt der Übersetzung\n* \[$pretgturl\oldid=$newrevid hier\] findet sich\
			die zusammengefasste Versionsgeschichte des Artikels \[\[:$srclang:$src\]\]"
		}
	t	{set licence "\n\nDer Artikel \[\[\{\{HAUPTSEITE\}\}\]\] wurde mittels einer Teilübersetzung des Artikels \[\[:$srclang:$src\]\]\
			überarbeitet. Daher wird lizenzrechtlich auf die Versionsgeschichte dieses Artikels wegen Überschneidung beider\
			Versionsgeschichten wie folgt verwiesen:\n\n* \[$presrcurl\oldid=$rvend hier\] findet sich\
			der Artikel \[\[:$srclang:$src\]\] zum Zeitpunkt der Teilübersetzung\n* \[$pretgturl\oldid=$newrevid hier\] findet sich\
			die zusammengefasste Versionsgeschichte des Artikels \[\[:$srclang:$src\]\]"
		}
	ü	{set licence "\n\nDer Artikel \[\[\{\{HAUPTSEITE\}\}\]\] wurde mittels einer Übersetzung des Artikels \[\[:$srclang:$src\]\]\
			überarbeitet. Daher wird lizenzrechtlich auf die Versionsgeschichte dieses Artikels wegen Überschneidung beider\
			Versionsgeschichten wie folgt verwiesen:\n\n* \[$presrcurl\oldid=$rvend hier\] findet sich\
			der Artikel \[\[:$srclang:$src\]\] zum Zeitpunkt der Übersetzung\n* \[$pretgturl\oldid=$newrevid hier\] findet sich\
			die zusammengefasste Versionsgeschichte des Artikels \[\[:$srclang:$src\]\]"
		}
	z	{set licence "\n\nDer Artikel \[\[\{\{HAUPTSEITE\}\}\]\] wurde\
			mit dem Artikel [expr {$srclang eq {de} ? "\[\[:$src\]\]" : "\[\[:$srclang:$src\]\]"}] zusammengeführt. Daher wird\
			lizenzrechtlich auf die Versionsgeschichte dieses Artikels wegen Überschneidung beider\
			Versionsgeschichten wie folgt verwiesen:\n\n\* \[$presrcurl\oldid=$rvend hier\] findet sich\
			der Artikel [expr {$srclang eq {de} ? "\[\[:$src\]\]" : "\[\[:$srclang:$src\]\]"}] zum Zeitpunkt\
			der Zusammenführung\n* \[$pretgturl\oldid=$newrevid hier\] findet sich\
			die zusammengefasste Versionsgeschichte des Artikels [expr {$srclang eq {de} ? "\[\[:$src\]\]" : "\[\[:$srclang:$src\]\]"}]"
		}
}
puts \n[edit $dtgt Lizenzhinweis {} / prependtext $prelicence$licence$endlicence]

exit

