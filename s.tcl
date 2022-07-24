#!/usr/bin/tclsh8.7

#set editafter 1

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]
set db [get_db dewiki]

package require http
package require tls
package require tdom

