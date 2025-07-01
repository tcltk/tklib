#! /usr/bin/env tclsh

#==============================================================================
# Demonstrates the use of the toggleswitch widget.
#
# Copyright (c) 2025  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

package require Tk
package require tsw

wm title . "Tsw Demo"

ttk::frame .tf
ttk::frame .bf

#
# Create 3 toggleswitch widgets having different values of the -size option
#
set l1 [ttk::label .tf.l1 -text "Toggle switch of size 1"]
set sw1 [tsw::toggleswitch .tf.sw1 -size 1]
set l2 [ttk::label .tf.l2 -text "Toggle switch of size 2"]
set sw2 [tsw::toggleswitch .tf.sw2 -size 2]
$sw2 switchstate 1
set l3 [ttk::label .tf.l3 -text "Toggle switch of size 3"]
set sw3 [tsw::toggleswitch .tf.sw3 -size 3]

#
# Create a toggleswitch widget of default size and set its -command option
#
set l4 [ttk::label .tf.l4 -text "Enable/disable above widgets"]
set sw4 [tsw::toggleswitch .tf.sw4]
$sw4 switchstate 1
$sw4 configure -command [list toggleWidgetsState $sw4]

#
# Create a ttk::menubutton used to select the theme
#
set mb .bf.mb
ttk::menubutton $mb -menu $mb.m
menu $mb.m -tearoff 0
### set themeList [ttk::style theme names]	;# built-in themes only
set themeList [ttk::themes]			;# third-party themes, too
foreach theme [lsort -dictionary $themeList] {
    $mb.m add command -label $theme -command [list setTheme $theme]
}

#
# Create a ttk::button widget
#
set b [ttk::button .bf.b -text "Close" -command exit]

#------------------------------------------------------------------------------
# toggleWidgetsState
#
# Enables/disables the widgets in the first 3 grid rows, depending on the
# switch state of the specified toggleswitch widget.
#------------------------------------------------------------------------------
proc toggleWidgetsState sw {
    global l1 l2 l3 sw1 sw2 sw3
    set stateSpec [expr {[$sw switchstate] ? "!disabled" : "disabled"}]
    foreach w [list $l1 $l2 $l3 $sw1 $sw2 $sw3] {
	$w state $stateSpec
    }
}

#------------------------------------------------------------------------------
# setTheme
#
# Sets the theme to the specified one and configures the ttk::menubutton and
# its menu accordingly.
#------------------------------------------------------------------------------
proc setTheme theme {
    ttk::setTheme $theme
    global mb l1 l2 l3 l4
    $mb configure -text $theme

    set bg [ttk::style lookup . -background]
    set fg [ttk::style lookup . -foreground {} black]
    $mb.m configure -background $bg -foreground $fg

    foreach opt {-activebackground -activeborderwidth -activeforeground
		 -borderwidth -relief} {
	set defaultVal [lindex [$mb.m configure $opt] 3]
	$mb.m configure $opt $defaultVal
    }

    foreach w [list $l1 $l2 $l3 $l4] {
	$w configure -background "" -foreground ""
    }
}

set origTheme [expr {$argc == 0 ? [ttk::style theme use] : [lindex $argv 0]}]
setTheme $origTheme

#------------------------------------------------------------------------------

#
# Manage the children of .tf
#
grid $l1 $sw1 -pady {9p 0} -sticky w
grid $l2 $sw2 -sticky w
grid $l3 $sw3 -sticky w
grid $l4 $sw4 -pady 6p -sticky w
grid configure $l1 $l2 $l3 $l4 -padx {9p 6p}
grid configure $sw1 $sw2 $sw3 $sw4 -padx {0 9p}
grid columnconfigure .tf 0 -weight 1

#
# Manage the children of .bf
#
grid $mb $b -padx 9p -pady {0 9p} -sticky w
grid configure $b -padx {0 9p}
grid columnconfigure .bf 0 -weight 1

pack .bf -side bottom -fill x
pack .tf -expand yes -fill both
