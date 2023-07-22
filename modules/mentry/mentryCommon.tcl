#==============================================================================
# Main Mentry and Mentry_tile package module.
#
# Copyright (c) 1999-2023  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

if {[catch {package require Wcb 3.1} result1] != 0 &&
    [catch {package require wcb 3.1} result2] != 0} {
    error "$result1; $result2"
}

namespace eval ::mentry {
    #
    # Public variables:
    #
    variable version	3.18
    variable library
    if {$::tcl_version >= 8.4} {
	set library	[file dirname [file normalize [info script]]]
    } else {
	set library	[file dirname [info script]] ;# no "file normalize" yet
    }

    #
    # Creates a new multi-entry widget:
    #
    namespace export	mentry

    #
    # Implement multi-entry widgets for date and time:
    #
    namespace export	dateMentry timeMentry dateTimeMentry \
			putClockVal getClockVal

    #
    # Implement a multi-entry widget for real numbers in fixed-point format:
    #
    namespace export	fixedPointMentry putReal getReal

    #
    # Implement a multi-entry widget for IP addresses:
    #
    namespace export	ipAddrMentry putIPAddr getIPAddr

    #
    # Implement a multi-entry widget for IPv6 addresses:
    #
    namespace export	ipv6AddrMentry putIPv6Addr getIPv6Addr
}

package provide mentry::common $::mentry::version

if {$::tcl_version >= 8.4} {
    interp alias {} ::mentry::addVarTrace {} trace add variable
} else {
    proc ::mentry::addVarTrace {name ops cmd} {
	set ops2 ""
	foreach op $ops { append ops2 [string index $op 0] }
	trace variable $name $ops2 $cmd
    }
}

#
# The following procedure, invoked in "mentry.tcl" and
# "mentry_tile.tcl", sets the variable ::mentry::usingTile
# to the given value and sets a trace on this variable.
#
proc ::mentry::useTile {bool} {
    variable usingTile $bool
    addVarTrace usingTile {write unset} [list ::mentry::restoreUsingTile $bool]
}

#
# The following trace procedure is executed whenever the variable
# ::mentry::usingTile is written or unset.  It restores the variable to its
# original value, given by the first argument.
#
proc ::mentry::restoreUsingTile {origVal varName index op} {
    variable usingTile $origVal
    switch -glob $op {
	w* {
	    return -code error "it is not supported to use both Mentry and\
				Mentry_tile in the same application"
	}
	u* {
	    addVarTrace usingTile {write unset} \
		[list ::mentry::restoreUsingTile $origVal]
	}
    }
}

proc ::mentry::createTkAliases {} {
    foreach cmd {frame entry label} {
	if {[llength [info commands ::tk::$cmd]] == 0} {
	    interp alias {} ::tk::$cmd {} ::$cmd
	}
    }
}
::mentry::createTkAliases

#
# Everything else needed is lazily loaded on demand, via the dispatcher
# set up in the subdirectory "scripts" (see the file "tclIndex").
#
lappend auto_path [file join $::mentry::library scripts]

#
# Load the package mwutil from the directory "scripts/mwutil".  Take
# into account that it is also included in Scrollutil and Tablelist.
#
if {[catch {package present mwutil} version] == 0 &&
    [package vcompare $version 2.20] < 0} {
    package forget mwutil
}
package require mwutil 2.20
