#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

exit

if {[exec pgrep -cxu taxonbot rc.tcl] > 1} {exit}

source api2.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]

lassign {} ollog llogid
while 1 {
puts "fetch pack"
   set llog [lreverse [get [post $wiki {*}$logevents / lelimit 2000] query logevents]]
puts "have pack"
   if {$llog ne $ollog} {
      set ollog $llog
      foreach log $llog {if {[dict get $log logid] ni $llogid} {
         set lparam [dict get $log params]
         set s 0
			if {{curid} in $lparam} {
				set curid [dict get $log params curid]
				set s 0
puts 1
			} else {
	         if [catch {set curid [dict get $log params 0]}] {puts 2 ; incr s} else {puts 3 ; set s 0}
			}
         if !$s {
            if ![exists ocurid] {set ocurid $curid}
            for {set id [incr ocurid]} {$id <= $curid} {incr id} {
               if [catch {
                  set rv [page [post $wiki {*}$query / revids $id / prop revisions]]
                  set rv [join [list [lreplace $rv end-1 end] [join [dict get $rv revisions]]]]
                  dict with rv {
#Arbeitsbereich
if !$ns {
#	puts $rv
	set ts [split $timestamp -T]
	set ts [lindex $ts 0][lindex $ts 1][lindex $ts 2]
	if {$ts == [clock format [clock seconds] -format %Y%m%d]} {
puts $rv
		set f [open rc/rc$ts.db a] ; puts $f $rv ; close $f
	}
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

