# Tool Labs mysql library

# Copyright 2010, 2012, 2013, 2014 Giftpflanze

# This file is part of the MediaWiki Tcl Bot Framework.

# The MediaWiki Tcl Bot Framework is free software: you can redistribute it
# and/or modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.

package require inifile
package require mysqltcl

set dbuser [string trim [ini::value [set ini [ini::open $env(HOME)/replica.my.cnf r]] client user] '][ini::close $ini][unset ini]

proc get_db {server {db {}}} {
	source replica.my.cnf.1
	while 1 {
		if {$i in {1 2 3}} {incr i} elseif {$i == 4} {set i 1}
#puts $i:[set user$i]
		if [catch {
			set handle [
				mysqlconnect -reconnect 1 -host $server.analytics.db.svc.wikimedia.cloud -db [
					expr {[llength $db]?$db:"${server}_p"}
				] -user [set user$i] -password [set password$i]
			]
		}] {
			puts {... waiting for DB connection ...}
			after 5000
			continue
		} else {
#			puts {... DB connected ...}
			break
		}
	}
	return $handle
}



