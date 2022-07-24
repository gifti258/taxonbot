#!/usr/bin/tclsh8.7
#exit

source api.tcl ; set lang d ;	source langwiki.tcl ; #set token [login $wiki]
#source api.tcl ; set lang de ;	source langwiki.tcl ; set btoken [login [set bwiki $wiki]]

#package require http
#package require tls
#package require tdom

while 1 {
	unset -nocomplain sde delabel dedesc sen enlabel endesc snl nllabel nldesc atpadr itfadr 								ref itfref claims preord ord val lnval lpreval lhval

	puts {}
	input mf		{m/f:     }
	switch $mf {
		m	{input atp	{ATP-ID:  }}
		f	{input wta	{WTA-ID:	 }}
	}
	input itf	{ITF-ID:	 }
	input de		{deLemma: }
	input en		{enLemma: }
	input nl		{nlLemma: }
	input land	{Land:    }
	input pre	{Vorname: }
	input name	{Name:	 }
	input birth	{Geburt:	 }
	input loc	{Ort:     }
	input state {Staat:	 }
	input disz	{Disz.:	 }
	input hand  {Hand:	 }
	input w		{Gewicht: }
	input h		{Größe:	 }

	if {$mf eq {m}} {set atp [string toupper $atp]}
	set sde [split $de &]
	set delabel [lindex $sde 0]
	set dedesc "[lindex $sde 1] Tennisspieler[expr {$mf eq {f} ? {in} : {}}]"
	set sen [split $en &]
	set enlabel [lindex $sen 0]
	set endesc "[lindex $sen 1] tennis player"
	set snl [split $nl &]
	set nllabel [lindex $snl 0]
	set nldesc "[lindex $snl 1] tennisser"
	if {$enlabel eq {de}} {set enlabel $delabel}
	switch $nllabel {
		de	{set nllabel $delabel}
		en	{set nllabel $enlabel}
	}
	if {[string first es: [lindex $name 1]] > -1} {
		set esname [lindex [split [lindex $name 1] :] 1]
		set name [lindex $name 0]
	} else {
		set esname {}
	}

	switch $mf {
		m	{
				set atpadr https://www.atptour.com/en/players/-/$atp/overview
				set ref [format {
					-ref {P854 %s P813 {{%s}}}
				} $atpadr [list [utc ^ seconds {} +%Y-%m-%d {}] 11]]
			}
		f	{
				set wtaadr https://www.wtatennis.com/players/$wta
				set ref [format {
					-ref {P854 %s P813 {{%s}}}
				} $wtaadr [list [utc ^ seconds {} +%Y-%m-%d {}] 11]]
			}
	}
	set itfadr https://www.itftennis.com/en/players/$itf
	set itfref [format {
		-ref {P854 %s P813 {{%s}}}
	} $itfadr [list [utc ^ seconds {} +%Y-%m-%d {}] 11]]

	lappend claims [format {
		-p labels -q {de {%s} en {%s} nl {%s}}
	} $delabel $enlabel $nllabel]
	lappend claims [format {
		-p descs -q {de {%s} en {%s} nl {%s}}
	} $dedesc $endesc $nldesc]
	if ![empty loc] {lappend claims [format {P19 -new -datas {{-q %s %s}}} Q$loc $ref]}
	switch $mf {
		m	{lappend claims [format {-p P21 -datas {{-q -new -val Q6581097 %s}}} $ref]}
		f	{lappend claims [format {-p P21 -datas {{-q -new -val Q6581072 %s}}} $ref]}
	}
	if ![empty state] {lappend claims [format {
		-p P27 -datas {{-q -new -val %s %s}}
	} Q$state $ref]}
	lappend claims [format {-p P31 -datas {{-q -new -val Q5 %s}}} $ref]
	lappend claims [format {-p P106 -datas {{-q -new -val Q10833314 %s}}} $ref]
	switch $mf {
		m	{lappend claims [format {-p P536 -datas {{-q -new -val %s %s}}} $atp $ref]}
		f	{lappend claims [format {-p P597 -datas {{-q -new -val %s %s}}} $wta $ref]}
	}
	if ![empty birth] {
		lappend claims [format {
			-p P569 -datas {{-q -new -val {%s} %s}}
		} [list +$birth 11] $ref]
	}
	lappend claims [format {-p P641 -datas {{-q -new -val Q847 %s}}} $ref]
	if ![empty name] {
		if {[llength $name] > 1} {
			foreach val $name {
				lappend lnval [format {
					-q -new -val %s -qual {P1545 %s} %s
				} Q$val [incr ord] $ref]
			}
			lappend claims [format {-p P734 -datas {%s}} $lnval]
		} else {
			lappend claims [format {-p P734 -datas {{-q -new -val %s %s}}} Q$name $ref]
		}
	}
	if ![empty pre] {
		if {[llength $pre] > 1} {
			foreach val $pre {
				lappend lpreval [format {
					-q -new -val %s -qual {P1545 %s} %s
				} Q$val [incr preord] $ref]
			}
			lappend claims [format {-p P735 -datas {%s}} $lpreval]
		} else {
			lappend claims [format {-p P735 -datas {{-q -new -val %s %s}}} Q$pre $ref]
		}
	}
	if ![empty hand] {
		switch $mf {
			m	{set handref $ref}
			f	{set handref $itfref}
		}
		if {[lindex $hand 0] in {ir il}} {
			set handref $itfref
			set hand [string map {ir r il l} $hand]
		}
		foreach val $hand {
			switch $val {
				r	{lappend lhval [format {-q -new -val Q3039938 %s} $handref]}
				l	{lappend lhval [format {-q -new -val Q789447 %s} $handref]}
				1	{lappend lhval [format {-q -new -val Q14420039 %s} $handref]}
				2	{lappend lhval [format {-q -new -val Q14420068 %s} $handref]}
			}
		}
		lappend claims [format {-p P741 -datas {%s}} $lhval]
#		switch $hand {
#		r 			{lappend claims [format {P741 -new -datas {{-q Q3039938 %s}}} $ref]}
#		r1			{lappend claims [format {P741 -new -datas {{-q Q3039938 %s}}} $ref]}
#		r2			{lappend claims [format {P741 -new -datas {{-q Q3039938 %s}}} $ref]}
#		l 			{lappend claims [format {P741 -new -datas {{-q Q789447 %s}}} $ref]}
#		default 	{}
#		}
	}
	lappend claims [format {-p P1532 -datas {{-q -new -val %s %s}}} Q$land $ref]
	if ![empty esname] {
		lappend claims [format {-p P1950 -datas {{-q -new -val %s %s}}} Q$esname $ref]
	}
	if ![empty h] {
		lappend claims [format {
			-p P2048 -datas {{-q -new -val {%s} %s}}
		} [list $h Q174728] $ref]
	}
	if ![empty w] {
		lappend claims [format {
			-p P2067 -datas {{-q -new -val {%s} %s}}
		} [list $w Q11570] $ref]
	}
	switch $disz {
		s			{lappend claims [format {
						-p P2416 -datas {{-q -new -val Q18123880 %s}}
					} $itfref]}
		d			{lappend claims [format {
						-p P2416 -datas {{-q -new -val Q18123885 %s}}
					} $itfref]}
		sd			{lappend claims [format {
						-p P2416 -datas {{-q -new -val Q18123880 %s} {-q -new -val Q18123885 %s}}
					} $itfref $itfref]}
		default 	{}
	}
	lappend claims [format {-p P8618 -datas {{-q -new -val %s %s}}} $itf $itfref]
	puts {}

	d_edit_entity1 new $claims
}



exit

set bodysplayer [lindex [[[
	dom parse -html [
		getHTML https://www.atptour.com/en/rankings/singles?rankRange=1-5000
	]
] documentElement] asList] 2 3 2 7 2 1 2 1 2 1 2 4 2 0 2 0 2 1 2]
set bodydplayer [lindex [[[
	dom parse -html [
		getHTML https://www.atptour.com/en/rankings/doubles?rankRange=1-5000
	]
] documentElement] asList] 2 3 2 7 2 1 2 1 2 1 2 4 2 0 2 0 2 1 2]
foreach trmplayer [join [list $bodysplayer $bodydplayer]] {
	lappend dbmplayer [
		lindex $trmplayer 2 3 2 0 1 3
	] [lindex [split [lindex $trmplayer 2 3 2 0 1 1] /] 4]
}
set f [open tennism0.db w] ; puts $f $dbmplayer ; close $f

for {set pagenr 0} {$pagenr <= 40} {incr pagenr} {
	set bodyfplayer [lindex [
		string toupper [[[dom parse -html [
			getHTML https://www.wtatennis.com/players?page=$pagenr
		]] documentElement] asList]
	] 2 2 2 1 2 0 2 2 2 1 2 1 2 0 2 0 2 1 2 0 2 0 2 0 2 1 2]
	foreach trfplayer $bodyfplayer {
		lappend dbfplayer [
			string trim [lindex $trfplayer 2 0 2 0 2 1 1]
			] [lindex [split [lindex $trfplayer 2 0 2 0 1 1] /] 3
		]
	}
}
set f [open tennisf0.db w] ; puts $f $dbfplayer ; close $f
