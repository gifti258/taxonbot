# json.tcl Library

# Parsing json-formatted API return data

# Copyright 2010, 2011 Giftpflanze

# This file is part of the MediaWiki Tcl Bot Framework.

# The MediaWiki Tcl Bot Framework is free software: you can redistribute it
# and/or modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.

package require json

set format {/ format json / maxlag 5}

proc get {json args} {
	return [dict get [json::json2dict $json] {*}$args]
}

# prop info
# prop revisions

proc page {json args} {
	return [dict get [lindex [get $json query pages] 1] {*}$args]
}

proc revision {json args} {
	return [dict get [lindex [page $json revisions] 0] {*}$args]
}

# rvprop content|…

proc contents {json} {
	foreach item [page $json revisions] {
		lappend return [lindex $item 1]
	}
	return $return
}

proc content {json} {
	return [encoding convertfrom [encoding convertto [dict get [revision $json] *]]]
}

# list logevents

proc logevents {json args} {
	return [dict get [lindex [get $json query logevents] 0] {*}$args]
}

# list categorymembers

proc catmem {json} {
	return [get $json query categorymembers]
}

# list allpages

proc allpages {json} {
	return [get $json query allpages]
}

# list usercontribs

proc lastcontrib {json} {
	if [dict exists [lindex [get $json query usercontribs] 0] timestamp] {
		return [dict get [lindex [get $json query usercontribs] 0] timestamp]
	}
}

# list embeddedin

proc embeddedin {json} {
	return [get $json query embeddedin]
}

# list alldeletedrevisions

proc alldeletedrevisions {json} {
	return [get $json query alldeletedrevisions]
}

# list users / usprop blockinfo

proc blocked {json} {
	if [dict exists [lindex [get $json query users] 0] blockexpiry] {
		return [dict get [lindex [get $json query users] 0] blockexpiry]
	}
}

return
