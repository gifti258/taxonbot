#!/usr/bin/tclsh8.7

catch {if {[exec pgrep -cxu taxonbot c-uncat1.tcl] > 1} {exit}}

source api.tcl ; set lang commons ; source langwiki.tcl ; #set token [login $wiki]

#set lfile [wdcat commonswiki listid {Cultural heritage monuments in Saxony} 14]

#set lfile [intitle {cultural heritage monument/i} 14]
#puts [llength $lfile]

#puts $lfile

set lfile [wdcat commonswiki list {Images from Wiki Loves Monuments 2021} 6]

#puts $lfile
puts [llength $lfile]

set luncat [wdcat commonswiki list {Media needing categories} 6]
puts [llength $luncat]

exit

set db [get_db commonswiki]
set luncat [template Uncategorized 6]
puts $luncat
puts [llength $luncat]
mysqlclose $db

exit

set offset 0
cont {ret1 {
	foreach item [get $ret1 query search] {
		if [catch {
			puts [incr ll]:$item
		}] {continue}
	}
}} {*}$get / list search / srsearch {intitle:/cultural heritage monument/i} / srprop title / srlimit 5000 / srnamespace 14|$offset


