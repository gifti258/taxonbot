#!/usr/bin/tclsh8.7
#exit

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]
source library.tcl
set db [get_db dewiki]

package require http
package require tls
package require tdom


set arg [lindex $argv 0]
set f [open adt.db w] ; close $f
mysqlreceive $db {
	select page_title
	from page join templatelinks on tl_from = page_id
	where !page_namespace and !tl_from_namespace and tl_namespace = 10 and tl_title in ('Lesenswert','Exzellent')
	order by page_title
;} pt {
	lappend lpt $pt
}
foreach pt $lpt {
	catch {
		if {[string first $arg [conts t $pt x]] > -1} {
			puts [incr i]:$pt
			set f [open adt.db a] ; puts $f $i:$pt ; close $f
		}
	}
}
puts \a

