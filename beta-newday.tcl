#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

#exit

#package require unicode

source api.tcl; set lang test ; source langwiki.tcl ; #set token [login $wiki]

#puts [edid 63277 "TaxonBot: Protokoll [utc <- seconds {} %Y-%m-%d {}]" {{{subst:user:Doc Taxon/newSect}}} / section new]

set oc	[conts id 63277 x]
set oc1	[conts id 63277 1]
set nc	"TaxonBot: Protokoll [utc <- seconds {} %Y-%m-%d {}]"

puts [edid 63277 "/* $nc */ new section" "[string map [list $oc1\n\n {}] $oc]\n\n== $nc =="]



