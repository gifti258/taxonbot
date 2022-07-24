#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

package require tdom

source library.tcl
source api.tcl

if {[exists swiki] && [exists slemma] && [exists tlemma]} {
   puts "\nSource: [set slang $swiki]"
   puts "Quelle: [set src $slemma]"
   puts "Ziel:   [set tgt $tlemma]"
} else {
	input part  "\nListe:     "
   input slang "Source:    "
	input sns   "Quelle-NS: "
   input src   "Quelle:    "
   input tgt   "Ziel:      "
	input ns    "Ziel-NS:   "
   if [empty tgt] {set tgt $src}
	if [empty ns] {set ns 0}
	if {$ns > 0} {regexp -- {^.*?\:(.*)$} $tgt -- dbtgt} else {set dbtgt $tgt}
}
input summary  "Grund:     "
set r "\[\[:[expr {$slang ne {de}?"$slang:":{}}]$src\]\]"
set summary [expr {   $summary eq "a"?"Auslagerung von Artikelteilen aus $r"
                     :$summary eq "d"?"Duplikation von $r"
                     :$summary eq "z"?"Zusammenführung mit $r"
                     :$summary eq "e"?"etappenweise Übersetzung von $r"
                     :$summary eq "t"?"Teilübersetzung von $r"
                     :$summary eq "ü"?"Übersetzung von $r"
                     :$summary eq "r"?"Redundanz mit $r"
                     :$summary
                  }]
input b        "b:         "
if {$b eq "b"} {
   puts "b:         [join [dict values [regexp -inline -- {\:(.*?)\/} $tgt]]]"
} elseif ![empty b] {
   puts "b:         $user"
   set tgt user:$user/$tgt
}

set lang de ; source langwiki.tcl ; #set token [login $wiki]

if [dict exists [page [post $wiki {*}$get / titles $tgt / prop info]] missing] {incr tgtmiss}

set lang $slang ; source langwiki.tcl ; #set token [login $wiki]

if [dict exists [page [post $wiki {*}$get / prop info / titles $src]] redirect] {
	regexp -line -- {^#.*?\[\[(.*?)\]\].*?} [contents t $src x] -- src
}

switch $slang {
	v			{set db [get_db dewikiversity]}
	default 	{set db [get_db $slang\wiki]}
}
set revc [mysqlsel $db "select count(*) from revision join page on rev_page = page_id where page_title = '[sql <- $src]' and page_namespace = $sns" -flatlist]
mysqlclose $db
puts "\n$src: $revc Versionen"

gets stdin

#set xml [export $lang wikipedia $src]

set db [get_db dewiki]
set revtgt1 [mysqlsel $db "select count(*) from revision join page on rev_page = page_id where page_title = '[sql <- $dbtgt]' and page_namespace = $ns;" -flatlist]
mysqlclose $db
puts $revtgt1

for {set r 0} {$r < 100} {incr r} {

set fl [open xml$part.xml r]
set xml [read $fl]
close $fl

regsub -- {    <ns.*?/ns>} $xml "    <ns>$ns</ns>" xml

set xml [encoding convertto $xml]
#puts $xml ; gets stdin
#set infile [open kurator.xml w]
#puts -nonewline $infile $xml
#close $infile
#gets stdin

set list [[[dom parse $xml] documentElement] asList]
lset list end end end 0 end 0 end [encoding convertto $tgt]
#set lastsrc [encoding convertfrom [lindex $list end end end end end end-1 end 0 end]]
set list [split [[[dom createDocumentNode] appendFromList $list] asXML] \n]
lset list 0 {}
lset list end-1 {}

source api2.tcl ; set lang de1 ; source langwiki.tcl ; #set token [login $wiki]

$wiki configure	-httppost {name format contents json} \
                  -httppost {name action contents import} \
						-httppost [list name interwikiprefix contents $slang] \
                  -httppost [list name xml bufferName --.xml buffer [join $list \n]] \
                  -httppost [list name summary contents $summary] \
                  -httppost [list name token contents [lindex $token 2]] \
                  -bodyvar body
$wiki perform
puts "\nListe $part: [get $body]\n"

after 60000
set db [get_db dewiki]
set revtgt2 [mysqlsel $db "select count(*) from revision join page on rev_page = page_id where page_title = '[sql <- $dbtgt]' and page_namespace = $ns;" -flatlist]
mysqlclose $db
puts $revtgt2

if {$revtgt1 == $revtgt2} {
	input wf {Wiederholung/Fortsetzung? }
	if {$wf eq {w}} {continue}
}

set revtgt1 $revtgt2
decr part
if !$part {break} else {puts "... Import der Liste $part ..."}

}

if 0 {
input part "Liste: "
if {$part eq {}} {break}
}


if 0 {
input repeat "\nWiederholung oder weitere Liste (w/l): "
if {$repeat eq {w}} {
	continue
} elseif {$repeat eq {l}} {
	input part "Liste: "
} else {break}
}

#if ![exists tgtmiss] {
#	set delreason {Temporäre Löschung zwecks [[WP:IMP|Import]] der Versionsgeschichte}
#	set undelreason {Import: Artikelwiederherstellung / Versionskorrektur}
#	puts \n[get [post $wiki {*}$format {*}$token / action delete / title $tgt / reason $delreason]]\n
#	puts \n[get [post $wiki {*}$format {*}$token / action undelete / title $tgt / reason $undelreason]]\n
#}

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]

#if ![empty b] {

#   set importrev \{\{Importartikel\}\}\n\n$lastsrc

#   set lastrev "\{\{Importartikel\}\}\n\n[content [post $wiki {*}$get / titles $tgt]]"
#   regsub -all -- {\[\[Cat[e|é]gorie:|\[\[Categor[i|í]a:|\[\[Category:|\[\[Κατηγορία:|\[\[Kategori(e)?:|\[\[Категор[і|и]я:} \
#      $lastrev "\[\[\:Kategorie\:" lastrev
#   puts $lastrev ; gets stdin
#   puts \n[edit $tgt {ImportBot: Importartikel} $lastrev]\n
#}

return
