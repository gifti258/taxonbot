#!/usr/bin/tclsh8.7
#exit

source api.tcl ; set lang meta ; source langwiki.tcl ; #set token [login $wiki]
package require http ; package require tls ; package require tdom

meta_lang

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]

set css [conts t user:Doc_Taxon/monobook.css x]

source api.tcl ; set lang ar ; source langwiki.tcl ; #set token [login $wiki]
puts [edit user:Doc_Taxon/monobook.css {} $css]

exit

foreach lang $llang {
	puts \n$lang:
	set lang 
}

puts $css
