#! /usr/bin/env tclsh

#==============================================================================
# Demonstrates the interactive tablelist cell editing with the aid of Ttk
# widgets and the configuration of boolean editing options using toggleswitch
# widgets.
#
# Copyright (c) 2005-2025  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

package require Tk
package require tsw
package require tablelist_tile

if {[tk windowingsystem] eq "x11" &&
    ($tk_version < 8.7 || [package vcompare $tk_patchLevel "8.7a5"] <= 0)} {
    #
    # Patch the default theme's styles TCheckbutton and TRadiobutton
    #
    package require themepatch
    themepatch::patch default
}

wm title . "Serial Line Configuration"

#
# Add some entries to the Tk option database
#
set dir [file dirname [info script]]
source [file join $dir option_tile.tcl]

foreach theme {alt clam classic default} {
    #
    # Configure the TSpinbox style
    #
    ttk::style theme settings $theme {
	ttk::style map TSpinbox -fieldbackground {readonly white}
    }
}
unset theme

#
# Create the images "checkedImg" and "uncheckedImg", as well as 16 images of
# names like "img#FF0000", displaying colors identified by names like "red"
#
source [file join $dir images.tcl]

#
# Register the toggleswitch widget for interactive cell editing if supported
#
if {[catch {tablelist::addToggleswitch}] == 0} {	;# Tablelist 7.5+
    set editWin toggleswitch
} else {
    set editWin ttk::checkbutton
}

#
# Improve the window's appearance by using a tile
# frame as a container for the other widgets
#
set f [ttk::frame .f]

#
# Create a tablelist widget with editable columns (except the first one)
#
set tbl $f.tbl
tablelist::tablelist $tbl \
    -columns {0 "No."		right
	      0 "Available"	center
	      0 "Name"		left
	      0 "Baud Rate"	right
	      0 "Data Bits"	center
	      0 "Parity"	left
	      0 "Stop Bits"	center
	      0 "Handshake"	left
	      0 "Cable Color"	center} \
    -editstartcommand editStartCmd -editendcommand editEndCmd \
    -aftercopycommand afterCopyCmd -height 0 -width 0
set isAwTheme \
    [llength [info commands ::ttk::theme::${currentTheme}::setTextColors]]
if {$isAwTheme && ![regexp {^(aw)?(arc|breeze.*)$} $currentTheme]} {
    $tbl configure -borderwidth 2
}
if {[$tbl cget -selectborderwidth] == 0} {
    $tbl configure -spacing 1
}
$tbl columnconfigure 0 -sortmode integer
$tbl columnconfigure 1 -name available -editable yes -editwindow $editWin \
    -formatcommand emptyStr -labelwindow ttk::checkbutton
$tbl columnconfigure 2 -name lineName  -editable yes -editwindow ttk::entry \
    -allowduplicates 0 -sortmode dictionary
$tbl columnconfigure 3 -name baudRate  -editable yes -editwindow ttk::combobox \
    -sortmode integer
$tbl columnconfigure 4 -name dataBits  -editable yes -editwindow ttk::spinbox
$tbl columnconfigure 5 -name parity    -editable yes -editwindow ttk::combobox
$tbl columnconfigure 6 -name stopBits  -editable yes -editwindow ttk::combobox
$tbl columnconfigure 7 -name handshake -editable yes -editwindow ttk::combobox
$tbl columnconfigure 8 -name color     -editable yes \
    -editwindow ttk::menubutton -formatcommand emptyStr

proc emptyStr val { return "" }

#
# Populate the tablelist widget and configure the checkbutton
# embedded into the header label of the column "available"
#
source [file join $dir serialParams.tcl]

set bf [ttk::frame $f.bf]
set b1 [ttk::button $bf.b1 -text "Configure Editing" \
	-command [list configEditing $tbl]]
set b2 [ttk::button $bf.b2 -text "Close" -command exit]

#
# Manage the widgets
#
pack $b2 -side right -padx 9p
pack $b1 -side left -padx 9p
pack $bf -side bottom -fill x -pady 9p
pack $tbl -side top -expand yes -fill both -padx 9p -pady {9p 0}
pack $f -expand yes -fill both

#------------------------------------------------------------------------------
# editStartCmd
#
# Applies some configuration options to the edit window; if the latter is a
# combobox, the procedure populates it.
#------------------------------------------------------------------------------
proc editStartCmd {tbl row col text} {
    set w [$tbl editwinpath]

    switch [$tbl columncget $col -name] {
	lineName {
	    #
	    # Set an upper limit of 20 for the number of characters
	    #
	    $w configure -invalidcommand bell -validate key \
			 -validatecommand {expr {[string length %P] <= 20}}
	}

	baudRate {
	    #
	    # Populate the combobox and allow no more
	    # than 6 digits in its entry component
	    #
	    $w configure -values {50 75 110 300 1200 2400 4800 9600 19200 38400
				  57600 115200 230400 460800 921600}
	    $w configure -invalidcommand bell -validate key -validatecommand \
		{expr {[string length %P] <= 6 && [regexp {^[0-9]*$} %S]}}
	}

	dataBits {
	    #
	    # Configure the spinbox
	    #
	    $w configure -from 5 -to 8 -state readonly
	}

	parity {
	    #
	    # Populate the combobox and make it non-editable
	    #
	    $w configure -values {None Even Odd Mark Space} -state readonly
	}

	stopBits {
	    #
	    # Populate the combobox and make it non-editable
	    #
	    $w configure -values {1 1.5 2} -state readonly
	}

	handshake {
	    #
	    # Populate the combobox and make it non-editable
	    #
	    $w configure -values {XON/XOFF RTS/CTS None} -state readonly
	}

	color {
	    #
	    # Populate the menu and make sure the menubutton will display the
	    # color name rather than $text, which is "", due to -formatcommand
	    #
	    set menu [$w cget -menu]
	    foreach name $::colorNames {
		$menu add radiobutton -compound left \
		    -image img$::colors($name) -label $name
	    }
	    $menu entryconfigure 8 -columnbreak 1
	    return [$tbl cellcget $row,$col -text]
	}
    }

    return $text
}

#------------------------------------------------------------------------------
# editEndCmd
#
# Performs a final validation of the text contained in the edit window and gets
# the cell's internal content.
#------------------------------------------------------------------------------
proc editEndCmd {tbl row col text} {
    switch [$tbl columncget $col -name] {
	available {
	    #
	    # Update the image contained in the cell and the checkbutton
	    # embedded into the header label of the column "available"
	    #
	    set img [expr {$text ? "checkedImg" : "uncheckedImg"}]
	    $tbl cellconfigure $row,$col -image $img
	    after idle [list updateHdrCkbtn $tbl $col]
	}

	baudRate {
	    #
	    # Check whether the baud rate is an integer in the range 50..921600
	    #
	    if {![regexp {^[0-9]+$} $text] || $text < 50 || $text > 921600} {
		bell
		tk_messageBox -title "Error" -icon error -message \
		    "The baud rate must be an integer in the range 50..921600"
		$tbl rejectinput
	    }
	}

	color {
	    #
	    # Update the image contained in the cell
	    #
	    $tbl cellconfigure $row,$col -image img$::colors($text)
	}
    }

    return $text
}

#------------------------------------------------------------------------------
# configEditing
#
# Configures the editing-related tablelist options having boolean values with
# the aid of toggleswitch widgets.
#------------------------------------------------------------------------------
proc configEditing tbl {
    set top .top
    if {[winfo exists $top]} {
	raise $top
	focus $top
	return ""
    }

    toplevel $top
    wm title $top "Editing Options"

    set tf [ttk::frame $top.tf]
    set bf [ttk::frame $top.bf]

    #
    # Create the widgets corresponding to the
    # editing-related options with boolean values
    #
    set row 0
    foreach opt {
	-autofinishediting
	-editendonfocusout
	-editendonmodclick
	-editselectedonly
	-forceeditendcommand
	-instanttoggle
	-showeditcursor
    } {
	lassign [$tbl configure $opt] option dbName dbClass default current
	set defaultStr [expr {$default ? "on" : "off"}]

	set l [ttk::label $tf.l$row -text "$opt ($defaultStr)"]
	if {$current != $default} {
	    $l configure -foreground red3
	}
	grid $l -row $row -column 0 -sticky w -padx 9p -pady {0 3p}

	set sw [tsw::toggleswitch $tf.sw$row]
	$sw switchstate $current	;# sets the switch state to $current
	$sw attrib default $default	;# saves $default as attribute value
	$sw configure -command [list applySwitchState $sw $tbl $opt $l]
	grid $sw -row $row -column 1 -sticky w -padx {0 9p} -pady {0 3p}

	incr row
    }

    grid configure $tf.l0 $tf.sw0 -pady {9p 3p}
    grid columnconfigure $tf 0 -weight 1

    #   
    # Create a ttk::button widget
    #
    set b [ttk::button $bf.b -text "Close" -command [list destroy $top]]
    pack $b -pady {6p 9p}

    pack $bf -side bottom -fill x
    pack $tf -expand yes -fill both
}

#------------------------------------------------------------------------------
# applySwitchState
#
# Sets the configuration option opt of the tablelist tbl and the foreground
# color of the ttk::label l according to the switch state of the toggleswitch
# widget sw.
#------------------------------------------------------------------------------
proc applySwitchState {sw tbl opt l} {
    set switchState [$sw switchstate]
    $tbl configure $opt $switchState

    set fgColor [expr {$switchState == [$sw attrib default] ? "" : "red3"}]
    $l configure -foreground $fgColor
}
