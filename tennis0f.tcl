#!/usr/bin/tclsh8.7
#exit

source api.tcl ; set lang d ; source langwiki.tcl ; #set token [login $wiki]

package require tdom

set body [d_query_raw {
	select ?item ?itemLabel_de ?sitelink_de ?itemLabel_en ?sitelink_en ?WTA_Kennung
	where {
		?item wdt:P597 ?WTA_Kennung.
		optional {
			?sitelink_de ^schema:name ?article_de.
			?article_de schema:about ?item; schema:isPartOf <https://de.wikipedia.org/>.
		}
		optional {
			?sitelink_en ^schema:name ?article_en.
			?article_en schema:about ?item; schema:isPartOf <https://en.wikipedia.org/>.
		}
		optional {?item rdfs:label ?itemLabel_de. filter(lang(?itemLabel_de)="de")}
		optional {?item rdfs:label ?itemLabel_en. filter(lang(?itemLabel_en)="en")}
	}
}]

foreach result [dict values [regexp -all -inline -- {<result>\n(.*?)</result>} $body]] {
	unset -nocomplain ldatafp q
	lappend ldatafp [set q [
		dict values [regexp -inline -- {/entity/(.*?)</uri>} $result]
	]]
	lappend ldatafp [
		dict values [regexp -inline -- {WTA_Kennung.*?<literal>(.*?)</literal>} $result]
	]
	lappend ldatafp [join [
		dict values [regexp -inline -- {sitelink_de.*?'de'>(.*?)</literal>} $result]
	]]
	lappend ldatafp [join [
		dict values [regexp -inline -- {itemLabel_de.*?'de'>(.*?)</literal>} $result]
	]]
	lappend ldatafp [join [
		dict values [regexp -inline -- {sitelink_en.*?'en'>(.*?)</literal>} $result]
	]]
	lappend ldatafp [join [
		dict values [regexp -inline -- {itemLabel_en.*?'en'>(.*?)</literal>} $result]
	]]
	set dom [[[dom parse -html [
		getHTML https://www.wtatennis.com/players/[lindex $ldatafp 1]/rankings-history
	]] documentElement] asList]
	set nationfp [lindex $dom 2 1 2 7 2 0 2 1 2 0 2 1 2 0 1 7]
	if [empty nationfp] {
		try {
			set ndom [[[dom parse -html [join [
				regexp -inline -- {<section class="player-scores-overview widget".*?</section>} [
					getHTML https://www.wtatennis.com/players/[
						lindex [split [lindex $ldatafp 1] /] 0
					]/-
				]
			]]] documentElement] asList]
			set nationfp [lindex $ndom 2 0 1 end]
			set url [split [lindex $ndom 2 0 2 0 2 0 2 1 1 1] /]
			lset ldatafp 1 [lindex $url 2]/[lindex $url 3]
		} on error {} {
			set nationfp {}
			lset ldatafp 1 {URL not found}
		}
	}
	lappend ldatafp $nationfp
	set rankbodyfp [split [string map {{\n} |} [
		regexp -inline -- {data-ui-tab-week Singles.*?\n.*?value2.*?value2.*?\n.*?\n} $dom
	]] |]
	lappend ldatafp [string trim [lindex $rankbodyfp 1 end]]
	lappend ldatafp [string trim [lindex $rankbodyfp 3 end]]
	lappend ldatafp [string trim [lindex $rankbodyfp 7 end]]
	lappend lq $q
	lappend lldatafp $ldatafp
}

foreach q [d_qsort $lq] {
	foreach ldatafp $lldatafp {
		if {[lindex $ldatafp 0] eq $q} {
			lappend nlldatafp $ldatafp
			break
		}
	}
}

save_file tennis0df.db [join $nlldatafp \n]
puts {File tennis0df.db saved}
