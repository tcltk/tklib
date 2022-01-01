#!/usr/bin/env wish

#==============================================================================
# Demonstrates the use of the scrollutil::pagesman widget having
# scrollutil::plainnotebook widgets as pages.
#
# Copyright (c) 2021-2022  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

package require scrollutil_tile
set dir [file dirname [info script]]
source [file join $dir styleUtil.tcl]

wm title . "Tk Library Files"

set pct $scrollutil::scalingpct
image create photo fileImg   -file [file join $dir file$pct.gif]
image create photo folderImg -file [file join $dir folder$pct.gif]

#
# Populates a given plainnotebook widget with panes that display the contents
# of the files of the specified suffix within the current working directory
#
proc populateNotebook {nb sfx} {
    set panePadding [expr {$ttk::currentTheme eq "aqua" ? 0 : "7p"}]
    foreach fileName [lsort -dictionary [glob *.$sfx]] {
	set baseName [string range $fileName 0 end-4]
	set sa [scrollutil::scrollarea $nb.sa_$baseName]
	if {$sfx eq "gif"} {
	    set canv [canvas $sa.canv -background silver]
	    set img [image create photo -file $fileName]
	    $canv create image 10 10 -anchor nw -image $img
	    set width  [expr {[image width  $img] + 20}]
	    set height [expr {[image height $img] + 20}]
	    $canv configure -scrollregion [list 0 0 $width $height]
	    scrollutil::addMouseWheelSupport $canv
	    $sa setwidget $canv
	} else {
	    $sa configure -lockinterval 10
	    if {$ttk::currentTheme eq "vista"} {
		$sa configure -relief solid
	    }
	    set txt [text $sa.txt -font TkFixedFont -height 30 -takefocus 1 \
		     -wrap none]
	    catch {$txt configure -tabstyle wordprocessor}	;# for Tk 8.5+
	    scrollutil::addMouseWheelSupport $txt   ;# old-school wheel support
	    $sa setwidget $txt

	    set chan [open $fileName]
	    $txt insert end [read -nonewline $chan]
	    close $chan
	    $txt configure -state disabled
	    bind $txt <Button-1> { focus %W } ;# for Tk versions < 8.6.11/8.7a4
	}
	$nb add $sa -text $fileName -image fileImg -compound left \
		    -padding $panePadding
    }
}

#
# Create a pagesman widget
#
set f [ttk::frame .f]
set pm [scrollutil::pagesman $f.pm -leavecommand pmLeaveCmd]

#
# Add option database entries for the -closabletabs,
# -forgetcommand, and -leavecommand plainnotebook options
#
option add *Plainnotebook.closableTabs	1
option add *Plainnotebook.forgetCommand	condCopySel
option add *Plainnotebook.leaveCommand	condCopySel

#
# Create a plainnotebook child displaying the contents of the Tk library files
#
set nbTk [scrollutil::plainnotebook $pm.nbTk]
$pm add $nbTk
$nbTk addbutton 1 "Image Files"	     folderImg
$nbTk addbutton 2 "Message Catalogs" folderImg
$nbTk addbutton 3 "Ttk Scripts"	     folderImg
$nbTk addseparator
$nbTk addlabel "Tk Scripts"
cd $tk_library
populateNotebook $nbTk "tcl"

#
# Create a plainnotebook child displaying the images for the Tcl (Powered) Logo
#
set nbImgs [scrollutil::plainnotebook $pm.nbImgs -caller 0 -title "Image Files"]
$pm add $nbImgs
cd $tk_library/images
populateNotebook $nbImgs "gif"

#
# Create a plainnotebook child displaying the contents of the message catalogs
#
set nbMsgs [scrollutil::plainnotebook $pm.nbMsgs -caller 0 -title \
	    "Message\nCatalogs"]
$pm add $nbMsgs
cd $tk_library/msgs
populateNotebook $nbMsgs "msg"

#
# Create a plainnotebook child displaying the contents of the Ttk library files
#
set nbTtk [scrollutil::plainnotebook $pm.nbTtk -caller 0 -title "Ttk Scripts"]
$pm add $nbTtk
### cd $tk_library/ttk		;# works for Tk versions 8.5a5 and later only
cd [expr {[info exists ttk::library] ? $ttk::library : $tile::library}]
populateNotebook $nbTtk "tcl"

proc pmLeaveCmd {pm nb} {
    return [condCopySel $nb [$nb select]]
}

proc condCopySel {nb widget} {
    global nbImgs
    if {$nb eq $nbImgs || [winfo class $widget] ne "Scrollarea"} {
	return 1
    }

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
foreach nb [list $nbTk $nbImgs $nbMsgs $nbTtk] {
    bind $nb <<MenuItemsRequested>> { populateMenu %W %d }
}

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
pack $pm -side top -expand yes -fill both -padx 7p -pady 7p
pack $f  -expand yes -fill both
