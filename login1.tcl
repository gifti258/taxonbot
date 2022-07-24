#!/usr/bin/tclsh8.7

source api2.tcl
set lang de ; source langwiki.tcl ; #set token [login $wiki]
source procs.tcl
puts [post $wiki {*}$query / meta userinfo]
puts [edit user:TaxonBot/Test Test Test / minor]

exit
