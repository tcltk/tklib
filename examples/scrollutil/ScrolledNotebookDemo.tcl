#!/usr/bin/env wish

#==============================================================================
# Demonstrates the use of the scrollutil::scrollednotebook widget.
#
# Copyright (c) 2021  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

package require scrollutil_tile
set dir [file dirname [info script]]
source [file join $dir styleUtil.tcl]

wm title . "Ttk Library Scripts"

scrollutil::addclosetab My.TNotebook

set pct $scrollutil::scalingpct
image create photo fileImg -file [file join $dir file$pct.gif]

#
# Create a scrollednotebook widget having closable tabs
# and populate it with panes that contain scrolled text
# widgets displaying the contents of the Ttk library files
#
set f  [ttk::frame .f]
set nb [scrollutil::scrollednotebook $f.nb -style My.TNotebook]
cd [expr {[info exists ttk::library] ? $ttk::library : $tile::library}]
foreach fileName [lsort [glob *.tcl]] {
    set baseName [string range $fileName 0 end-4]
    set sa [scrollutil::scrollarea $nb.sa_$baseName -lockinterval 10]
    set txt [text $sa.txt -font TkFixedFont -wrap none]
    catch {$txt configure -tabstyle wordprocessor}	;# for Tk 8.5 and later
    scrollutil::addMouseWheelSupport $txt      ;# adds old-school wheel support
    $sa setwidget $txt

    set chan [open $fileName]
    $txt insert end [read -nonewline $chan]
    close $chan
    $txt configure -state disabled

    set padding [expr {$ttk::currentTheme eq "aqua" ? 0 : "7p"}]
    $nb add $sa -text $fileName -image fileImg -compound left -padding $padding
}

#
# Set the scrollednotebook's width.  Take into account that in the aqua
# theme the -padding option of the TNotebook style is set to {18 8 18 17}
# and the panes are drawn with a hard-coded internal padding of {9 5 9 9}.
#
update idletasks
set width [expr {[winfo reqwidth $sa] + [winfo reqwidth $sa.vsb]}]
incr width [expr {$ttk::currentTheme eq "aqua" ?
	          2*27 : 2*[winfo pixels . 7p] + 4}]
$nb configure -width $width

#
# Create a binding for moving and closing the tabs interactively
#
bind $nb <<MenuItemsRequested>> { populateMenu %W %d }

proc populateMenu {nb data} {
    foreach {menu tabIdx} $data {}
    set tabCount [$nb index end]
    set prevIdx [expr {($tabIdx - 1) % $tabCount}]
    set nextIdx [expr {($tabIdx + 1) % $tabCount}]
    set widget [lindex [$nb tabs] $tabIdx]

    $menu add command -label "Move Tab Left"  -command \
	[list $nb insert $prevIdx $widget]
    $menu add command -label "Move Tab Right" -command \
	[list $nb insert $nextIdx $widget]
    $menu add separator
    $menu add command -label "Close Tab" -command \
	[list $nb forget $tabIdx]
}

#
# Create a ttk::button widget
#
set b [ttk::button $f.b -text "Close" -command exit]

pack $b  -side bottom -pady {0 7p}
pack $nb -side top -expand yes -fill both -padx 7p -pady 7p
pack $f  -expand yes -fill both
