#!/usr/bin/tclsh8.7
#exit

source api.tcl ; set lang d ; source langwiki.tcl ; #set token [login $wiki]

package require tdom

set body [d_query_raw {
	select ?item ?itemLabel_de ?sitelink_de ?itemLabel_en ?sitelink_en ?ATP_Kennung
	where {
		?item wdt:P536 ?ATP_Kennung.
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
	unset -nocomplain ldatamp qmp
	lappend ldatamp [set qmp [
		dict values [regexp -inline -- {/entity/(.*?)</uri>} $result]
	]]
	lappend ldatamp [
		dict values [regexp -inline -- {ATP_Kennung.*?<literal>(.*?)</literal>} $result]
	]
	lappend ldatamp [join [
		dict values [regexp -inline -- {sitelink_de.*?'de'>(.*?)</literal>} $result]
	]]
	lappend ldatamp [join [
		dict values [regexp -inline -- {itemLabel_de.*?'de'>(.*?)</literal>} $result]
	]]
	lappend ldatamp [join [
		dict values [regexp -inline -- {sitelink_en.*?'en'>(.*?)</literal>} $result]
	]]
	lappend ldatamp [join [
		dict values [regexp -inline -- {itemLabel_en.*?'en'>(.*?)</literal>} $result]
	]]
	lappend lqmp $qmp
	lappend lldatamp $ldatamp
}

foreach qmp [d_qsort $lqmp] {
	foreach ldatamp $lldatamp {
		if {[lindex $ldatamp 0] eq $qmp} {
			lappend nlldatamp $ldatamp
			break
		}
	}
}

save_file tennis0dm.db [join $nlldatamp \n]
puts {File tennis0dm.db saved}

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
	unset -nocomplain ldatafp qfp
	lassign {} inner weekSingles
	lappend ldatafp [set qfp [
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
	set html [getHTML https://www.wtatennis.com/players/[lindex $ldatafp 1]/rankings-history]
	catch {
		set inner [[[dom parse -html [
			regexp -inline -- {<div class="player-header-info__inner">.*?\n                </div>} $html
		]] documentElement] asList]
	}
	set namefp "[string trim [lindex $inner 2 0 2 0 2 0 2 0 1]]\
					[string trim [lindex $inner 2 0 2 0 2 1 2 0 1]]"
	set nationfp [lindex $inner 2 0 2 1 2 0 1 7]
	if [empty nationfp] {
		try {
			set ndom [[[dom parse -html [join [
				regexp -inline -- {<section class="player-scores-overview widget".*?</section>} [
					getHTML https://www.wtatennis.com/players/[
						lindex [split [lindex $ldatafp 1] /] 0
					]/-
				]
			]]] documentElement] asList]
			set namefp "[lindex $ndom 2 0 1 end-4] [lindex $ndom 2 0 1 end-2]"
			set nationfp [lindex $ndom 2 0 1 end]
			set url [split [lindex $ndom 2 0 2 0 2 0 2 1 1 1] /]
			lset ldatafp 1 [lindex $url 2]/[lindex $url 3]
		} on error {} {
			lassign {} namefp nationfp
			lset ldatafp 1 {URL not found}
		}
	}
	lappend ldatafp $namefp
	lappend ldatafp $nationfp

	catch {
		set weekSingles [[[dom parse -html [
			regexp -inline -- {<div class="player-ranking-history__tab" data-ui-tab-week="Singles" data-ui-tab="Singles">.*?\n                </div>} $html
		]] documentElement] asList]
	}
	lappend ldatafp [string trim [lindex $weekSingles 2 0 2 0 2 1 2 0 2 0 2 0 1]]
	lappend ldatafp [string trim [lindex $weekSingles 2 0 2 0 2 1 2 0 2 2 2 0 1]]
	lappend ldatafp [string trim [lindex $weekSingles 2 0 2 0 2 1 2 1 2 2 2 0 1]]
	lappend lqfp $qfp
	lappend lldatafp $ldatafp
puts $ldatafp
}

foreach qfp [d_qsort $lqfp] {
	foreach ldatafp $lldatafp {
		if {[lindex $ldatafp 0] eq $qfp} {
			lappend nlldatafp $ldatafp
			break
		}
	}
}

save_file tennis0df.db [join $nlldatafp \n]
puts {File tennis0df.db saved}
