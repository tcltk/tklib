#! /usr/bin/env tclsh
# -*- tcl -*-
# # ## ### ##### ######## ############# #####################
# demo_editpoly.tcl --
#
# This demonstration script creates a canvas widget where you can edit
# an ordered cloud of points i.e. a poly-line.
#
# RCS: @(#) $Id: demo_editpoly.tcl,v 1.1 2012/02/24 01:41:22 andreas_kupries Exp $

# # ## ### ##### ######## ############# #####################
## Bindings
#
# Button-1 : Create new line vertex at mouse position.
# Button-2 : Remove line vertex at mouse position.
# Button-3 : Start drag of line vertex at mouse position.

# # ## ### ##### ######## ############# #####################
## Requirements

package require Tcl 8.5-

# Extend the package search path so that this demonstration works with
# the non-installed tklib packages well. A regular application should
# not require this.

apply {{selfdir} {
    #puts ($selfdir)
    lappend ::auto_path $selfdir
    lappend ::auto_path [file normalize $selfdir/../../modules]
}} [file dirname [file normalize [info script]]]

package require Tk
package require canvas::edit::polyline

# # ## ### ##### ######## ############# #####################
## GUI

set w .plot
catch {destroy $w}
wm withdraw .

toplevel       $w
wm title       $w "Canvas :: Editor :: Polygon"
wm iconname    $w "CEP"
set c          $w.c

label  $w.msg -text {} -relief raised -bd 2 -anchor w
button $w.exit  -command ::exit -text Exit
button $w.flip  -command flip   -text Disable
button $w.clear -command clear  -text Clear
canvas $c -relief raised -width 450 -height 300 -bd 2

grid rowconfigure    $w 0 -weight 0
grid rowconfigure    $w 1 -weight 1
grid rowconfigure    $w 2 -weight 0

grid columnconfigure $w 0 -weight 0
grid columnconfigure $w 1 -weight 1
grid columnconfigure $w 2 -weight 0
grid columnconfigure $w 3 -weight 0

grid $w.msg   -row 0 -column 0 -columnspan 4 -sticky swen
grid $c       -row 1 -column 0 -columnspan 4 -sticky swen
grid $w.exit  -row 2 -column 0               -sticky swen
grid $w.flip  -row 2 -column 2               -sticky swen
grid $w.clear -row 2 -column 3               -sticky swen

# # ## ### ##### ######## ############# #####################
## Setup the behavioral triggers and responses ...

# lc to demo polygon filling on highlight
set lc {-line-config { -activefill green -activestipple gray25 }}
set lc {}

canvas::edit polyline EDITOR $c -data-cmd M -closed 1 {*}$lc

proc M {args} {
    global w
    $w.msg configure -text $args
    return
}

# # ## ### ##### ######## ############# #####################
##

proc flip {} {
    global w
    if {[EDITOR active]} {
	EDITOR disable
	$w.flip configure -text Enable
    } else {
	EDITOR enable
	$w.flip configure -text Disable
    }
    return
}

proc clear {} {
    EDITOR clear
}

# # ## ### ##### ######## ############# #####################
## Invoke event loop.

flip

vwait __forever__
exit
