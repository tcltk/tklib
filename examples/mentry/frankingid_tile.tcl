#! /usr/bin/env tclsh

#==============================================================================
# Demonstrates how to implement a multi-entry widget for 20-character
# Franking IDs used by the German postal service (Deutsche Post) for tracking
# and sorting mail pieces.  Franking IDs are usually written as strings of the
# form "XX XXXX XXXX XX XXXX XXXX", where each X is an uppercase hexadecimal
# digit and the last one is a CRC checksum of type CCITT (CRC-4).
#
# Copyright (c) 2025  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

package require Tk
package require mentry_tile

set title "Franking ID"
wm title . $title

#
# Add some entries to the Tk option database
#
source [file join [file dirname [info script]] option_tile.tcl]

#------------------------------------------------------------------------------
# frankingIdMentry
#
# Creates a new mentry widget win that allows to display and edit 20-character
# Franking IDs.  Sets the type attribute of the widget to FrankingId and
# returns the name of the newly created widget.
#------------------------------------------------------------------------------
proc frankingIdMentry {win args} {
    #
    # Create a mentry widget consisting of 6 entries of widths 2, 4, 4, 2, 4,
    # and 4, separated by " " characters, and set its type to FrankingId
    #
    eval [list mentry::mentry $win] $args
    $win configure -body {2 " " 4 " " 4 " " 2 " " 4 " " 4}
    $win attrib type FrankingId

    #
    # Install automatic uppercase conversion and allow only hexadecimal
    # digits in all entry components; use wcb::cbappend (or wcb::cbprepend)
    # instead of wcb::callback in order to keep the wcb::checkEntryLen
    # callback, registered by mentry::mentry for all entry components
    #
    for {set n 0} {$n < 6} {incr n} {
	set w [$win entrypath $n]
	wcb::cbappend $w before insert wcb::convStrToUpper \
		      {wcb::checkStrForRegExp {^[0-9A-F]*$}}
	$win adjustentry $n "0123456789ABCDEF"
	bindtags $w [linsert [bindtags $w] 1 MentryFrankingId]
    }

    return $win
}

#------------------------------------------------------------------------------
# putFrankingId
#
# Outputs the Franking ID id to the mentry widget win of type Franking ID.  The
# Franking ID must be either a string consisting of 20 uppercase hexadecimal
# digits, or a string of the form "XX XXXX XXXX XX XXXX XXXX", where each X is
# an uppercase hexadecimal digit.
#------------------------------------------------------------------------------
proc putFrankingId {id win} {
    #
    # Check the syntax of num
    #
    set expr1 {^[0-9A-F]{20}$}
    set expr2 {^[0-9A-F]{2} [0-9A-F]{4} [0-9A-F]{4} [0-9A-F]{2} [0-9A-F]{4}\
		[0-9A-F]{4}$}
    if {[regexp $expr1 $id]} {
	set isFormatted 0
    } elseif {[regexp $expr2 $id]} {
	set isFormatted 1
    } else {
	return -code error "expected a Franking ID but got \"$id\""
    }

    #
    # Check the widget and display the properly formatted Franking ID
    #
    checkIfFrankingIdMentry $win
    if {$isFormatted} {
	foreach {str0 str1 str2 str3 str4 str5} [split $id " "] {}
	$win put 0 $str0 $str1 $str2 $str3 $str4 $str5
    } else {
	$win put 0 [string range $id 0 1] [string range $id 2 5] \
		   [string range $id 6 9] [string range $id 10 11] \
		   [string range $id 12 15] [string range $id 16 19]
    }
}

#------------------------------------------------------------------------------
# getFrankingId
#
# Returns the Franking ID contained in the mentry widget win of type
# FrankingId, per default formatted as a string of the form
# "XX XXXX XXXX XX XXXX XXXX", where each X is an uppercase hexadecimal digit.
#------------------------------------------------------------------------------
proc getFrankingId {win {formatted 1}} {
    #
    # Check the widget
    #
    checkIfFrankingIdMentry $win

    #
    # Generate an error if any entry component is empty or incomplete.
    # "Incomplete" means in case of the last entry that it has less than
    # 3 characters, and in case of the other entries that it is not full.
    #
    for {set n 0} {$n < 6} {incr n} {
	if {[$win isempty $n]} {
	    focus [$win entrypath $n]
	    return -code error EMPTY
	}

	if {$n == 5} {
	    set w [$win entrypath $n]
	    if {[string length [$w get]] < 3} {
		focus $w
		return -code error INCOMPL
	    }
	} elseif {![$win isfull $n]} {
	    focus [$win entrypath $n]
	    return -code error INCOMPL
	}
    }

    #
    # Return the Franking ID built from the values contained in
    # the entry components and extended by the checksum if needed
    #
    set id [$win getstring]
    if {[string length $id] == 24} {  ;# i.e., last entry contains 3 characters
	append id [crc4 $id]
    } elseif {[string index $id end] ne [crc4 [string range $id 0 end-1]]} {
	focus $w
	return -code error BAD_CRC
    }
    return [expr {$formatted ? $id : [string map {" " ""} $id]}]
}

#------------------------------------------------------------------------------
# checkIfFrankingIdMentry
#
# Generates an error if win is not a mentry widget of type FrankingId.
#------------------------------------------------------------------------------
proc checkIfFrankingIdMentry win {
    if {![winfo exists $win]} {
	return -code error "bad window path name \"$win\""
    }

    if {[winfo class $win] ne "Mentry" || [$win attrib type] ne "FrankingId"} {
	return -code error \
	       "window \"$win\" is not a mentry widget for Franking IDs"
    }
}

#------------------------------------------------------------------------------
# crc4
#
# Returns the CRC-4 checksum of the specified string as an uppercase
# hexadecimal digit.  It is assumed that the string contains ASCII characters
# only.  Space characters (" ") are ignored.  Translated from C# code published
# by ub_coding at the bottom of the page
# https://stackoverflow.com/questions/46971887/crc-4-implementation-for-c-sharp.
#------------------------------------------------------------------------------
proc crc4 str {
    set crc 0
    set poly [expr {0x13 << 3}]			;# 10011000: x**4 + x + 1

    foreach char [split $str ""] {
	if {$char eq " "} {
	    continue
	}

	set code [scan $char %c]
	set crc [expr {$crc ^ $code}]

	for {set n 0} {$n < 8} {incr n} {
	    if {($crc & 0x80) != 0} {
		set crc [expr {$crc ^ $poly}]
	    }

	    set crc [expr {$crc << 1}]
	}
    }

    set crc [expr {$crc >> 4}]
    return [format %X $crc]
}

bind MentryFrankingId <<Paste>> { pasteFrankingId %W }

#------------------------------------------------------------------------------
# pasteFrankingId
#
# Handles <<Paste>> events in the entry component w of a mentry widget for
# Franking IDs by pasting the current contents of the clipboard into the mentry
# if it is a valid Franking ID.
#------------------------------------------------------------------------------
proc pasteFrankingId w {
    set res [catch {::tk::GetSelection $w CLIPBOARD} id]
    if {$res == 0} {
	set win [winfo parent [winfo parent $w]]
	catch { putFrankingId $id $win }
    }

    return -code break ""
}

#------------------------------------------------------------------------------

#
# Improve the window's appearance by using a tile
# frame as a container for the other widgets
#
ttk::frame .base

#
# Frame .base.f with a mentry displaying a Franking ID
#
ttk::frame .base.f
ttk::label .base.f.l -text "A mentry widget for Franking IDs,\nwith automatic\
			    uppercase conversion:"
frankingIdMentry .base.f.me -justify center
pack .base.f.l .base.f.me

#
# Message strings corresponding to the values
# returned by getFrankingId on failure
#
array set msgs {
    EMPTY	"Field value missing"
    INCOMPL	"Incomplete field value"
    BAD_CRC	"Bad CRC-4 checksum"
}

#
# Button .base.get invoking the procedure getFrankingId
#
ttk::button .base.get -text "Get from mentry" -command {
    if {[catch {
	set id ""
	set id [getFrankingId .base.f.me]
    } result] != 0} {
	bell
	tk_messageBox -icon error -message $msgs($result) \
		      -title $title -type ok
    }
}

#
# Label .base.id displaying the result of getFrankingId
#
ttk::label .base.id -textvariable id

#
# Separator .base.sep and button .base.close
#
ttk::separator .base.sep -orient horizontal
ttk::button .base.close -text Close -command exit

#
# Manage the widgets
#
pack .base.close -side bottom -pady 7p
pack .base.sep -side bottom -fill x
pack .base.f -padx 7p -pady 7p
pack .base.get -padx 7p
pack .base.id -padx 7p -pady 7p
pack .base -expand yes -fill both

putFrankingId "36 2FCA 2870 4D 2003 0394" .base.f.me
focus [.base.f.me entrypath 0]
