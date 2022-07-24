#!/usr/bin/tclsh8.7

#exit

#source api2.tcl
#set lang de ; source langwiki.tcl
#source procs.tcl

set lang de
source login.tcl

puts $wiki

puts [post $wiki {*}$query / meta userinfo]
puts [edit user:TaxonBot/Test Test Test / minor]
