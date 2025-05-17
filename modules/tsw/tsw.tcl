#==============================================================================
# Main Tsw package module. 
#
# Copyright (c) 2025  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

namespace eval tsw {
    proc - {} { return [expr {$::tcl_version >= 8.5 ? "-" : ""}] }

    package require Tk 8.6[-]

    if {$::tk_version == 8.6} {
	package require tksvg
    }

    #
    # Public variables:
    #
    variable version    1.1
    variable library    [file dirname [file normalize [info script]]]

    #
    # Creates a new toggleswitch widget:
    #
    namespace export	toggleswitch
}

package provide tsw $tsw::version
package provide Tsw $tsw::version

#
# Everything else needed is lazily loaded on demand, via the dispatcher
# set up in the subdirectory "scripts" (see the file "tclIndex").
#
lappend auto_path [file join $tsw::library scripts]

#
# Load the packages mwutil and (conditionally) scaleutil from
# the directory "scripts/utils".  Take into account that mwutil
# is also included in Mentry, Scrollutil, and Tablelist, and
# scaleutil is also included in Scrollutil and Tablelist.
#
proc tsw::loadUtils {} {
    if {[catch {package present mwutil} version] == 0 &&
        [package vcompare $version 2.25] < 0} {
        package forget mwutil
    }
    package require mwutil 2.25[-]

    if {[info exists ::tk::svgFmt]} {			;# Tk 8.7b1/9 or later
	return ""
    }

    if {[catch {package present scaleutil} version] == 0 &&
	[package vcompare $version 1.15] < 0} {
	package forget scaleutil
    }
    package require scaleutil 1.15[-]
}
tsw::loadUtils

tsw::createBindings
