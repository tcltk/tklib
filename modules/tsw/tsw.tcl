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
    variable version    1.4
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
# Load the package mwutil from the directory "scripts/mwutil".  Take into
# account that it is also included in Mentry, Scrollutil, and Tablelist.
#
proc tsw::loadUtil {} {
    if {[catch {package present mwutil} version] == 0 &&
        [package vcompare $version 2.25] < 0} {
        package forget mwutil
    }
    package require mwutil 2.25[-]
}
tsw::loadUtil

tsw::createBindings
