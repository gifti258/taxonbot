#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]

set nconts [set oconts [conts id 9767885 x]]
set lline [split [conts id 9767885 7] \n]
foreach oline $lline {
	if {[string index $oline 0] eq {*}} {
		set c [regexp -all -- {\[\[} $oline]
		regsub -- {'''\]\] \(\d{1,3}\):} $oline "'''\]\] ([decr c]):" nline
		set nconts [string map [list $oline $nline] $nconts]
	}
}
if {$nconts ne $oconts && $oconts eq [conts id 9767885 x]} {
	puts [edid 9767885 {Bot: Aktualisierung Stimmen zur Jury-Wahl} $nconts / minor]
}
