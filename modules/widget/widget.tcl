# -*- tcl -*-
#
# widget.tcl --
#
# megawidget package that uses snit as the object system (snidgets)
#
# Copyright (c) 2005 Jeffrey Hobbs
#

package require Tk 8.4
package require snit

#package provide Widget 3.0 ; # at end

namespace eval ::widget {}

# ::widget::validate --
#
#   Used by widgets for option validate - *private* spec may change
#
# Arguments:
#   as     type to compare as
#   range  range/data info specific to $as
#   option option name
#   value  value being validated
#
# Results:
#   Returns error or empty
#
proc ::widget::isa {as args} {
    foreach {range option value} $args { break }
    if {$as eq "list"} {
	if {[lsearch -exact $range $value] == -1} {
	    return -code error "invalid $option option \"$value\",\
		must be one of [join $data {, }]"
	}
    } elseif {$as eq "boolean" || $as eq "bool"} {
	foreach {option value} $args { break }
	if {![string is boolean -strict $value]} {
	    return -code error "$option requires a boolean value"
	}
    } elseif {$as eq "integer" || $as eq "int"} {
	foreach {min max} $range { break }
	if {![string is integer -strict $value]
	    || ($value < $min) || ($value > $max)} {
	    return -code error "$option requires an integer in the\
		range \[$min .. $max\]"
	}
    } elseif {$as eq "listofinteger" || $as eq "listofint"} {
	if {$range eq ""} { set range [expr {1<<16}] }
	set i 0
	foreach val $value {
	    if {![string is integer -strict $value] || ([incr i] > $range)} {
		return -code error "$option requires an list of integers"
	    }
	}
    } elseif {$as eq "double"} {
	foreach {min max} $range { break }
	if {![string is double -strict $value]
	    || ($value < $min) || ($value > $max)} {
	    return -code error "$option requires a double in the\
		range \[$min .. $max\]"
	}
    } elseif {$as eq "window"} {
	foreach {option value} $args { break }
	if {$value eq ""} { return }
	if {![winfo exists $value]} {
	    return -code error "invalid window \"$value\""
	}
    } else {
	return -code error "unknown validate type \"$as\""
    }
    return
}

package provide widget 3.0
