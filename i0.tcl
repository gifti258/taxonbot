#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

package require tdom
package require http
package require tls
package require uri::urn

source library.tcl
source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]

proc infos {pgid ns} {
	global lastrevid wiki get i xmlframe
	set infos [page [post $wiki {*}$get / prop info / pageids $pgid]]
	set lastrevid [dict get $infos lastrevid]
	return [
		dict with infos {string map [list $i "    <title>$title</title>\n    <ns>$ns</ns>\n    <id>$pageid</id>\n$i"] $xmlframe}
	]
}

proc rev {hist offset} {
	global wiki get i xml0
#	set nr 21
	incr nr
	set xml($nr) $xml0
	foreach 1 $hist {
		dict with 1 {
#puts [incr zzzzz]:$timestamp
	puts "Version [incr zyx2]: $timestamp"
			set xml($nr) [string map [list $i "    <revision>\n      <id>$revid</id>\n$i"] $xml($nr)]
			if $parentid {set xml($nr) [string map [list $i "      <parentid>$parentid</parentid>\n$i"] $xml($nr)]}
			set xml($nr) [string map [list $i "      <timestamp>$timestamp</timestamp>\n      <contributor>\n$i"] $xml($nr)]
			if $userid {
				set xml($nr) [string map [list $i "        <username>[
					string map {< &lt; > &gt; & &amp;} $user
				]</username>\n        <id>$userid</id>\n$i"] $xml($nr)]
			} else {
				set xml($nr) [string map [list $i "        <ip>$user</ip>\n$i"] $xml($nr)]
			}
			set xml($nr) [string map [list $i "      </contributor>\n$i"] $xml($nr)]
			if [dict exists $1 minor] {set xml($nr) [string map [list $i "      <minor />\n$i"] $xml($nr)]}
			if {$comment ne {}} {set xml($nr) [string map [list $i "      <comment>[
				string map {< &lt; > &gt; & &amp;} $comment
			]</comment>\n$i"] $xml($nr)]}
			set xml($nr) [string map [list $i "      <model>wikitext</model>\n      <format>text/x-wiki</format>\n$i"] $xml($nr)]
			set xml($nr) [string map [list $i "      <text xml:space=\"preserve\" bytes=\"$size\">[
				string map {< &lt; > &gt; & &amp;} ${*}
			]</text>\n$i"] $xml($nr)]
			set xml($nr) [string map [list $i "      <sha1>$sha1</sha1>\n    </revision>\n$i"] $xml($nr)]
		}
		if {[string bytelength $xml($nr)] > 95000000} {
			lappend lxml $nr [string map [list $i\n {}] $xml($nr)]
			incr nr
			set xml($nr) $xml0
		}
		if {$revid == $offset} {
			lappend lxml $nr [string map [list $i\n {}] $xml($nr)]
			break
		}
	}
	return $lxml
#	set xml1 [string map [list $i\n {}] $xml1]
}

set i {<insert />}
input swiki "\nQuellwiki:  "
switch $swiki {
	v			{set db [get_db dewikiversity]}
	default 	{set db [get_db $swiki\wiki]}
}
input ns "Namespace:  "
input offset "Offset:     "
if $offset {
	mysqlreceive $db "select page_title, page_id from page join revision on rev_page = page_id where page_namespace = $ns and rev_id = $offset" {sourc pgid} {
		lassign [list [sql -> $sourc] $pgid] sourc pgid
	}
} else {
	input sourc "Quelltitel: "
}
#lassign {de Google {}} swiki sourc offset
set revc [mysqlsel $db "select count(*) from revision join page on rev_page = page_id where page_id = $pgid;" -list]
mysqlclose $db
puts "\n$sourc: $revc Versionen" ; gets stdin
set lang $swiki ; source langwiki.tcl ; #set token [login $wiki]
set xmlframe [read [set xmlfile [open xmlframe.xml]]] ; close $xmlfile
set xml0 [infos $pgid $ns]
if {$offset eq {}} {set offset $lastrevid}
#set xml0 [infos $sourc]
set rvproplist ids|timestamp|user|userid|flags|comment|size|content|sha1

#set rvid 205673848
#set rvid 206102202 ; #Uiguren
while 1 {
	incr rvid
	catch {
		cont {ret1 {
#			set ditem [page $ret1 revisions]
#			puts $ditem
			foreach item [page $ret1 revisions] {lappend hist $item}
			puts "Version [incr zyx1]: [set rvid [dict get $item revid]]"
			if {$rvid == $offset} {break}
#			if {[incr ihist] == 1000} {
#				save_file hist[incr shist].xml $hist
#				unset ihist
#				set hist {}
#			}
#			break
		}} {*}$get / prop revisions / pageids $pgid / rvprop $rvproplist / rvstartid $rvid / rvdir newer / rvlimit 1 / utf8 1
	}
	if {$rvid == $offset} {break}
}

#cont {ret1 {
#puts $rvid
#	if [catch {set ditem [page $ret1 revisions]}] {
#		after 10000
#		puts "Trial 2" ; gets stdin

#		set ditem [list [lindex [page [post $wiki {*}$get / prop revisions / pageids $pgid / rvprop $rvproplist / rvstartid $rvid / rvdir newer / rvlimit 2 / utf8 1] revisions] end]]
#		puts "Trial 2 complete" ; gets stdin
#	}
#	puts $ditem
#	puts [list [lindex [page [post $wiki {*}$get / prop revisions / pageids $pgid / rvprop $rvproplist / rvstartid $rvid / rvdir newer / rvlimit 2 / utf8 1] revisions] end]]
#	foreach item $ditem {
#puts item:$item
#		lappend hist $item
#		set f [open xxml.xml a] ; puts $f $item ; close $f
#puts [incr aaaaa]
#	}
#	puts "Version [incr zyx1]: [set rvid [dict get $item revid]]"
#	if {[set rvid [dict get $item revid]] == $offset} {break}
#	puts "Version [incr zyx1]:$rvid"
#	if {$rvid == $offset} {puts "break: rvid = $rvid | offset = $offset" ; gets stdin ; break}
#}} {*}$get / prop revisions / pageids $pgid / rvprop $rvproplist / rvdir newer / rvlimit 1 / utf8 1
#puts Versionen_gespeichert ; gets stdin
#rev $hist $offset
#puts "end: rvid = $rvid | offset = $offset" ; gets stdin

foreach {1 2} [rev $hist $offset] {
	save_file xml$1.xml $2
#	set xmlfile [open xml$1.xml w] ; puts $xmlfile $2 ; close $xmlfile
	puts "\nFile Size (xml$1): [file size xml$1.xml]"
	puts "Liste $1: [regexp -all -- {<revision.*?</revision} $2] Versionen"
}
puts {}
exit
