#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

#exit

if {[exec pgrep -cxu taxonbot rc.tcl] > 1} {exit}

source api2.tcl ; set lang species ; source langwiki.tcl ; #set token [login $wiki]

lassign {} ollog llogid
while 1 {
   set llog [lreverse [get [post $wiki {*}$logevents / lelimit 2000] query logevents]]
   if {$llog ne $ollog} {
      set ollog $llog
      foreach log $llog {if {[dict get $log logid] ni $llogid} {
         set lparam [dict get $log params]
         if [catch {set curid [dict get $log params curid]}] {incr s} else {set s 0}
         if !$s {
            if ![exists ocurid] {set ocurid $curid}
            for {set id [incr ocurid]} {$id <= $curid} {incr id} {
               if [catch {
                  set rv [page [post $wiki {*}$query / revids $id / prop revisions]]
                  set rv [join [list [lreplace $rv end-1 end] [join [dict get $rv revisions]]]]
                  dict with rv {
#Arbeitsbereich
if !$ns {
	if {$user eq {323van}} {
		puts $user:$title
		puts $rv
		set ts [split $timestamp -T]
		set ts [lindex $ts 0][lindex $ts 1][lindex $ts 2]
	}
#	set f [open rc/rc$ts.db a] ; puts $f $rv ; close $f
}
#Arbeitsbereich
                  }
               }] {continue}
            }
            set ocurid $curid
         }
      }}
      unset -nocomplain llogid
      foreach log $llog {lappend llogid [dict get $log logid]}
   }
}

