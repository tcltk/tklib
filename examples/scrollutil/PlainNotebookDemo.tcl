#!/usr/bin/env wish

#==============================================================================
# Demonstrates the use of the scrollutil::plainnotebook widget.
#
# Copyright (c) 2021-2022  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

package require scrollutil_tile
set dir [file dirname [info script]]
source [file join $dir styleUtil.tcl]

wm title . "Ttk Library Scripts"

set pct $scrollutil::scalingpct
image create photo fileImg -file [file join $dir file$pct.gif]

#
# Create a plainnotebook widget having closable (and, per default,
# movable) tabs and populate it with panes that contain scrolled
# text widgets displaying the contents of the Ttk library files
#
set f  [ttk::frame .f]
set nb [scrollutil::plainnotebook $f.nb -closabletabs 1 \
	-forgetcommand condCopySel -leavecommand condCopySel]
set currentTheme [ttk::style theme use]
set panePadding [expr {$currentTheme eq "aqua" ? 0 : "7p"}]
cd [expr {[info exists ttk::library] ? $ttk::library : $tile::library}]
foreach fileName [lsort [glob *.tcl]] {
    set baseName [string range $fileName 0 end-4]
    set sa [scrollutil::scrollarea $nb.sa_$baseName -lockinterval 10]
    if {$currentTheme eq "vista"} {
	$sa configure -relief solid
    }
    set txt [text $sa.txt -font TkFixedFont -height 30 -takefocus 1 -wrap none]
    catch {$txt configure -tabstyle wordprocessor}	;# for Tk 8.5 and later
    scrollutil::addMouseWheelSupport $txt	;# old-school wheel support
    $sa setwidget $txt

    set chan [open $fileName]
    $txt insert end [read -nonewline $chan]
    close $chan
    $txt configure -state disabled
    bind $txt <Button-1> { focus %W }	;# for Tk versions < 8.6.11/8.7a4

    $nb add $sa -text $fileName -image fileImg -compound left \
		-padding $panePadding
}

proc condCopySel {nb widget} {
    set txt $widget.txt
    if {[$txt tag nextrange sel 1.0 end] eq ""} {
	return 1
    }

    set btn [tk_messageBox -title "Copy Selection?" -icon question \
	     -message "Do you want to copy the selection to the clipboard?" \
	     -type yesnocancel]
    switch $btn {
	yes	{ tk_textCopy $txt; return 1 }
	no	{ return 1 }
	cancel	{ return 0 }
    }
}

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

    $menu add command -label "Move Tab Up"   -command \
	[list $nb insert $prevIdx $widget]
    $menu add command -label "Move Tab Down" -command \
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
