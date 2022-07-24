#!/usr/bin/tclsh8.7

set testoffset 1
source api2.tcl
#set lang de
puts $lang
source langwiki.tcl
puts $self
login $wiki
$wiki configure -cookiejar taxonbot.cookie
puts $wiki
$wiki cleanup
puts $wiki
