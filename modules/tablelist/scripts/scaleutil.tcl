#==============================================================================
# Contains scaling-related utility procedures.
#
# Structure of the module:
#   - Namespace initialization
#   - Public utility procedures
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
    variable version	1.0
    variable library
    if {$::tcl_version >= 8.4} {
	set library	[file dirname [file normalize [info script]]]
    } else {
	set library	[file dirname [info script]] ;# no "file normalize" yet
    }

    #
    # Public procedures:
    #
    namespace export	scalingPercentage \
    			scaleBWidgetSpinBox scaleBWidgetComboBox \
			scaleIncrDateentry scaleIncrTimeentry \
			scaleIncrCombobox scaleOakleyComboboxArrow
}

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
	option add *Scrollbar.width $scrlbarWidth widgetDefault
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

#------------------------------------------------------------------------------
# scaleutil::scaleBWidgetSpinBox
#
# Scales a BWidget SpinBox widget of the given path name.
#------------------------------------------------------------------------------
proc scaleutil::scaleBWidgetSpinBox {w pct} {
    #
    # Scale the width of the two arrows, which is set to 11
    #
    set arrWidth [expr {11 * $pct / 100}]
    $w.arrup configure -width $arrWidth
    $w.arrdn configure -width $arrWidth
}

#------------------------------------------------------------------------------
# scaleutil::scaleBWidgetComboBox
#
# Scales a BWidget ComboBox widget of the given path name.
#------------------------------------------------------------------------------
proc scaleutil::scaleBWidgetComboBox {w pct} {
    #
    # Scale the width of the arrow, which is set to 11 or 15
    #
    variable onX11
    set defaultWidth [expr {$onX11 ? 11 : 15}]
    set width [expr {$defaultWidth * $pct / 100}]
    $w.a configure -width $width

    #
    # Scale the width of the two scrollbars, which is set to 11 or 15
    #
    ComboBox::_create_popup $w
    if {![Widget::theme]} {
	bind $w.shell <Map> [format {
	    if {[string compare [winfo class %%W] "Toplevel"] == 0} {
		%%W.sw.vscroll configure -width %d
		%%W.sw.hscroll configure -width %d
	    }
	} $width $width]
    }
}

#------------------------------------------------------------------------------
# scaleutil::scaleIncrDateentry
#
# Scales an [incr Widgets] dateentry of the given path name.
#------------------------------------------------------------------------------
proc scaleutil::scaleIncrDateentry {w pct} {
    #
    # Scale the values of a few options
    #
    set btnFg [$w cget -buttonforeground]
    $w configure -icon [calendarImg $pct] \
	-backwardimage [backwardImg $pct $btnFg] \
	-forwardimage  [forwardImg  $pct $btnFg] \
	-titlefont {Helvetica 11 bold} -dayfont {Helvetica 9} \
	-datefont {Helvetica 9} -currentdatefont {Helvetica 9 bold} \
	-selectthickness 2p
    set default [lindex [$w configure -height] 3]
    $w configure -height [expr {$default * $pct / 100}]
    set default [lindex [$w configure -width] 3]
    $w configure -width [expr {$default * $pct / 100}]
}

#------------------------------------------------------------------------------
# scaleutil::scaleIncrTimeentry
#
# Scales an [incr Widgets] timeentry of the given path name.
#------------------------------------------------------------------------------
proc scaleutil::scaleIncrTimeentry {w pct} {
    #
    # Scale the values of a few options
    #
    $w configure -icon [watchImg $pct]
    set default [lindex [$w configure -watchheight] 3]
    $w configure -watchheight [expr {$default * $pct / 100}]
    set default [lindex [$w configure -watchwidth] 3]
    $w configure -watchwidth [expr {$default * $pct / 100}]
}

#------------------------------------------------------------------------------
# scaleutil::scaleIncrCombobox
#
# Scales an [incr Widgets] combobox of the given path name.
#------------------------------------------------------------------------------
proc scaleutil::scaleIncrCombobox {w pct} {
    #
    # Scale the two arrows, as well as the value of the -listheight
    # option and that of the -sbwidth option of the list component
    #
    scaleIncrComboboxArrows $pct
    set default [lindex [$w configure -listheight] 3]
    $w configure -listheight [expr {$default * $pct / 100}]
    set listComp [$w component list]
    set default [lindex [$listComp configure -sbwidth] 3]
    $listComp configure -sbwidth [expr {$default * $pct / 100}]
}

#------------------------------------------------------------------------------
# scaleutil::scaleOakleyComboboxArrow
#
# Scales the default arrow of the Oakley combobox widget.
#------------------------------------------------------------------------------
proc scaleutil::scaleOakleyComboboxArrow pct {
    switch $pct {
	100 {
	    set data "
#define down_width 9
#define down_height 5
static unsigned char down_bits[] = {
   0xff, 0x01, 0xfe, 0x00, 0x7c, 0x00, 0x38, 0x00, 0x10, 0x00};
"
	}
	125 {
	    set data "
#define down_width 11
#define down_height 6
static unsigned char down_bits[] = {
   0xff, 0x07, 0xfe, 0x03, 0xfc, 0x01, 0xf8, 0x00, 0x70, 0x00, 0x20, 0x00};
"
	}
	150 {
	    set data "
#define down_width 13
#define down_height 7
static unsigned char down_bits[] = {
   0xff, 0x1f, 0xfe, 0x0f, 0xfc, 0x07, 0xf8, 0x03, 0xf0, 0x01, 0xe0, 0x00,
   0x40, 0x00};
"
	}
	175 {
	    set data "
#define down_width 15
#define down_height 8
static unsigned char down_bits[] = {
   0xff, 0x7f, 0xfe, 0x3f, 0xfc, 0x1f, 0xf8, 0x0f, 0xf0, 0x07, 0xe0, 0x03,
   0xc0, 0x01, 0x80, 0x00};
"
	}
	200 {
	    set data "
#define down_width 17
#define down_height 9
static unsigned char down_bits[] = {
   0xff, 0xff, 0x01, 0xfe, 0xff, 0x00, 0xfc, 0x7f, 0x00, 0xf8, 0x3f, 0x00,
   0xf0, 0x1f, 0x00, 0xe0, 0x0f, 0x00, 0xc0, 0x07, 0x00, 0x80, 0x03, 0x00,
   0x00, 0x01, 0x00};
"
	}
    }

    ::combobox::bimage configure -data $data
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
    if {$size < 0} { set size 9 }	;# -12 -> 9, for backward compatibility
    foreach font {TkDefaultFont TkTextFont TkHeadingFont
		  TkIconFont TkMenuFont} {
	font configure $font -size [expr {$factor * $size}]
    }

    set idx [string first "F(ttsize)" $str]
    scan [string range $str $idx end] "%*s %d" size
    if {$size < 0} { set size 8 }	;# -10 -> 8, for backward compatibility
    foreach font {TkTooltipFont TkSmallCaptionFont} {
	font configure $font -size [expr {$factor * $size}]
    }

    set idx [string first "F(capsize)" $str]
    scan [string range $str $idx end] "%*s %d" size
    if {$size < 0} { set size 11 }	;# -14 -> 11, for backward compatibility
    font configure TkCaptionFont -size [expr {$factor * $size}]

    set idx [string first "F(fixedsize)" $str]
    scan [string range $str $idx end] "%*s %d" size
    if {$size < 0} { set size 9 }	;# -12 -> 9, for backward compatibility
    font configure TkFixedFont -size [expr {$factor * $size}]
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

#------------------------------------------------------------------------------
# scaleutil::calendarImg
#------------------------------------------------------------------------------
proc scaleutil::calendarImg pct {
    variable calendarImg
    if {![info exists calendarImg]} {
	set calendarImg [image create photo scaleutil_calendarImg]

	switch $pct {
	    100 {
		set data "
R0lGODlhFAAUAKUqAPVLPvVMP+1QRPFSRutVSvZVSfZWSvVaT/VdUeR1bdp4cfhyaOt3bvN3bvKG
f+GTjdGYlNOloeeinLa2tsPDw9fBv8bGxszMzM3Nzc/Pz9HR0dPT09XV1dfX19jY2NnZ2dvb29zc
3N3d3d/f3+Xe3eDg4OHh4eLi4uPj4+Tk5P//////////////////////////////////////////
/////////////////////////////////////////////yH5BAEKAD8ALAAAAAAUABQAAAa0wJ9w
SCwaj8giomBYGArQKNNZOAwBgIbKge1itVzAFSB4ELzd8lksRLvdQ4h8Tq/LhykQhcLJ7E17Fx57
Hil4HRMTGRaJJYkUG4kbhkIpiIqME44TkJKUPykoJSUnJqMpKSQpJ6Mnn5aJi40MARKRE5OHsZkl
AwAJt7mVIRYWHRrFJhEKFR/FH68jGRkgHdMnGRgcItMir5eymo/B37uN455Dph0dIyHsKOwgJewl
KEn4+fpBADs=
"
	    }
	    125 {
		set data "
R0lGODlhGQAZAKU5ANJANdtDN/JKPfRLP/VLPvVMP/FTR9tfVutcUexdUvFgVfZgVfdrYfdrYvds
YfdvZfdwZfBzael4b9iYk8Kwr7a2tri4uOerp7m5uby8vMO7ur+/v8PDw8bGxtjCwcfHx+jAvcrK
ys3Nzc/Pz9DQ0NHR0dLS0tPT09TU1PDOy/HOzNjY2NnZ2dvb29zc3OTb2t7e3uDg4OHh4eLi4uPj
4+Tk5Prt7fru7f3v7v///////////////////////////yH5BAEKAD8ALAAAAAAZABkAAAb+wJ9w
SCwaj8ikcrlsOJ7QqDTKIBYIhMcCy+1iFw9sgYiF5HBXL7eAy4UJZELillJ7VTYENi4ABOxdAQAC
e0MHh4iJiotEJiQWkCUfkBsmG5AfJZAWJCZENTEVojMlohw1HKIlM6IVMTWfoaOlFaepFautr58z
Ir40Lb4oNSi+LTS+IjOwQzXOz9DR0rEY1TQn1R01IAoRLzTVGLvNshWkpjUSWBesouNCoK3ntTUT
AwYe7a7M8MAtLaD+wajBgoIGGTX+HeP3owaNFRBBQXRRwwXEVxBX0GAYbxa6W7nccSw3z5Yqfe8a
xsjAkgYKlh9qfGCJggbLDClDjNjJs6cJz54hmAgdKjQIADs=
"
	    }
	    150 {
		set data "
R0lGODlhHgAeAKU9AOhHO+lHO+pIO/VLPvVMP/ROQfVOQfRYTOxcUfZjWNRwadRxafVpXtV1btZ2
b+5yae5zavdxZ/dyaNl7dPd2bMiIhO5+dfh8cu5/ddGHgvh9dOuBedyNh+2YkcWvrba2tre3t8HB
wcXFxcfHx8nJyc3NzefGw87OztHOztDQ0NPT09TU1NXV1dbW1tfX19jY2Nra2tvb29zc3N3d3eXb
29/f3+Dg4OHh4eXh4eLi4uPj4+Tk5P/+/v///////////yH5BAEKAD8ALAAAAAAeAB4AAAb+wJ9w
SCwaj8ikcslsOp9CRmJKrVqvVAbRMOhKKN2weEyJhA3EsITXu4zfA02PZ+6mu5BezwIfY/QPYXcD
AgsNAH1iAA4KAoJDYgIBiWMBjo9CFZqbnJ2enUQuLiUgpSQuIaUgLCyqIS4kqiWiRDs7LR+5KTsi
uR83N74iOym+Lba1t767vbnAwsTGyEO2uLq8vs+5w8W5xzvJtuLj5OXjyTk16jc7Nuo14jQ4tjfv
OdNC1cvYzjsdBAdMRPOG74e+a81+4SjQZcPAD9+SWfvALJsOBF04PIxIbUeMESBdEAM54p6HCRlQ
7HBBMkZBc+ZsnFABE1zHGSVywtixImdDiRw5fK7YAcPnjJfKEGYLtm0j0okVnTH9wE2azXxJKfL7
NbUqwas/ZLR7QRaeDLIvdOhAK7YGWhs7ZkCZS7euXSFBAAA7
"
	    }
	    175 {
		set data "
R0lGODlhIwAjAKU8AONIQe1JOuBOQvVIPvJORPVQQOFXS/BURPNXTe9bTfVaT/dbUNlmXtZqX/Bs
X+VwaPltY+55cOx+d+GIftyMhcmXl/uMhOecktKmpLW3tMiyr7i6t++sq+quq7q8uby+u/itqMi8
vL/CvtS+u8XHxMfJxsrMycvOys3QzNHT0NPV0tTW09XX1OnT0NbZ1dfa1tjb19vd2tze293f3OTe
3d7g3eDj3+Hk4OLl4f749//5+P3//P///////////////yH5BAEKAD8ALAAAAAAjACMAAAb+wJ9w
SCwaj8ikcslsOp9QJGRKrVqv16OiwO16v2DwwjgoDwoWiHnNNkMshTXZDNrlFu38QrcDyYtrHTs6
CHltCXwcf0RrAhQMhnkNFACLQ2wBkYaZlkIGn6ChoqOkBkYpqKmqq6ytKUY4sSketB84JrQeJDgk
uSY4H7kpsTiwsSgZyRs4JckZIjgiziU4G84oxMY4yMrMztDSydTWydix2twZy83J4NPV19lFxDAn
9tgs9ifDKfos2/pgyCNC7IaNgzZwGERYkBhCGzcGDiGWbt03HC0cDIhAA145iUIoOrPYDocEMxc8
ZjBXbN6xkd5KPjAzQSVLdDDZPcOBgcB/gAMjbIL8QWyGiqMrcMA4qsIFjhoaKoRIuILpjKHEasDY
KlDrVhk4ZMB4AaOGUq5mz7nclvNiuAzj4qkl+LKbTnfihM6dWFddzJ1v437cG7IvScDvyK0cmvBp
jMdgazyOcXXGZLMyLseycYREic+gQ4seHZpElNOoU6tezZpIEAA7
"
	    }
	    200 {
		set data "
R0lGODlhKAAoAKU4ANtDN+ZGOuZIO/JKPfVLPvVMP/VMQPVNQPROQfVOQd5YTt9YTfNXS+9aT/Bc
UORoX+hoXvdoXfdrYN11bet2bseFgNODfceMiMuWkdaVkPmOhuufmfifmPigmba2tr6+vvCxrPCy
rem6tsvEw8bGxsvLy+3Ewc3Nze3FwufIxc/Pz+fOzOLR0NXV1dfX19vb29zc3OXa2d3d3d7e3uXd
3N/f3+Hh4eTk5P///////////////////////////////yH5BAEKAD8ALAAAAAAoACgAAAb+wJ9w
SCwaj8ikcslsOp/QqHTqlESu2Kx2y71Kjo0CYUwum8/occFhFJQTGs0hnYbLywJjoNzB4Th0aH1/
ZQF6ZSF+IIFniTiLZIZFe2QKKCYLjGaWmIWHZAMAAAOaZaGjnpOlq2aSRBcVsbKztLW2sxdGL7u8
vb6/wL9GN8Q3Jx7IHic3H8keMDDOH8bOy8XDxcfJy83J0NLU28U32MTayNzO38nT58rj5eHozOrR
7PLv10Xj7une9sjaVYO3b5zBgwgT6iMyTkaLhy1k3HABsYUNYitExCDmEKLEhUP4DeyGDMaNDQYI
MEiBzxqxeP3oeaOBgAyFlgQZZhupjkWFGQg4QQoRKY7kMxsPyGQI+rIgsRYkopJocaOEVBI1boyw
MAGDixtQpVIV+kOhWRcqTJol5xTsVapWpdaocbWEW7E5Q+4sWg9cTLJE5xldF5ApW53meP7zOxDw
XsF97/1tSuQix4oSKUK0YaPi144PP96wcUT02tPjZlBZzbq169ewY0MJAgA7
"
	    }
	}
	scaleutil_calendarImg put $data
    }

    return $calendarImg
}

#------------------------------------------------------------------------------
# scaleutil::backwardImg
#------------------------------------------------------------------------------
proc scaleutil::backwardImg {pct fg} {
    variable backwardImg
    if {![info exists backwardImg]} {
	set backwardImg [image create bitmap scaleutil_backwardImg]

	switch $pct {
	    100 {
		set data " 
#define backward_width 16
#define backward_height 16
static unsigned char backward_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc0, 0x30, 0xe0, 0x38, 0xf0, 0x3c,
   0xf8, 0x3e, 0xfc, 0x3f, 0xfc, 0x3f, 0xf8, 0x3e, 0xf0, 0x3c, 0xe0, 0x38,
   0xc0, 0x30, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
"
	    }
	    125 {
		set data "
#define backward_width 20
#define backward_height 20
static unsigned char backward_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x03,
   0x80, 0x83, 0x03, 0xc0, 0xc3, 0x03, 0xe0, 0xe3, 0x03, 0xf0, 0xf3, 0x03,
   0xf8, 0xfb, 0x03, 0xfc, 0xff, 0x03, 0xfc, 0xff, 0x03, 0xf8, 0xfb, 0x03,
   0xf0, 0xf3, 0x03, 0xe0, 0xe3, 0x03, 0xc0, 0xc3, 0x03, 0x80, 0x83, 0x03,
   0x00, 0x03, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
"
	    }
	    150 {
		set data "
#define backward_width 24
#define backward_height 24
static unsigned char backward_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x0c, 0x18, 0x00, 0x0e, 0x1c, 0x00, 0x0f, 0x1e, 0x80, 0x0f, 0x1f,
   0xc0, 0x8f, 0x1f, 0xe0, 0xcf, 0x1f, 0xf0, 0xef, 0x1f, 0xf8, 0xff, 0x1f,
   0xf8, 0xff, 0x1f, 0xf0, 0xef, 0x1f, 0xe0, 0xcf, 0x1f, 0xc0, 0x8f, 0x1f,
   0x80, 0x0f, 0x1f, 0x00, 0x0f, 0x1e, 0x00, 0x0e, 0x1c, 0x00, 0x0c, 0x18,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
"
	    }
	    175 {
		set data "
#define backward_width 28
#define backward_height 28
static unsigned char backward_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x30, 0x80, 0x01, 0x00, 0x38, 0xc0, 0x01,
   0x00, 0x3c, 0xe0, 0x01, 0x00, 0x3e, 0xf0, 0x01, 0x00, 0x3f, 0xf8, 0x01,
   0x80, 0x3f, 0xfc, 0x01, 0xc0, 0x3f, 0xfe, 0x01, 0xe0, 0x3f, 0xff, 0x01,
   0xf0, 0xbf, 0xff, 0x01, 0xf8, 0xff, 0xff, 0x01, 0xf8, 0xff, 0xff, 0x01,
   0xf0, 0xbf, 0xff, 0x01, 0xe0, 0x3f, 0xff, 0x01, 0xc0, 0x3f, 0xfe, 0x01,
   0x80, 0x3f, 0xfc, 0x01, 0x00, 0x3f, 0xf8, 0x01, 0x00, 0x3e, 0xf0, 0x01,
   0x00, 0x3c, 0xe0, 0x01, 0x00, 0x38, 0xc0, 0x01, 0x00, 0x30, 0x80, 0x01,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00};
"
	    }
	    200 {
		set data " 
#define backward_width 32
#define backward_height 32
static unsigned char backward_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xe0, 0x00, 0x0e,
   0x00, 0xf0, 0x00, 0x0f, 0x00, 0xf8, 0x80, 0x0f, 0x00, 0xfc, 0xc0, 0x0f,
   0x00, 0xfe, 0xe0, 0x0f, 0x00, 0xff, 0xf0, 0x0f, 0x80, 0xff, 0xf8, 0x0f,
   0xc0, 0xff, 0xfc, 0x0f, 0xe0, 0xff, 0xfe, 0x0f, 0xf0, 0xff, 0xff, 0x0f,
   0xf0, 0xff, 0xff, 0x0f, 0xf0, 0xff, 0xff, 0x0f, 0xf0, 0xff, 0xff, 0x0f,
   0xe0, 0xff, 0xfe, 0x0f, 0xc0, 0xff, 0xfc, 0x0f, 0x80, 0xff, 0xf8, 0x0f,
   0x00, 0xff, 0xf0, 0x0f, 0x00, 0xfe, 0xe0, 0x0f, 0x00, 0xfc, 0xc0, 0x0f,
   0x00, 0xf8, 0x80, 0x0f, 0x00, 0xf0, 0x00, 0x0f, 0x00, 0xe0, 0x00, 0x0e,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
"
	    }
	}
	scaleutil_backwardImg configure -data $data -foreground $fg
    }

    return $backwardImg
}

#------------------------------------------------------------------------------
# scaleutil::forwardImg
#------------------------------------------------------------------------------
proc scaleutil::forwardImg {pct fg} {
    variable forwardImg
    if {![info exists forwardImg]} {
	set forwardImg [image create bitmap scaleutil_forwardImg]

	switch $pct {
	    100 {
		set data " 
#define forward_width 16
#define forward_height 16
static unsigned char forward_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0c, 0x03, 0x1c, 0x07, 0x3c, 0x0f,
   0x7c, 0x1f, 0xfc, 0x3f, 0xfc, 0x3f, 0x7c, 0x1f, 0x3c, 0x0f, 0x1c, 0x07,
   0x0c, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
"
	    }
	    125 {
		set data "
#define forward_width 20
#define forward_height 20
static unsigned char forward_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0c, 0x0c, 0x00,
   0x1c, 0x1c, 0x00, 0x3c, 0x3c, 0x00, 0x7c, 0x7c, 0x00, 0xfc, 0xfc, 0x00,
   0xfc, 0xfd, 0x01, 0xfc, 0xff, 0x03, 0xfc, 0xff, 0x03, 0xfc, 0xfd, 0x01,
   0xfc, 0xfc, 0x00, 0x7c, 0x7c, 0x00, 0x3c, 0x3c, 0x00, 0x1c, 0x1c, 0x00,
   0x0c, 0x0c, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
"
	    }
	    150 {
		set data "
#define forward_width 24
#define forward_height 24
static unsigned char forward_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x18, 0x30, 0x00, 0x38, 0x70, 0x00, 0x78, 0xf0, 0x00, 0xf8, 0xf0, 0x01,
   0xf8, 0xf1, 0x03, 0xf8, 0xf3, 0x07, 0xf8, 0xf7, 0x0f, 0xf8, 0xff, 0x1f,
   0xf8, 0xff, 0x1f, 0xf8, 0xf7, 0x0f, 0xf8, 0xf3, 0x07, 0xf8, 0xf1, 0x03,
   0xf8, 0xf0, 0x01, 0x78, 0xf0, 0x00, 0x38, 0x70, 0x00, 0x18, 0x30, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
"
	    }
	    175 {
		set data "
#define forward_width 28
#define forward_height 28
static unsigned char forward_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x18, 0xc0, 0x00, 0x00, 0x38, 0xc0, 0x01, 0x00,
   0x78, 0xc0, 0x03, 0x00, 0xf8, 0xc0, 0x07, 0x00, 0xf8, 0xc1, 0x0f, 0x00,
   0xf8, 0xc3, 0x1f, 0x00, 0xf8, 0xc7, 0x3f, 0x00, 0xf8, 0xcf, 0x7f, 0x00,
   0xf8, 0xdf, 0xff, 0x00, 0xf8, 0xff, 0xff, 0x01, 0xf8, 0xff, 0xff, 0x01,
   0xf8, 0xdf, 0xff, 0x00, 0xf8, 0xcf, 0x7f, 0x00, 0xf8, 0xc7, 0x3f, 0x00,
   0xf8, 0xc3, 0x1f, 0x00, 0xf8, 0xc1, 0x0f, 0x00, 0xf8, 0xc0, 0x07, 0x00,
   0x78, 0xc0, 0x03, 0x00, 0x38, 0xc0, 0x01, 0x00, 0x18, 0xc0, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00};
"
	    }
	    200 {
		set data " 
#define forward_width 32
#define forward_height 32
static unsigned char forward_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x70, 0x00, 0x07, 0x00,
   0xf0, 0x00, 0x0f, 0x00, 0xf0, 0x01, 0x1f, 0x00, 0xf0, 0x03, 0x3f, 0x00,
   0xf0, 0x07, 0x7f, 0x00, 0xf0, 0x0f, 0xff, 0x00, 0xf0, 0x1f, 0xff, 0x01,
   0xf0, 0x3f, 0xff, 0x03, 0xf0, 0x7f, 0xff, 0x07, 0xf0, 0xff, 0xff, 0x0f,
   0xf0, 0xff, 0xff, 0x0f, 0xf0, 0xff, 0xff, 0x0f, 0xf0, 0xff, 0xff, 0x0f,
   0xf0, 0x7f, 0xff, 0x07, 0xf0, 0x3f, 0xff, 0x03, 0xf0, 0x1f, 0xff, 0x01,
   0xf0, 0x0f, 0xff, 0x00, 0xf0, 0x07, 0x7f, 0x00, 0xf0, 0x03, 0x3f, 0x00,
   0xf0, 0x01, 0x1f, 0x00, 0xf0, 0x00, 0x0f, 0x00, 0x70, 0x00, 0x07, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
"
	    }
	}
	scaleutil_forwardImg configure -data $data -foreground $fg
    }

    return $forwardImg
}

#------------------------------------------------------------------------------
# scaleutil::watchImg
#------------------------------------------------------------------------------
proc scaleutil::watchImg pct {
    variable watchImg
    if {![info exists watchImg]} {
	set watchImg [image create photo scaleutil_watchImg]

	switch $pct {
	    100 {
		set data "
R0lGODlhFAAUAMZAADU2NDc7PTs9OkA9QTs/QT9BPkBERkVDRkRISkdJRklNT05MUExOS1BOUVBU
VlVZW1lbWFpeYF5hXmBkZmNlYmlmamNoamtpbWhsbmptampucG1xc29xbnN1cnZ6fHh8f4KEgYKG
icR2dYmLiIuPko6QjZSQjpeZlt6cm/yVlrS2s7q8ufmvsL7BvsPFwsfKxsvNys7QzdHT0NPV0trc
2fbZ1+Hj4OTn4+fq5urs6e7w7fHz8PP28vb59fn7+Pv9+v//////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////yH5
BAEKAEAALAAAAAAUABQAAAf+gECCg4SFhocSGRkSh4YOGhsaGBiQGg6NQBIbGCAqLi4qIRgbEYcQ
Gh4uNDYtNjY0Lh4aEIUNFx4xNjc4Mji+Ni8fGAyEEhovuzg5y8sjMy8apYMTIzbKKjrZOiUyOTYj
E4MKFis42S8nOzvcOzU4LRULggoYMObqMCcmKCkpLDoyMigQhKBeixk7ePA4IaJGjx6wAiYQZGBC
ixwJH/rY6OPhDhcUDgx6QOJGxh4+fqjsiKPEA0IJOMTQwUNjyo07ZmxAQGjAAxA0aPaYsbHHDhog
HhQoNEACiBjmVqjjBWICgUMCHnQo4ULGDBclOjwIgAmAgQcWOHCg8MAAAEwLhAIIEEAWrl1DgQAA
Ow==
"
	    }
	    125 {
		set data "
R0lGODlhGQAZAMZAADI0Mjk2OjY4NjU5Ozw+PDxAQkRHSkdJRktITGdDQUlNT0tNS1BOUVBUVlZT
V1xZXVlbWFhdX1xgYl5gXWRhZWFlZ2NmY29tcWtvcW1vbG9zdnp4fHd6d3Z6fIB+gn2AfXyAguFn
aIOFiIaJhY2QjY6SlZOVkvp+faGcm/iKiKeppq2vrLS2s/mko7q8ub/Cv8THw8jKx8zOy9HU0PfJ
x9rd2d/h3uTm4+jq5/bp6ezu6+/y7vL08fb49fn7+Pv++///////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////yH5
BAEKAEAALAAAAAAZABkAAAf+gECCg4SFhoeIiYqDCxAZHR8dGRALi4wVIh4YFRIVGCAiEpWKCxsd
DiIqLqsqIg8bG6OHCB0VHS4xNTW5uy61HbKEBxoVJDA1Nzg3LjjKNTAlngeGEBccMTbNzTPaOCQx
HxoNhQeTLtk4OurrOtc2LhAY04wWI9w6NiY7+/vXOzgzRsgj1IDCChvqdrAgwc/fvhsrKowb1ADC
ixs6+LkgwWNEDBopTrTAESPCREEVY8hYEWMHDx4uEoQQmWMGCxkxJpwEogACjBv7ePTocQPFDh8+
hvbQEQOCAkIGJqwA+nIo0qtIibKQME9QgQj2XFpF+qMs0h01RkQoQIhAxYtxO8b6MJtUBwwIDggU
KjDhgwwccYfOuNpjx4wPE9gWGqBAgom/LnesSPpvhgkJCgYcCsCAwocXM5LJ0HFjxgvEDQQkEhB1
wogVMGLAWDFiggQEmhUBGMAggoUJwC2YHADAkiAAAQgYWE5AQHHj0KNHDwQAOw==
"
	    }
	    150 {
		set data "
R0lGODlhHgAeAMZAADM1MzI2ODY4NTk7OTs8Pz5APT9DRUNFQ0VISklLSElNT05MUE1PTFBST09T
VVRSVrA6PFNXWVVXVFhcX1pcWV5cX15iZGRiZmNlYmhrbmttanF2eHV2c3t5fXd8foGEh/xpaYmN
j4uNipSSlvp2c5GWmJeZlsSSkpqeoZyem/iEhaCin6mrqK6wrfqeoLO1srm7uL2/vPazscTHxMjK
x87QzdPV0tzf2+Dj3/ji4uXo5Onr6O3w7fL18fb49fn8+P//////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////yH5
BAEKAEAALAAAAAAeAB4AAAf+gECCg4SFhoeIiYqLhQyOEREMCgyMiAwYHSMlISElIx4WCZWDCRYh
HRkIDxYWDwoZHx8ToowJG7IWJS8wMTEwLyYXFh8ZtIm2GwomMDQ2NzQ3NzY0MCkOHRvGhgkZHBEs
0Dg6Oi3jOjjPLREdF9qEEhwLLTU35jstO/k7OjcxLQ8eIhxK4A0FDXH6EubTgYEZigkbDhiKkAFD
jHoKeWjksUMDjB04YmDI0KDQgQsVTNTQkS+GiI0bPWrUYSMFK4mDDmRYAOPGjo0mRPQY2kPDC6I8
bsBYkAGnoJMSZuDYODToUKM9crgAIUPHDIpOgRxgRUOHRqI9gnY4oQIECRn3O3rsoIHhggFCYzHQ
qMGChY6hPnwwgOAiR+AeLVjUoFshbIEJEWaYJRrYx7gfmH8cnjthQgFCBSI0gDEVcODMqDX30BGj
QYXPgwgooJDCRtwep1Nn9tHDxgoKCmAPMkABg2TTujPLpTvhbqEBDiakWIn7dI/UPnj4nuBgwKEC
FSS8sF3dRwrUPbS/kDCBAKIBCCZQmDc57eHVNl5QmIDAOyIBC1QQAQoz2CBODfngMM0KEUywgACL
CIBABcUtQ8OF1KSAAQUVIAAhIwIM8AAFFkhQ3IYmckfAh6OEqEoFME7wAAIrjmIIAAIIEECOAgBg
449ABllIIAA7
"
	    }
	    175 {
		set data "
R0lGODlhIwAjAMZAADM1MjM1Nzc7PTk7OD0/Qj9BPlRAPkRGQ0RGSUhMTk5MUExOS09SVFFTUFJW
WFlWWldZVlZaXF9cYFpeYV1fXF5iZGFjYMxERmViZmJmaWlraGlsb3FzdvpOTnV3dHl+gH99gf1e
YIKFh42QjZaZlfp9fZebnqGjoairqc6joK2wrfigoLW3tPimpLy/u8TGw8jKx/bBwc3PzNPV0vLO
z9ja19zf2+Di3+Tn5PXl5ujq5+zu6+/y7vL08fX49Pn8+P//////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////yH5
BAEKAEAALAAAAAAjACMAAAf+gECCg4SFhoeIiYqLjIYLjwyPC42MCxAcICKamiAbEZOUhQsRHyAc
ExASERIQE5gfE6ChCx4fFhGkJCcoJyQfuBmmDaENH54VJy4vMjPNMi8uJ6obHw6NxRkOJC4yNTY2
Mi433zXhJg8ZHwyLCRwZECgw3jc4OjMuOvk3NzUwKBAVOMgydGADBgcoZNi4kS9fDXwNdeAAhwLd
hgOIGHCAYALGwoggI3qwAYNEBA7DCGKokOFFjXoNd8icOdPCCR02XlSogAGjqA0TUMxgqIOmUZkW
SMjEMQPFhA0DBUHAMOGFjXwyR4yQyaMrjx0aSHzdgfNFhGyFDlSY8AHGDaP+HkZ47Rp27g4cMj5Q
kOBTkNoJJmbgmOk1bmG5PHrEKEFDRw0SEyr0BVIAgwQUNYrOTRy3R9wcK0J0KBGjxw4bKCxgKEDo
gIQKLGawYOHCa48ePjwYuNAhRIscPnrAcKGiBosKEhAQKjDhcrkaNxLf9uFDhYEU1LP7sFEDeuoJ
rAcVcDDhRGbbuLP/WL9eu2kbJyg8CC+oAIMJImTo6DpdPfv/1Jk2gwgUMECfIAhIYIFbO0jn338A
8qCDDBRUoFwhBChY3H7pUQchhD7wYIMKFURAgCEDJFCBBgwm9uCHIU6oQQUGHlJABMgItkOHPnz4
Q4wznGCBBAcSkmIFFKiSoKOL27nQ448xGldhAgMkMgADSMb2lnQzqJDdV/awYEEFClSpyAAO7NTR
S0U1NRZOMpywkwMCNCIAlhZooAIMMyzk5wwyqKDBmArUSckACKxigQUinKACCyqcIMKiyCFgZigA
pPgaBRRkYEEGFZZYaAChFAJAAAQo4EAED0TggAIEAABAqYnIeqqttOaq666KBAIAOw==
"
	    }
	    200 {
		set data "
R0lGODlhKAAoAMZAAC4wLTQ2Mzg6ODg7PageGz5APj1AQkVHREVJS0xKTkpOUUxOS09TVlFTUFZU
WFpXW1dZVlZaXFxeXFtfYv4xMWJfY2FjYWFlZ2hman5kZGhsbf1CQG5scG1xdHByb3Z4df5SUHV5
e316fnt/gn1/fICEh4KEgfxhYIqLio+SkPp2c5udmvmVlLG0svijorq9usHEwfe4uMfKx9DTz9ja
197g3fPd2fvd3OPm4ufp5vHs6uvu6u/x7vH08PX39Pn7+P//////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////yH5
BAEKAEAALAAAAAAoACgAAAf+gECCg4SFhoeIiYqLjI2ICwuOkoQLDRYdISIiIR4XDQmTigsYIygj
IhwaGhwhpSMXkaGECRclIhoREQwKvAoMERIaIiawskALrRcPChopLS/QLy0pGgoRF6exkg0kHBEJ
JS0wMjPl5jIwLSUJEB0jDdsiF9fiMzQ0NTUr+TX3M+kVHmggAY+Rgg8YHoR4YS8fDhw5VuTI8RBH
vxkvQkTAEEIbIgSrIixsCHFixJImLWLUuOqAoggdJlhgWAOlSRomc+Ig9+LChA4REh3ocIFBixk1
Te5YyrTpjhwQ9s1oweBCB5eHGGiAUEIGDYhOwzKVgGKHRRklImhgcOjAhaL+NHMwrSGWqQUSTHHQ
eMGgQgWshA5gkNDBK46mElIs5cGY8Y67jp/WkNEhGOBBCuatQCq3KYQUPUKLviu6Bw+zM1ZIKFao
L4QWX5ky7rHjc2kPJErbcKEjx95rbFtXYAAD5+LSPGz38PDBh44YKjZsYKFjx2QIwwsdcDAPRg25
PEqL/vwhg4sTFE7E0OEjtHUZEYYbCEyL+AwUKVLgEO2jfw8ABIDAwg399ZcDfinQAF8FHgmCQAUR
eJdDePwVuIMJJPygoYYFtvdefAgY8qAEsMlVYYEbprihf9a9IMEElwliQAQTbHZYaB36oOKOP3hI
wwoTRDBfIQU8MIEHMtD6hSOKPKrYHg4zeBBkAYYYoECQL+C0ZH9NOmkdDPEpQGWVwKCQ5A49dNjl
ij3kcJ8EQiJSQFURZGmimmvSVsMLNDIw5iEzTqCBhGiqWcOOHk6mgQVxJiJAAhVMYEKSdxaY4YqJ
ymDCBBMgIMAiAvQlwaSxUegDCQW655sMJEgw3KeMDNBXBRrQBNaFTan0ggYTvCpJqJGSNQ5S/ORD
wz8oSGDBBAwMEMqjNE4gwQcrvCDDtTK8sMIHygaZAKyhBCArjRaUK8G5yi4LYbMBGDOIuAg8EF+k
vQb5AAIDtOtuIQEEIIABCCSQAAIF5KvvvooAAADCDDfscCGBAAA7
"
	    }
	}
	scaleutil_watchImg put $data
    }

    return $watchImg
}

#------------------------------------------------------------------------------
# scaleutil::scaleIncrComboboxArrows
#------------------------------------------------------------------------------
proc scaleutil::scaleIncrComboboxArrows pct {
    switch $pct {
	100 {
	    downarrow configure -data "
#define down_width 16
#define down_height 16
static unsigned char down_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0xfc, 0x7f, 0xf8, 0x3f, 0xf0, 0x1f, 0xe0, 0x0f, 0xc0, 0x07, 0x80, 0x03,
   0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
"
	    uparrow configure -data "
#define up_width 16
#define up_height 16
static unsigned char up_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0xc0, 0x01, 0xe0, 0x03,
   0xf0, 0x07, 0xf8, 0x0f, 0xfc, 0x1f, 0xfe, 0x3f, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
"
	}

	125 {
	    downarrow configure -data "
#define down_width 20
#define down_height 20
static unsigned char down_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0xff, 0x07,
   0xf8, 0xff, 0x03, 0xf0, 0xff, 0x01, 0xe0, 0xff, 0x00, 0xc0, 0x7f, 0x00,
   0x80, 0x3f, 0x00, 0x00, 0x1f, 0x00, 0x00, 0x0e, 0x00, 0x00, 0x04, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
"
	    uparrow configure -data "
#define up_width 20
#define up_height 20
static unsigned char up_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x02, 0x00, 0x00, 0x07, 0x00, 0x80, 0x0f, 0x00, 0xc0, 0x1f, 0x00,
   0xe0, 0x3f, 0x00, 0xf0, 0x7f, 0x00, 0xf8, 0xff, 0x00, 0xfc, 0xff, 0x01,
   0xfe, 0xff, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
"
	}

	150 {
	    downarrow configure -data "
#define down_width 24
#define down_height 24
static unsigned char down_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0xf8, 0xff, 0x3f, 0xf0, 0xff, 0x1f, 0xe0, 0xff, 0x0f,
   0xc0, 0xff, 0x07, 0x80, 0xff, 0x03, 0x00, 0xff, 0x01, 0x00, 0xfe, 0x00,
   0x00, 0x7c, 0x00, 0x00, 0x38, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
"
	    uparrow configure -data "
#define up_width 24
#define up_height 24
static unsigned char up_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x1c, 0x00, 0x00, 0x3e, 0x00,
   0x00, 0x7f, 0x00, 0x80, 0xff, 0x00, 0xc0, 0xff, 0x01, 0xe0, 0xff, 0x03,
   0xf0, 0xff, 0x07, 0xf8, 0xff, 0x0f, 0xfc, 0xff, 0x1f, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
"
	}

	175 {
	    downarrow configure -data "
#define down_width 28
#define down_height 28
static unsigned char down_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xf8, 0xff, 0xff, 0x03,
   0xf0, 0xff, 0xff, 0x01, 0xe0, 0xff, 0xff, 0x00, 0xc0, 0xff, 0x7f, 0x00,
   0x80, 0xff, 0x3f, 0x00, 0x00, 0xff, 0x1f, 0x00, 0x00, 0xfe, 0x0f, 0x00,
   0x00, 0xfc, 0x07, 0x00, 0x00, 0xf8, 0x03, 0x00, 0x00, 0xf0, 0x01, 0x00,
   0x00, 0xe0, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00};
"
	    uparrow configure -data "
#define up_width 28
#define up_height 28
static unsigned char up_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00,
   0x00, 0x70, 0x00, 0x00, 0x00, 0xf8, 0x00, 0x00, 0x00, 0xfc, 0x01, 0x00,
   0x00, 0xfe, 0x03, 0x00, 0x00, 0xff, 0x07, 0x00, 0x80, 0xff, 0x0f, 0x00,
   0xc0, 0xff, 0x1f, 0x00, 0xe0, 0xff, 0x3f, 0x00, 0xf0, 0xff, 0x7f, 0x00,
   0xf8, 0xff, 0xff, 0x00, 0xfc, 0xff, 0xff, 0x01, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00};
"
	}

	200 {
	    downarrow configure -data "
#define down_width 32
#define down_height 32
static unsigned char down_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0xf8, 0xff, 0xff, 0x3f, 0xf0, 0xff, 0xff, 0x1f, 0xe0, 0xff, 0xff, 0x0f,
   0xc0, 0xff, 0xff, 0x07, 0x80, 0xff, 0xff, 0x03, 0x00, 0xff, 0xff, 0x01,
   0x00, 0xfe, 0xff, 0x00, 0x00, 0xfc, 0x7f, 0x00, 0x00, 0xf8, 0x3f, 0x00,
   0x00, 0xf0, 0x1f, 0x00, 0x00, 0xe0, 0x0f, 0x00, 0x00, 0xc0, 0x07, 0x00,
   0x00, 0x80, 0x03, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
"
	    uparrow configure -data "
#define up_width 32
#define up_height 32
static unsigned char up_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x80, 0x00, 0x00, 0x00, 0xc0, 0x01, 0x00, 0x00, 0xe0, 0x03, 0x00,
   0x00, 0xf0, 0x07, 0x00, 0x00, 0xf8, 0x0f, 0x00, 0x00, 0xfc, 0x1f, 0x00,
   0x00, 0xfe, 0x3f, 0x00, 0x00, 0xff, 0x7f, 0x00, 0x80, 0xff, 0xff, 0x00,
   0xc0, 0xff, 0xff, 0x01, 0xe0, 0xff, 0xff, 0x03, 0xf0, 0xff, 0xff, 0x07,
   0xf8, 0xff, 0xff, 0x0f, 0xfc, 0xff, 0xff, 0x1f, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
"
	}
    }
}
