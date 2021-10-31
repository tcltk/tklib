#==============================================================================
# Contains the main scaling-related utility procedure.
#
# Structure of the module:
#   - Namespace initialization
#   - Public utility procedures
#   - Private helper procedures
#
# Copyright (c) 2020-2021  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
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
    variable version	1.6
    variable library
    if {$::tcl_version >= 8.4} {
	set library	[file dirname [file normalize [info script]]]
    } else {
	set library	[file dirname [info script]] ;# no "file normalize" yet
    }

    #
    # Public procedures:
    #
    namespace export	scalingPercentage scale
}

package provide scaleutil $scaleutil::version

#
# Public utility procedures
# =========================
#

#------------------------------------------------------------------------------
# scaleutil::scalingPercentage
#
# Returns the display's current scaling percentage (100, 125, 150, 175, or 200).
#------------------------------------------------------------------------------
proc scaleutil::scalingPercentage winSys {
    set onX11 [expr {[string compare $winSys "x11"] == 0}]
    set pct [expr {[tk scaling] * 75}]

    if {$onX11} {
	set factor 1
	set changed 0
	if {[catch {exec ps -e | grep xfce}] == 0} {			;# Xfce
	    if {[catch {exec xfconf-query -c xsettings \
		 -p /Gdk/WindowScalingFactor} result] == 0} {
		set factor $result
		set pct [expr {100 * $factor}]
		set changed 1
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
			set changed 1
		    }
		} else {
		    set factor $result
		    set pct [expr {100 * $factor}]
		    set changed 1
		}
	    }
	} elseif {[catch {exec gsettings get \
		   org.gnome.settings-daemon.plugins.xsettings overrides} \
		   result] == 0 &&
		  [set idx \
		   [string first "'Gdk/WindowScalingFactor'" $result]] >= 0} {
	    scan [string range $result $idx end] "%*s <%d>" factor
	    set pct [expr {100 * $factor}]
	    set changed 1
	} elseif {[catch {exec xrdb -query | grep Xft.dpi} result] == 0} {
	    scan $result "%*s %f" dpi
	    set pct [expr {100 * $dpi / 96}]
	    set changed 1
	} elseif {$::tk_version >= 8.3 &&
		  [catch {exec ps -e | grep gnome}] == 0 &&
		  ![info exists ::env(WAYLAND_DISPLAY)] &&
		  [catch {exec xrandr | grep " connected"} result] == 0 &&
		  [catch {open $::env(HOME)/.config/monitors.xml} chan] == 0} {
	    #
	    # Update pct by scanning the file ~/.config/monitors.xml
	    #
	    scanMonitorsFile $result $chan pct
	    set changed 1
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
    } elseif {$pct < 200 + 12.5} {
	set pct 200
    } else {
	set pct [expr {int($pct + 0.5)}]	;# temporarily (see return)
    }

    if {$pct == 100} {
	return 100
    }

    #
    # Scale the default parameters of the panedwindow sash
    #
    option add *Panedwindow.handlePad		[scale 8 $pct] widgetDefault
    option add *Panedwindow.handleSize		[scale 8 $pct] widgetDefault
    if {$::tk_version >= 8.5} {
	option add *Panedwindow.sashPad		0 widgetDefault
	option add *Panedwindow.sashWidth	[scale 3 $pct] widgetDefault
    } else {
	option add *Panedwindow.sashPad		[scale 2 $pct] widgetDefault
	option add *Panedwindow.sashWidth	[scale 2 $pct] widgetDefault
    }

    #
    # Scale the default size of the scale widget and its slider
    #
    option add *Scale.length		$pct widgetDefault
    option add *Scale.sliderLength	[scale 30 $pct] widgetDefault
    option add *Scale.width		[scale 15 $pct] widgetDefault

    if {$onX11} {
	if {$changed} {
	    tk scaling [expr {$pct / 75.0}]
	}

	#
	# Conditionally correct and then scale the sizes of the standard fonts
	#
	if {$::tk_version >= 8.5} {
	    scaleX11Fonts $factor
	}

	#
	# Scale the default scrollbar width
	#
	if {$::tk_version >= 8.5} {
	    option add *Scrollbar.width	[scale 11 $pct] widgetDefault
	} else {
	    option add *Scrollbar.width [scale 15 $pct] widgetDefault
	}
    }

    if {$::tk_version >= 8.5} {
	#
	# Scale the default ttk::scale and ttk::progressbar length
	#
	option add *TScale.length	$pct widgetDefault
	option add *TProgressbar.length	$pct widgetDefault

	#
	# Scale the default height of the ttk::treeview rows
	#
	set font [ttk::style lookup Treeview -font]
	ttk::style configure Treeview \
	    -rowheight [expr {[font metrics $font -linespace] + 3}]

	#
	# Scale a few styles for the built-in themes
	# "alt", "clam", "classic", and "default"
	#
	foreach theme {alt clam classic default} {
	    scaleStyles_$theme $pct
	}

	#
	# Scale a few styles for the "vista" and "xpnative" themes
	#
	foreach theme {vista xpnative} {
	    if {[lsearch -exact [ttk::style theme names] $theme] >= 0} {
		scaleWinStyles $theme $pct
	    }
	}

	#
	# For the "vista" and "xpnative" themes work around a bug
	# related to the scaling of ttk::checkbutton and ttk::radiobutton
	# widgets in Tk releases no later than 8.6.10 and 8.7a3
	#
	if {[package vcompare $::tk_patchLevel "8.6.10"] <= 0 ||
	    ($::tk_version == 8.7 &&
	     [package vcompare $::tk_patchLevel "8.7a3"] <= 0)} {
	    foreach theme {vista xpnative} {
		if {[lsearch -exact [ttk::style theme names] $theme] >= 0} {
		    patchWinTheme $theme $pct
		}
	    }
	}
    }

    return [expr {$pct > 200 ? 200 : $pct}]
}

#------------------------------------------------------------------------------
# scaleutil::scale
#
# Scales a positive integer according to a given scaling percentage.
#------------------------------------------------------------------------------
proc scaleutil::scale {num pct} {
    set factor [expr {$num * $pct}]
    set result [expr {$factor / 100}]
    if {$factor % 100 >= 50} {
	incr result
    }

    return $result
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
proc scaleutil::scanMonitorsFile {xrandrResult chan pctName} {
    upvar $pctName pct

    #
    # Get the list of connected outputs reported by xrandr
    #
    set outputList {}
    foreach line [split $xrandrResult "\n"] {
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
proc scaleutil::scaleX11Fonts factor {
    if {$factor > 2} {
	set factor 2
    }

    set chan [open $::tk_library/ttk/fonts.tcl]
    set str [read $chan]
    close $chan

    set idx [string first "courier" $str]
    set str [string range $str $idx end]

    set idx [string first "size" $str]
    scan [string range $str $idx end] "%*s %d" size
    set points [expr {$size < 0 ? 9 : $size}]		;# -12 -> 9, else 10
    foreach font {TkDefaultFont TkTextFont TkHeadingFont
		  TkIconFont TkMenuFont} {
	font configure $font -size [expr {$factor * $points}]
    }

    set idx [string first "ttsize" $str]
    scan [string range $str $idx end] "%*s %d" size
    set points [expr {$size < 0 ? 8 : $size}]		;# -10 -> 8, else 9
    foreach font {TkTooltipFont TkSmallCaptionFont} {
	font configure $font -size [expr {$factor * $points}]
    }

    set idx [string first "capsize" $str]
    scan [string range $str $idx end] "%*s %d" size
    set points [expr {$size < 0 ? 11 : $size}]		;# -14 -> 11, else 12
    font configure TkCaptionFont -size [expr {$factor * $points}]

    set idx [string first "fixedsize" $str]
    scan [string range $str $idx end] "%*s %d" size
    set points [expr {$size < 0 ? 9 : $size}]		;# -12 -> 9, else 10
    font configure TkFixedFont -size [expr {$factor * $points}]
}

#------------------------------------------------------------------------------
# scaleutil::scaleStyles_alt
#
# Scales a few styles for the "alt" theme.
#------------------------------------------------------------------------------
proc scaleutil::scaleStyles_alt pct {
    ttk::style theme settings alt {
	set scrlbarWidth [scale 14 $pct]
	ttk::style configure TScrollbar \
	    -arrowsize $scrlbarWidth -width $scrlbarWidth

	ttk::style configure TScale -groovewidth [scale 4 $pct] \
	    -sliderthickness [scale 15 $pct]

	ttk::style configure TProgressbar -barsize [scale 30 $pct] \
	    -thickness [scale 15 $pct]

	ttk::style configure TCombobox -arrowsize [scale 14 $pct]
	ttk::style configure TSpinbox -arrowsize [scale 10 $pct]

	ttk::style configure TButton -padding [scale 1 $pct]
	ttk::style configure Toolbutton -padding [scale 2 $pct]

	ttk::style configure TMenubutton -arrowsize [scale 5 $pct] \
	    -padding [scale 3 $pct]

	set t [scale 2 $pct]; set r [scale 4 $pct]; set b $t
	set indicatorMargin [list 0 $t $r $b]			;# {0 2 4 2}
	foreach style {TCheckbutton TRadiobutton} {
	    ttk::style configure $style -indicatormargin $indicatorMargin \
		-padding [scale 2 $pct]
	}

	set l [scale 2 $pct]; set t $l; set r [scale 1 $pct]
	set margins [list $l $t $r 0]				;# {2 2 1 0}
	ttk::style configure TNotebook -tabmargins $margins
	ttk::style configure TNotebook.Tab \
	    -padding [list [scale 4 $pct] [scale 2 $pct]]
	ttk::style map TNotebook.Tab -expand [list selected $margins]
    }
}

#------------------------------------------------------------------------------
# scaleutil::scaleStyles_clam
#
# Scales a few styles for the "clam" theme.
#------------------------------------------------------------------------------
proc scaleutil::scaleStyles_clam pct {
    ttk::style theme settings clam {
	set scrlbarWidth [scale 14 $pct]
	ttk::style configure TScrollbar -gripcount [scale 5 $pct] \
	    -arrowsize $scrlbarWidth -width $scrlbarWidth

	ttk::style configure TScale -sliderlength [scale 30 $pct] \
	    -arrowsize $scrlbarWidth

	ttk::style configure TProgressbar -sliderlength [scale 30 $pct] \
	    -arrowsize $scrlbarWidth

	ttk::style configure TCombobox -arrowsize [scale 14 $pct]
	ttk::style configure TSpinbox -arrowsize [scale 10 $pct]

	ttk::style configure TButton -padding [scale 5 $pct]
	ttk::style configure Toolbutton -padding [scale 2 $pct]

	ttk::style configure TMenubutton -arrowsize [scale 5 $pct] \
	    -padding [scale 5 $pct]

	set l [scale 1 $pct]; set t $l; set r [scale 4 $pct]; set b $l
	set indicatorMargin [list $l $t $r $b]			;# {1 1 4 1}
	foreach style {TCheckbutton TRadiobutton} {
	    ttk::style configure $style -indicatorsize [scale 10 $pct] \
		-indicatormargin $indicatorMargin -padding [scale 2 $pct]
	}

	set l [scale 6 $pct]; set t [scale 2 $pct]; set r $l; set b $t
	ttk::style configure TNotebook.Tab \
	    -padding [list $l $t $r $b]				;# {6 2 6 2}
	set t [scale 4 $pct]
	ttk::style map TNotebook.Tab \
	    -padding [list selected [list $l $t $r $b]]		;# {6 4 6 2}

	ttk::style configure Sash -sashthickness [scale 6 $pct] \
	    -gripcount [scale 10 $pct]

	ttk::style configure Heading -padding [scale 3 $pct]

	ttk::style configure TLabelframe \
	    -labelmargins [list 0 0 0 [scale 4 $pct]]
    }
}

#------------------------------------------------------------------------------
# scaleutil::scaleStyles_classic
#
# Scales a few styles for the "classic" theme.
#------------------------------------------------------------------------------
proc scaleutil::scaleStyles_classic pct {
    ttk::style theme settings classic {
	set scrlbarWidth [scale 15 $pct]
	ttk::style configure TScrollbar \
	    -arrowsize $scrlbarWidth -width $scrlbarWidth

	ttk::style configure TScale -sliderlength [scale 30 $pct] \
	    -sliderthickness [scale 15 $pct]

	ttk::style configure TProgressbar -barsize [scale 30 $pct] \
	    -thickness [scale 15 $pct]

	ttk::style configure TCombobox -arrowsize [scale 15 $pct]
	ttk::style configure TSpinbox -arrowsize [scale 10 $pct]

	ttk::style configure TButton -padding {3m 1m}
	ttk::style configure Toolbutton -padding [scale 2 $pct]

	ttk::style configure TMenubutton \
	    -indicatormargin [list [scale 5 $pct] 0] -padding {3m 1m}

	set t [scale 2 $pct]; set r [scale 4 $pct]; set b $t
	set indicatorMargin [list 0 $t $r $b]			;# {0 2 4 2}
	foreach style {TCheckbutton TRadiobutton} {
	    ttk::style configure $style -indicatordiameter [scale 12 $pct] \
		-indicatormargin $indicatorMargin
	}

	ttk::style configure TNotebook.Tab -padding {3m 1m}

	ttk::style configure Sash \
	    -sashthickness [scale 6 $pct] -sashpad [scale 2 $pct] \
	    -handlesize [scale 8 $pct] -handlepad [scale 8 $pct]
    }
}

#------------------------------------------------------------------------------
# scaleutil::scaleStyles_default
#
# Scales a few styles for the "default" theme.
#------------------------------------------------------------------------------
proc scaleutil::scaleStyles_default pct {
    ttk::style theme settings default {
	set scrlbarWidth [scale 12 $pct]
	ttk::style configure TScrollbar \
	    -arrowsize $scrlbarWidth -width $scrlbarWidth

	ttk::style configure TScale -sliderlength [scale 30 $pct] \
	    -sliderthickness [scale 15 $pct]

	ttk::style configure TProgressbar -barsize [scale 30 $pct] \
	    -thickness [scale 15 $pct]

	ttk::style configure TCombobox -arrowsize [scale 12 $pct]
	ttk::style configure TSpinbox -arrowsize [scale 10 $pct]

	ttk::style configure TButton -padding [scale 3 $pct]
	ttk::style configure Toolbutton -padding [scale 2 $pct]

	ttk::style configure TMenubutton \
	    -indicatormargin [list [scale 5 $pct] 0] \
	    -padding [list [scale 10 $pct] [scale 3 $pct]]

	set t [scale 2 $pct]; set r [scale 4 $pct]; set b $t
	set indicatorMargin [list 0 $t $r $b]			;# {0 2 4 2}
	foreach style {TCheckbutton TRadiobutton} {
	    ttk::style configure $style -indicatordiameter [scale 10 $pct] \
		-indicatormargin $indicatorMargin -padding [scale 1 $pct]
	}

	ttk::style configure TNotebook.Tab \
	    -padding [list [scale 4 $pct] [scale 2 $pct]]
    }
}

#------------------------------------------------------------------------------
# scaleutil::scaleWinStyles
#
# Scales a few styles for the "vista" and "xpnative" themes.
#------------------------------------------------------------------------------
proc scaleutil::scaleWinStyles {theme pct} {
    ttk::style theme settings $theme {
	ttk::style configure TButton -padding [scale 1 $pct]
	ttk::style configure Toolbutton -padding [scale 4 $pct]

	ttk::style configure TMenubutton \
	    -padding [list [scale 8 $pct] [scale 4 $pct]]

	foreach style {TCheckbutton TRadiobutton} {
	    ttk::style configure $style -padding [scale 2 $pct]
	}

	set m [scale 2 $pct]
	set margins [list $m $m $m 0]
	ttk::style configure TNotebook -tabmargins $margins
	set margins [list $m $m $m $m]
	ttk::style map TNotebook.Tab -expand [list selected $margins]
    }
}

#------------------------------------------------------------------------------
# scaleutil::patchWinTheme
#
# Works around a bug related to the scaling of ttk::checkbutton and
# ttk::radiobutton widgets in the "vista" and "xpnative" themes.
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
	if {$pct > 200} {
	    array set arr {225 13  250 16  300 20  350 20}
	    if {$pct < 225 + 13} {
		set pct 225
	    } elseif {$pct < 250 + 25} {
		set pct 250 
	    } elseif {$pct < 300 + 25} {
		set pct 300 
	    } else {
		set pct 350 
	    }
	}
	set height $arr($pct)
	set pad [scale 2 $pct]
	set width [expr {$height + 2*$pad}]
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
	set padding [list -$pad $pad $pad $pad]
	ttk::style configure TCheckbutton -padding $padding
	ttk::style configure TRadiobutton -padding $padding
    }
}
