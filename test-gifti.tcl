#!/usr/bin/tclsh8.7

source api2.tcl
set debug 1

set lang de ; source langwiki.tcl ; #set token [login $wiki]
set lang kat   ; source langwiki.tcl ; #set token [login $wiki]
set lang de ; source langwiki.tcl ; #set token [login $wiki]

source procs.tcl

package require http
package require tls
package require tdom

set db [read [set f [open ss-2.db r]]] ; close $f

foreach item $db {
if [catch {
   set kid 0
   set born [dict values [regexp -inline -- {Kategorie:Geboren (\d{4})} [pagecat $item]]]
   set entity [page [post $wiki {*}$query / prop pageprops / titles $item / ppprop wikibase_item] pageprops wikibase_item]
after 10000
   set lang d ; source langwiki.tcl ; #set token [login $wiki]
   set imdb [dict get [join [dict get [get [
      post $wiki {*}$format / action wbgetclaims / entity $entity
   ] claims] P345]] mainsnak datavalue value]
after 10000
   set lang de ; source langwiki.tcl ; #set token [login $wiki]
   set html [getHTML http://www.imdb.com/name/$imdb/]
   if {[string first >Actress< $html] > -1} {
      set actor [regexp -inline -- {<a name="actress">Actress</a>.*?</div>\n</div>\n</?div(?:>| id)} $html]
   } else {
      set actor [regexp -inline -- {<a name="actor">Actor</a>.*?</div>\n</div>\n</?div(?:>| id)} $html]
   }
   set self [regexp -inline -- {<a name="self">Self</a>.*?</div>\n</div>\n</?div(?:>| id)} $html]
   set dateactor [dict values [regexp -all -inline -- {&nbsp;(\d{4})} $actor]]
   set dateself [dict values [regexp -all -inline -- {&nbsp;(\d{4})} $self]]
   set first [lindex [lsort -unique "$dateactor $dateself"] 0]
   if {[expr $first - $born] < 14} {incr kid}
}] {gets stdin}
}

