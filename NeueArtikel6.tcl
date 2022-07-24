#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

#exit

catch {if {[exec pgrep -cxu taxonbot NeueArtikel6.tc] > 1} {exit}}

source api2.tcl
set lang dea ; source langwiki.tcl ; #set token [login $wiki]
source procs.tcl

set db [get_db dewiki]

set t [clock scan [clock format [clock seconds] -format %Y%m%d%T] -format %Y%m%d%T -timezone :Europe/Berlin]
for {set day -29} {$day <= -1} {incr day} {
	set rcdb [read [set f [open rc/rc[clock format [clock add $t $day days] -format %Y%m%d].db r]]] ; close $f
	append mrcdb \n[string trim $rcdb]
}
set f [open rc1 w] ; puts $f [string trim $mrcdb] ; close $f

exit

mysqlreceive $db "
	select rc_timestamp, rc_type, rc_namespace, rc_title, rc_params, rc_log_type
	from recentchanges
	where rc_timestamp >= 20170411103000 and rc_timestamp < 20170411143000 and ((rc_log_type = 'move' and rc_namespace in (0,2)) or (rc_type in (0,1) and rc_namespace in (0,2)) or (rc_log_type = 'import' and rc_namespace in (0,2)))
	order by rc_timestamp
;" {rcts rctyp rcns rct rcp rcltyp} {
	if 1 {
		set log "ts $rcts typ $rctyp ns $rcns title [list [sql -> $rct]]"
		if {$rctyp == 3} {append log " $rcltyp [dict values [regexp -inline -- {"4::target";s:\d{1,3}:"(.*?)";s:10:"5::noredir"} $rcp]]"}
		puts $log
	}
}

