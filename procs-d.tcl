proc laliases aliases {
	foreach alias $aliases {
		lappend laliases [dict get $alias value]
	}
	return $laliases
}

proc dtab {} {
	global llabels ldescriptions laliases
	foreach {key --} [list {*}$llabels {*}$ldescriptions {*}$laliases] {
		lappend lkey $key
	}
	foreach key [lsort -unique $lkey] {
		lappend tab $key
		foreach lcol [list $llabels $ldescriptions $laliases] {
			if ![catch {dict get $lcol $key}] {lappend tab [dict get $lcol $key]} else {lappend tab {}}
		}
	}
	foreach {key labels -- --} $tab {
		lappend lenkey [string length $key]
		lappend lenlabels [string length $labels]
	}
	set lenkey [lindex [lsort -integer $lenkey] end]
	set lenlabels [lindex [lsort -integer $lenlabels] end]
	foreach {key labels descriptions aliases} $tab {
		set row "$key[string repeat { } [expr $lenkey - [string length $key]]] – $labels"
		lappend lrow [append row "[string repeat { } [expr $lenlabels - [string length $labels]]] – $descriptions     || $aliases"]
	}
	return [join $lrow \n]
}

proc entchange {} {
	global dtab llabels ldescriptions laliases select entchange
	while 1 {
		input lang "\nlang: "
		if [empty lang] {break}
		foreach row [split $dtab \n] {
			if {[lindex [split $row] 0] eq $lang} {puts $row ; break}
		}
		while 1 {
			input change "\nchange label, description or alias: "
			switch $change {
				l			{
								input label "label: "
								set llabels [dict replace $llabels $lang $label]
							}
				d			{
								input description "description: "
								set ldescriptions [dict replace $ldescriptions $lang $description]
							}
				a			{
								while 1 {
									puts "\n[set i 0]: "
									if ![catch {
										foreach alias [set lalias [dict get $laliases $lang]] {
											puts "[incr i]: $alias"
										}
									}] {
										puts "[incr i]: "
									} else {
										set lalias {}
									}
									input select "\nselect: "
									if {$select < 0 || $select > $i} {break}
									decr select
									input alias "alias: "
									set lalias [lreplace $lalias $select $select $alias]
									if [exists entchange] {
										if {$lang ni [set unroman {dty fa he hi mai ml pa ru ta te}]} {
											input allroman "aliases for all Roman spelled items: "
										} else {
											set allroman n
										}
										if {$allroman eq {y}} {
											foreach {lang --} [list {*}$llabels {*}$ldescriptions {*}$laliases] {
												if {$lang in $unroman} {continue}
												set laliases [dict replace $laliases $lang $lalias]
											}
										} else {
											set laliases [dict replace $laliases $lang $lalias]
										}
									} else {
										set laliases [dict replace $laliases $lang $lalias]
									}
								}
							}
				default {break}
			}
		}
	}
	return [dtab]
}

proc entpost title {
	global llabels ldescriptions laliases wiki format token
	foreach col {labels descriptions aliases} {
		foreach {key val} [subst $[subst l$col]] {
			if {$col eq {aliases}} {
				set i 0
				foreach value $val {
					lappend data$col [format {{"language":"%s","value":"%s"%s}} $key $value [expr {[incr i] > 1 ? {,"add":""} : {}}]]
				}
			} else {
				lappend data$col [format {{"language":"%s","value":"%s"}} $key $val]
			}
		}
		lappend data [format {"%s":[%s]} $col [join [subst $[subst data$col]] ,]]
	}
	return [get [post $wiki {*}$format {*}$token / action wbeditentity / id Q$title / data [format {{%s}} [join $data ,]] / bot]]
}
