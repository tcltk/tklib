#==============================================================================
# Contains the main scaling-related utility procedure.
#
# Structure of the module:
#   - Namespace initialization
#   - Public utility procedure
#   - Private helper procedures
#
# Copyright (c) 2020  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

package require Tk 8

#
# Namespace initialization
# ========================
#

namespace eval scaleutil {
    #
    # Public variables:
    #
    variable version	1.1
    variable library
    if {$::tcl_version >= 8.4} {
	set library	[file dirname [file normalize [info script]]]
    } else {
	set library	[file dirname [info script]] ;# no "file normalize" yet
    }

    #
    # Public procedure:
    #
    namespace export	scalingPercentage
}

package provide scaleutil $scaleutil::version

#
# Public utility procedure
# ========================
#

#------------------------------------------------------------------------------
# scaleutil::scalingPercentage
#
# Returns the display's current scaling percentage (100, 125, 150, 175, or 200).
#------------------------------------------------------------------------------
proc scaleutil::scalingPercentage winSys {
    variable onX11 [expr {[string compare $winSys "x11"] == 0}]
    set pct [expr {[tk scaling] * 75}]

    if {$onX11} {
	set factor 1
	if {[catch {exec ps -e | grep xfce}] == 0} {			;# Xfce
	    if {[catch {exec xfconf-query -c xsettings \
		 -p /Gdk/WindowScalingFactor} result] == 0} {
		set factor $result
		set pct [expr {100 * $factor}]
	    }
	} elseif {[catch {exec ps -e | grep mate}] == 0} {		;# MATE
	    if {[catch {exec gsettings get org.mate.interface \
		 window-scaling-factor} result] == 0} {
		if {$result == 0} {			;# means: "Auto-detect"
		    #
		    # Try to get the scaling factor from the cursor size
		    #
		    if {[catch {exec xrdb -query | grep Xcursor.size} \
			 result] == 0 &&
			[catch {exec gsettings get org.mate.peripherals-mouse \
			 cursor-size} defCursorSize] == 0} {
			scan $result "%*s %d" cursorSize
			set factor [expr {($cursorSize + $defCursorSize - 1) /
					  $defCursorSize}]
			set pct [expr {100 * $factor}]
		    }
		} else {
		    set factor $result
		    set pct [expr {100 * $factor}]
		}
	    }
	} elseif {[catch {exec gsettings get \
		   org.gnome.settings-daemon.plugins.xsettings overrides} \
		   result] == 0 &&
		  [set idx \
		   [string first "'Gdk/WindowScalingFactor'" $result]] >= 0} {
	    scan [string range $result $idx end] "%*s <%d>" factor
	    set pct [expr {100 * $factor}]
	} elseif {[catch {exec xrdb -query | grep Xft.dpi} result] == 0} {
	    scan $result "%*s %f" dpi
	    set pct [expr {100 * $dpi / 96}]
	} elseif {$::tk_version >= 8.3 &&
		  [catch {exec ps -e | grep gnome}] == 0 &&
		  ![info exists ::env(WAYLAND_DISPLAY)] &&
		  [catch {exec xrandr | grep " connected"} result] == 0 &&
		  [catch {open $::env(HOME)/.config/monitors.xml} chan] == 0} {
	    #
	    # Update pct by scanning the file ~/.config/monitors.xml
	    #
	    scanMonitorsFile $chan pct
	}

	#
	# Conditionally correct and then scale the sizes of the standard fonts
	#
	if {$::tk_version >= 8.5} {
	    scaleX11Fonts $factor
	}
    }

    if {$pct < 100 + 12.5} {
	set pct 100
    } elseif {$pct < 125 + 12.5} {
	set pct 125 
    } elseif {$pct < 150 + 12.5} {
	set pct 150 
    } elseif {$pct < 175 + 12.5} {
	set pct 175 
    } else {
	set pct 200
    }

    if {$onX11} {
	tk scaling [expr {$pct / 75.0}]

	if {$pct > 100} {
	    #
	    # Scale the default scrollbar width
	    #
	    set helpScrlbar .__helpScrlbar
	    for {set n 2} {[winfo exists $helpScrlbar]} {incr n} {
		set helpScrlbar .__helpScrlbar$n
	    }
	    scrollbar $helpScrlbar
	    set defScrlbarWidth [lindex [$helpScrlbar configure -width] 3]
	    destroy $helpScrlbar
	    set scrlbarWidth [expr {$defScrlbarWidth * $pct / 100}]
	    option add *Scrollbar.width $scrlbarWidth userDefault
	}
    }

    if {$::tk_version >= 8.5} {
	#
	# Scale a few styles for the built-in themes
	# "alt", "clam", "classic", and "default"
	#
	scaleStyles $pct

	#
	# For the "xpnative" and "vista" themes work around a bug
	# related to the scaling of ttk::checkbutton and ttk::radiobutton
	# widgets in Tk releases no later than 8.6.10 and 8.7a3
	#
	if {$pct > 100 &&
	    ([package vcompare $::tk_patchLevel "8.6.10"] <= 0 ||
	     ($::tk_version == 8.7 &&
	      [package vcompare $::tk_patchLevel "8.7a3"] <= 0))} {
	    foreach theme {xpnative vista} {
		if {[lsearch -exact [ttk::style theme names] $theme] >= 0} {
		    patchWinTheme $theme $pct
		}
	    }
	}
    }

    return $pct
}

#
# Private helper procedures
# =========================
#

#------------------------------------------------------------------------------
# scaleutil::scanMonitorsFile
#
# Updates the scaling percentage by scanning the file ~/.config/monitors.xml.
#------------------------------------------------------------------------------
proc scaleutil::scanMonitorsFile {chan pctName} {
    upvar $pctName pct

    #
    # Get the list of connected outputs reported by xrandr
    #
    set outputList {}
    foreach line [split $result "\n"] {
	set idx [string first " " $line]
	set output [string range $line 0 [incr idx -1]]
	lappend outputList $output
    }
    set outputList [lsort $outputList]

    #
    # Get the content of the file ~/.config/monitors.xml
    #
    set str [read $chan]
    close $chan

    #
    # Run over the file's "configuration" sections
    #
    set idx 0
    while {[set idx2 [string first "<configuration>" $str $idx]] >= 0} {
	set idx2 [string first ">" $str $idx2]
	set idx [string first "</configuration>" $str $idx2]
	set config [string range $str [incr idx2] [incr idx -1]]

	#
	# Get the list of connectors within this configuration
	#
	set connectorList {}
	foreach {dummy connector} [regexp -all -inline \
		{<connector>([^<]+)</connector>} $config] {
	    lappend connectorList $connector
	}
	set connectorList [lsort $connectorList]

	#
	# If $outputList and $connectorList are identical then set the
	# variable pct to 100 or 200, depending on the max. scaling
	# within this configuration, and exit the loop.  (Due to the
	# way fractional scaling is implemented in GNOME, we have to
	# set the variable pct to 200 rather than 125, 150, or 175.)
	#
	if {[string compare $outputList $connectorList] == 0} {
	    set maxScaling 0.0
	    foreach {dummy scaling} [regexp -all -inline \
		    {<scale>([^<]+)</scale>} $config] {
		if {$scaling > $maxScaling} {
		    set maxScaling $scaling
		}
	    }
	    set pct [expr {$maxScaling > 1.0 ? 200 : 100}]
	    break
	}
    }
}

#------------------------------------------------------------------------------
# scaleutil::scaleX11Fonts
#
# If needed, corrects the sizes of the standard fonts on X11 by replacing the
# sizes in pixels contained in the library file ttk/fonts.tcl with sizes in
# points, and then multiplies them with $factor.
#------------------------------------------------------------------------------
proc scaleX11Fonts factor {
    if {$factor > 2} {
	set factor 2
    }

    set chan [open $::tk_library/ttk/fonts.tcl]
    set str [read $chan]
    close $chan

    set idx [string first "courier" $str]
    set str [string range $str $idx end]

    set idx [string first "F(size)" $str]
    scan [string range $str $idx end] "%*s %d" size
    set points [expr {$size < 0 ? 9 : $size}]		;# -12 -> 9, else 10
    foreach font {TkDefaultFont TkTextFont TkHeadingFont
		  TkIconFont TkMenuFont} {
	if {[font actual $font -size] == $points} {
	    font configure $font -size [expr {$factor * $points}]
	}
    }

    set idx [string first "F(ttsize)" $str]
    scan [string range $str $idx end] "%*s %d" size
    set points [expr {$size < 0 ? 8 : $size}]		;# -10 -> 8, else 9
    foreach font {TkTooltipFont TkSmallCaptionFont} {
	if {[font actual $font -size] == $points} {
	    font configure $font -size [expr {$factor * $points}]
	}
    }

    set idx [string first "F(capsize)" $str]
    scan [string range $str $idx end] "%*s %d" size
    set points [expr {$size < 0 ? 11 : $size}]		;# -14 -> 11, else 12
    if {[font actual TkCaptionFont -size] == $points} {
	font configure TkCaptionFont -size [expr {$factor * $points}]
    }

    set idx [string first "F(fixedsize)" $str]
    scan [string range $str $idx end] "%*s %d" size
    set points [expr {$size < 0 ? 9 : $size}]		;# -12 -> 9, else 10
    if {[font actual TkFixedFont -size] == $points} {
	font configure TkFixedFont -size [expr {$factor * $points}]
    }
}

#------------------------------------------------------------------------------
# scaleutil::scaleStyles
#
# Scales a few styles for the "alt", "clam", "classic", and "default" themes.
#------------------------------------------------------------------------------
proc scaleutil::scaleStyles pct {
    #
    # For the "alt", "clam", "classic", and "default" themes scale the
    # values of the -arrowsize and -width TScrollbar options, as well
    # as the value of the -arrowsize TCombobox and TSpinbox option
    #
    set comboboxArrowSize [expr {12 * $pct / 100}]
    set spinboxArrowSize [expr {10 * $pct / 100}]
    foreach theme {alt clam classic default} {
	switch $theme {
	    alt -
	    clam    { set scrlbarWidth [expr {14 * $pct / 100}] }
	    classic { set scrlbarWidth [expr {15 * $pct / 100}] }
	    default { set scrlbarWidth [expr {13 * $pct / 100}] }
	}

	ttk::style theme settings $theme {
	    ttk::style configure TScrollbar \
		-arrowsize $scrlbarWidth -width $scrlbarWidth
	    ttk::style configure TCombobox -arrowsize $comboboxArrowSize
	    ttk::style configure TSpinbox -arrowsize $spinboxArrowSize
	}
    }

    #
    # For the "alt" theme scale the value
    # of the -arrowsize TMenubutton option
    #
    set menubtnArrowSize [expr {5 * $pct / 100}]
    ttk::style theme settings alt {
	ttk::style configure TMenubutton -arrowsize $menubtnArrowSize
    }

    #
    # For the "clam" theme scale the value of the
    # -arrowsize TMenubutton option, as well as that of the
    # -indicatorsize TCheckbutton and TRadiobutton option
    #
    set indicatorSize [expr {10  * $pct / 100}]
    ttk::style theme settings clam {
	ttk::style configure TMenubutton -arrowsize $menubtnArrowSize
	foreach style {TCheckbutton TRadiobutton} {
	    ttk::style configure $style -indicatorsize $indicatorSize
	}
    }

    #
    # For the "classic" and "default" themes scale the value of
    # the -indicatordiameter TCheckbutton and TRadiobutton option
    #
    set indicatorDiam [expr {10 * $pct / 100}]
    foreach theme {classic default} {
	ttk::style theme settings $theme {
	    foreach style {TCheckbutton TRadiobutton} {
		ttk::style configure $style -indicatordiameter $indicatorDiam
	    }
	}
    }
}

#------------------------------------------------------------------------------
# scaleutil::patchWinTheme
#
# Works around a bug related to the scaling of ttk::checkbutton and
# ttk::radiobutton widgets in the "xpnative" and "vista" themes.
#------------------------------------------------------------------------------
proc scaleutil::patchWinTheme {theme pct} {
    ttk::style theme settings $theme {
	#
	# Create the Checkbutton.vsapi_indicator and
	# Radiobutton.vsapi_indicator elements.  Due to the
	# way the vsapi element factory is implemented, we
	# have to set the -height and -width options to half
	# of the desired element height and width, respectively.
	#
	array set arr {125 8  150 10  175 10  200 13}
	set height $arr($pct)
	set width [expr {$height + 4}]
	ttk::style element create Checkbutton.vsapi_indicator vsapi BUTTON 3 {
	    {alternate disabled} 12  {alternate pressed} 11
	    {alternate active} 10  alternate 9
	    {selected disabled} 8  {selected pressed} 7
	    {selected active} 6  selected 5
	    disabled 4  pressed 3  active 2  {} 1
	} -height $height -width $width
	ttk::style element create Radiobutton.vsapi_indicator vsapi BUTTON 2 {
	    {alternate disabled} 4  alternate 1
	    {selected disabled} 8  {selected pressed} 7
	    {selected active} 6  selected 5
	    disabled 4  pressed 3  active 2  {} 1
	} -height $height -width $width

	#
	# Redefine the TCheckbutton and TRadiobutton layouts
	#
	ttk::style layout TCheckbutton {
	    Checkbutton.padding -sticky nswe -children {
		Checkbutton.vsapi_indicator -side left -sticky ""
		Checkbutton.focus -side left -sticky w -children {
		    Checkbutton.label -sticky nswe
		}
	    }
	}
	ttk::style layout TRadiobutton {
	    Radiobutton.padding -sticky nswe -children {
		Radiobutton.vsapi_indicator -side left -sticky ""
		Radiobutton.focus -side left -sticky w -children {
		    Radiobutton.label -sticky nswe
		}
	    }
	}

	#
	# Patch the padding of TCheckbutton and TRadiobutton, so widgets of
	# these styles will look as if they had a uniform padding of 2, as
	# set in the library files ttk/xpTheme.tcl and ttk/vistaTheme.tcl
	#
	ttk::style configure TCheckbutton -padding {-2 2 2 2}
	ttk::style configure TRadiobutton -padding {-2 2 2 2}
    }
}
