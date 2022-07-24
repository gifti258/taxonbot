#!/usr/bin/tclsh8.7
#exit

#set editafter 1

source api.tcl ; set lang d ; source langwiki.tcl ; #set token [login $wiki]
source library.tcl
#set db [get_db wikidatawiki]

package require http
package require tls
package require tdom

set db [get_db wikidatawiki]
set lpt [
	mysqlsel $db {
		select page_id from (
			select page_id from (
				select page_id from page join pagelinks on pl_from = page_id
				where !page_namespace and !pl_from_namespace and !pl_namespace
					and pl_title = 'Q117'
			) a join pagelinks on pl_from = a.page_id
			where !pl_namespace
				and pl_title in ('Q6581072','Q6581097')
		) b join pagelinks on pl_from = b.page_id
		where !pl_namespace
			and pl_title = 'Q5'
	;} -flatlist
]
mysqlclose $db

puts $lpt
puts [llength $lpt]



exit

set query {
	select ?item ?state
	where {
		?item wdt:P31 wd:Q5.
		?item wdt:P21 wd:Q6581072.
		optional {
			?item wdt:P27 ?state.
		}
	}
	limit 100
}

set dt [d_query $query]
puts $dt
