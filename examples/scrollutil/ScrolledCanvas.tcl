#! /usr/bin/env tclsh

#==============================================================================
# Demonstrates the use of the scrollutil::scrollarea widget and of the
# scrollutil::addMouseWheelSupport command in connection with a canvas and two
# ttk::scale widgets.
#
# Copyright (c) 2024-2025  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

package require Tk
package require scrollutil_tile
set dir [file dirname [info script]]
source [file join $dir styleUtil.tcl]

wm title . "Scrolled Canvas"

set scaleFactor [expr {[scrollutil::getScalingPct] / 100.0}]
set width  [expr {13 * 32 * $scaleFactor}]
set height [expr {10 * 32 * $scaleFactor}]
set scrlIncr [expr {16 * $scaleFactor}]

#
# Create a canvas widget within a scrollarea and add mouse wheel support to it
#
set f  [ttk::frame .f]
set sa [scrollutil::scrollarea $f.sa]
set c  [canvas $sa.c -background white -width $width -height $height \
	-xscrollincrement $scrlIncr -yscrollincrement $scrlIncr]
bind $c <Configure> { setScrollRegion %W %w %h }
scrollutil::addMouseWheelSupport $c
$sa setwidget $c

set rows 20
set cols 20

#
# Populate the canvas and then rescale the coordinates
# of all of the items by a factor of $scaleFactor
#
proc populate canv {
    $canv delete all
    global rows cols scaleFactor

    for {set row 0; set y 32} {$row < $rows} {incr row; incr y 96} {
	for {set col 0; set x 32} {$col < $cols} {incr col; incr x 96} {
	    $canv create rectangle $x $y [expr {$x+63}] [expr {$y+63}] \
		-fill gray95
	    $canv create text [expr {$x+32}] [expr {$y+32}] \
		-text "Box\n$row,$col" -anchor center -justify center
	}
    }

    $canv scale all 0 0 $scaleFactor $scaleFactor
}
populate $c

#
# Sets the scroll region of the canvas.
#
proc setScrollRegion {canv width height} {
    global cols rows scaleFactor
    set rightX [expr {($cols*96 + 32) * $scaleFactor}]
    set lowerY [expr {($rows*96 + 32) * $scaleFactor}]
    if {$rightX < $width}  { set rightX $width }
    if {$lowerY < $height} { set lowerY $height }
    $canv configure -scrollregion [list 0 0 $rightX $lowerY]
}

#
# Variables used in the scan-related binding scripts below:
#
set origCursor [$c cget -cursor]
set scanCursor \
    [expr {[tk windowingsystem] eq "aqua" ? "pointinghand" : "hand2"}]

bind $c <Button-2>  { %W scan mark %x %y; %W configure -cursor $scanCursor }
bind $c <B2-Motion> { %W scan dragto %x %y }
bind $c <ButtonRelease-2> { %W configure -cursor $origCursor }

#
# Create a ttk::scale widget for setting the number of box rows
#
set fRows [ttk::frame $f.fRows]
pack [ttk::label $fRows.l1 -text "Rows:"] -side left -padx {0 3p}
pack [ttk::label $fRows.l2 -textvariable rows] -side left -padx {0 3p}
pack [ttk::scale $fRows.scl -from 5 -to 50 -value $rows -command \
      [list setBoxRows $fRows.scl]] -side left -expand yes -fill x

proc setBoxRows {scl val} {
    global rows c
    set val [expr {round($val)}]
    if {$val != $rows} {
	set rows $val
	populate $c
	setScrollRegion $c [winfo width $c] [winfo height $c]
    }
}

#
# Create a ttk::scale widget for setting the number of box columns
#
set fCols [ttk::frame $f.fCols]
pack [ttk::label $fCols.l1 -text "Columns:"] -side left -padx {0 3p}
pack [ttk::label $fCols.l2 -textvariable cols] -side left -padx {0 3p}
pack [ttk::scale $fCols.scl -from 5 -to 50 -value $cols -command \
      [list setBoxCols $fCols.scl]] -side left -expand yes -fill x

proc setBoxCols {scl val} {
    global cols c
    set val [expr {round($val)}]
    if {$val != $cols} {
	set cols $val
	populate $c
	setScrollRegion $c [winfo width $c] [winfo height $c]
    }
}

#
# Add mouse wheel support to the ttk::scale widgets
#
scrollutil::addMouseWheelSupport TScale

#
# Create a ttk::button widget
#
set b [ttk::button $f.b -text "Close" -command exit]

#
# Manage the widgets
#
grid $sa -columnspan 2 -padx 7p -pady 7p -sticky news
grid $fRows $fCols -padx 7p -sticky we
grid $b -columnspan 2 -pady 7p
grid rowconfigure    $f 0 -weight 1
grid columnconfigure $f 0 -weight 1
grid columnconfigure $f 1 -weight 1
pack $f -expand yes -fill both
