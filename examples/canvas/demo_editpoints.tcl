#!/bin/env tclsh8.5
# -*- tcl -*-
# demo_editpoints.tcl --
#
# This demonstration script creates a canvas widget where you can edit
# a cloud of points, i.e. add, remove, and drag point markers.
#
# RCS: @(#) $Id: demo_editpoints.tcl,v 1.2 2012/02/22 04:42:07 andreas_kupries Exp $

# Bindings
#
# Button-1 : Create new point at mouse position.
# Button-2 : Remove point at mouse position.
# Button-3 : Start drag of point at mouse position.

# # ## ### ##### ######## #############
## Requirements

package require Tcl 8.5

apply {{selfdir} {
    puts ($selfdir)
    lappend ::auto_path $selfdir
}} [file dirname [file normalize [info script]]]

package require Tk
package require canvas::edit::points

# # ## ### ##### ######## #############
## GUI

set w .plot
catch {destroy $w}
wm withdraw .

toplevel       $w
wm title       $w "Canvas Edit Point Cloud"
wm iconname    $w "CEPC"
set c          $w.c

label $w.msg -text {}
pack  $w.msg -side top -anchor w -fill both -expand 1

button $w.exit -command ::exit -text Exit
pack   $w.exit -side bottom -anchor w

button $w.flip -command flip -text Disable
pack   $w.flip -side bottom -anchor w

button $w.clear -command clear -text Clear
pack   $w.clear -side bottom -anchor w

canvas $c -relief raised -width 450 -height 300
pack   $c -side top -fill x

# # ## ### ##### ######## #############
## Setup the behavioral triggers and responses ...

canvas::edit points P $c -point-cmd M

proc M {args} {
    global w
    $w.msg configure -text $args
    lassign $args _ c m
    #puts |$c|$m|
    if {$c eq "move"} {
	switch -exact -- $m {
	    start {}
	    delta {
		global dx dy
		lassign $args c m id x y dx dy
		#puts "|$dx $dy|"
	    }
	    done {
		global dx dy
		#puts "|$dx $dy|[expr {hypot($dx,$dy)}]"
		if {hypot($dx,$dy) > 200} { return 0 }
	    }
	}
    }
    return 1
}

# # ## ### ##### ######## #############
##

proc flip {} {
    global w
    if {[P active]} {
	P disable
	$w.flip configure -text Enable
    } else {
	P enable
	$w.flip configure -text Disable
    }
    return
}

proc clear {} {
    P clear
}

# # ## ### ##### ######## #############
## Invoke event loop.

vwait __forever__
exit
