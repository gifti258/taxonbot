#!/usr/bin/tclsh8.7
#exit

if {[exec pgrep -cxu taxonbot rc.tcl] > 1} {exit}

source api2.tcl ; set lang dea ; source langwiki.tcl ; #set token [login $wiki]
source library.tcl
set db [get_db dewiki]

package require http
package require tls
package require tdom

lassign {} olrc rcline logtype logparams
while 1 {
	while 1 {
		if ![catch {
			set lrc [get [post $wiki {*}$query {*}$format / list recentchanges / rcnamespace 0|2 / rcprop timestamp|title|ids|user|comment|loginfo / rclimit 500] query recentchanges]
		}] {break}
	}
	if {$lrc ne $olrc} {
		foreach rc [lreverse $lrc] {
			if {$rc ni $olrc} {
#				puts \n
				dict with rc {
					if {$ns == 2 && $logtype eq {move} && ![dict get $logparams target_ns]} {
						puts $rc
						lappend rcline type $type pageid $pageid ns $ns title [dict get $logparams target_title] user $user timestamp $timestamp
					} elseif {!$ns && $type eq {new}} {
						puts $rc
						lappend rcline type $type pageid $pageid ns $ns title $title user $user timestamp $timestamp
					} else {
						lassign {} rcline logtype logparams
						continue
					}
#				puts $rcline
					set ts [split $timestamp -T]
					set ts [lindex $ts 0][lindex $ts 1][lindex $ts 2]
					if {![empty rcline] && $ts == [clock format [clock seconds] -format %Y%m%d]} {
						set f [open rc/rc$ts.a.db a] ; puts $f $rcline ; close $f
					}
				}
				lassign {} rcline logtype logparams
			}
		}
		set olrc $lrc
	} else {
		continue
	}
}

exit

cont {ret1 {
puts ----[incr xyz]
	foreach item [get $ret1 query recentchanges] {
		puts $item
	}
}} {*}$query {*}$format / list recentchanges / rclimit 10







exit

set conts [conts t {Liste von Vornamen/N} x]

set llink [lrange [dict values [regexp -all -inline -- {\[\[(.*?)\]\]} $conts]] 1 end-1]

foreach name $llink {
	if {[string first | $name] > -1} {
		lappend lname [lindex [split $name |] 1]
	} else {
		lappend lname $name
	}
}


foreach name $lname {
#set name {Elaine Aron}
set name "Elaine $name Aron"
puts $name:
set html [getHTML https://www.google.de/search?q='[join $name +]']
#puts $html ; gets stdin
#if [catch {
#set xml [[[dom parse -html [encoding convertfrom $html]] documentElement] asList]
#}] {puts Fehler ; continue}
puts [regexp -all -- "$name" $html]
}

exit

set c4 [conts t Benutzer:AsuraBot/Purges 4]
set ll4 [dict values [regexp -all -inline -line -- {^\* \[\[[:]?(.*?)[|\]].*$} $c4]]
set lpid {}
foreach l4 $ll4 {
lappend lpid [scat [join $l4] -14]
}
lassign {} plpid lplpid
foreach pid [join $lpid] {
incr i
lappend plpid $pid
if {$i == 500} {
lappend lplpid $plpid
lassign {0 {}} i plpid
}
}
lappend lplpid $plpid
set f [open test3.out w]
foreach plpid $lplpid {
puts $f [get [post $wiki {*}$format / action purge / pageids [join $plpid |] / forcelinkupdate 1]]
}
close $f
