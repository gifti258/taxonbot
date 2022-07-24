#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

package require tdom

source library.tcl
source api.tcl

if {[exists swiki] && [exists slemma] && [exists tlemma]} {
   puts "\nSource: [set slang [string tolower $swiki]]"
   puts "Quelle: [set src [lindex [split $slemma #] 0]]"
   puts "Ziel:   [set tgt $tlemma]"
} else {
   input slang "\nSource: "
   input src "Quelle: "
   input tgt "Ziel:   "
   if [empty tgt] {
      set tgt $src
   }
}
input summary "Grund:  "
set r "\[\[:[expr {$slang ne {de}?"$slang:":{}}]$src\]\]"
set summary [expr {   $summary eq "a"?"Auslagerung von Artikelteilen aus $r"
                     :$summary eq "z"?"Zusammenführung mit $r"
                     :$summary eq "e"?"etappenweise Übersetzung von $r"
                     :$summary eq "v"?"Vorbereitung für eine Zusammenführung"
                     :$summary eq "t"?"Teilübersetzung von $r"
                     :$summary eq "ü"?"Übersetzung von $r"
							:$summary eq "r"?"Redundanz mit $r"
							:$summary eq "d"?"Duplikation von $r"
                     :$summary
                  }]
input b       "b:      "
if {$b eq "b"} {
   puts "b:      [join [dict values [regexp -inline -- {\:(.*?)\/} $tgt]]]"
} elseif ![empty b] {
   puts "b:      $user"
   set tgt user:$user/$tgt
}

set lang de ; source langwiki.tcl ; #set token [login $wiki]

set tgtmiss 0
if [dict exists [page [post $wiki {*}$get / titles $tgt / prop info]] missing] {incr tgtmiss}

set lang $slang ; source langwiki.tcl ; #set token [login $wiki]

if [dict exists [page [post $wiki {*}$get / prop info / titles $src]] redirect] {
	regexp -line -- {^#.*?\[\[(.*?)\]\].*?} [contents t $src x] -- src
}

set db [get_db $slang\wiki]
#set revsrc [join $src _]
#set revc [mysqlsel $db {
#	select count(*) from revision join page on rev_page = page_id where page_title = $revsrc and page_namespace = 0
#} -list]
set revc [mysqlsel $db "select count(*) from revision join page on rev_page = page_id where page_title = \"[join $src _]\" and page_namespace = 0;" -list]
mysqlclose $db

#cont {revs {foreach rev [page $revs revisions] {incr revc}}} {*}$get / titles $src / prop revisions / rvlimit max


#puts "\n[llength [dict get [page [
#   post $wiki {*}$get / titles $src / prop revisions / rvprop ids / rvlimit max
#]] revisions]] Versionen"

puts "\n$src: $revc Versionen"
if {$revc > 1000} {puts "Maximum an Versionen überschritten" ; exit}

gets stdin

set xml [string map [list <ns>2</ns> <ns>0</ns>] [export $lang wikipedia $src]]

#set fl [open liste40.xml r]
#set xml [read $fl]
#close $fl
#set xml [encoding convertto $xml]
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
puts \n[get $body]\n

puts \nAbwarten?
gets stdin

#if !$tgtmiss {
#	set delreason {Temporäre Löschung zwecks [[WP:IMP|Import]] der Versionsgeschichte}
#	set undelreason {Import: Artikelwiederherstellung / Versionskorrektur}
#	puts \n[get [post $wiki {*}$format {*}$token / action delete / title $tgt / reason $delreason]]\n
#	puts \n[get [post $wiki {*}$format {*}$token / action undelete / title $tgt / reason $undelreason]]\n
#}

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]

if ![empty b] {

#   set importrev \{\{Importartikel\}\}\n\n$lastsrc

   set lastrev "\{\{Importartikel\}\}\n\n[content [post $wiki {*}$get / titles $tgt]]"
   regsub -all -- {\[\[Cat[e|é]gorie:|\[\[Categor[i|í]a:|\[\[Category:|\[\[Κατηγορία:|\[\[Kategori(e)?:|\[\[Категор[і|и]я:|\[\[Luokka} \
      $lastrev "\[\[\:Kategorie\:" lastrev
   puts $lastrev ; gets stdin
   puts \n[edit $tgt {ImportBot: Importartikel} $lastrev]\n
}

return
