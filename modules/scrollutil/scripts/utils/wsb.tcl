#==============================================================================
# Contains the implementation of the Wide.TSpinbox layout, and arranges for it
# to be created automatically for the current theme when needed.
#
# Usage:
#   package require wsb
#   ttk::spinbox <pathName> -style Wide.TSpinbox ...
#
# Copyright (c) 2025  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

namespace eval wsb {
    proc - {} { return [expr {$::tcl_version >= 8.5 ? "-" : ""}] }

    package require Tk 8.6[-]

    if {$::tk_version == 8.6} {
        package require tksvg
    }

    #
    # Public variables:
    #
    variable version    1.1
    variable library    [file dirname [file normalize [info script]]]

    proc getScalingPct {} {
	set pct [expr {[tk scaling] * 75}]
	for {set intPct 100} {1} {incr intPct 25} {
	    if {$pct < $intPct + 12.5} {
		return $intPct
	    }
	}
    }

    proc createAliases {} {
	set svgFmt [list svg -scale [expr {[getScalingPct] / 100.0}]]
	interp alias {} ::wsb::createImg  {} image create photo -format $svgFmt

	interp alias {} ::wsb::createElem {} ttk::style element create
    }
    createAliases

    variable uparrowImgData {
<svg width="20" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <circle cx="10" cy="8" r="8" fill="bg"/>
 <path d="m6 10 4-4 4 4" fill="none" stroke-linecap="round" stroke-linejoin="round" }
    variable downarrowImgData {
<svg width="20" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <circle cx="10" cy="8" r="8" fill="bg"/>
 <path d="m6 6 4 4 4-4" fill="none" stroke-linecap="round" stroke-linejoin="round" }
    variable gapImg [createImg -data {
<svg width="4" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg"/>}]

    variable onAndroid [expr {[info exists ::tk::android] && $::tk::android}]
}

package provide wsb $wsb::version

#------------------------------------------------------------------------------
# wsb::createBindings
#
# Creates the default bindings for the binding tag WsbMain.
#------------------------------------------------------------------------------
proc wsb::createBindings {} {
    bindtags . [linsert [bindtags .] 1 WsbMain]
    foreach event {<<ThemeChanged>> <<LightAqua>> <<DarkAqua>>} {
	bind WsbMain $event { after idle wsb::onThemeChanged }
    }
}

#------------------------------------------------------------------------------
# wsb::onThemeChanged
#
# Creates and/or updates the elements WideSpinbox.uparrow and
# WideSpinbox.downarrow of the Wide.TSpinbox layout for the current theme if
# necessary.
#------------------------------------------------------------------------------
proc wsb::onThemeChanged {} {
    variable elemInfoArr
    set theme [ttk::style theme use]

    if {![info exists elemInfoArr($theme)]} {
	createElements $theme
	updateElements $theme
	set elemInfoArr($theme) 1
    } elseif {$theme eq "aqua"} {
	updateElements $theme
    }
}

#------------------------------------------------------------------------------
# wsb::normalizeColor
#
# Returns the representation of a given color in the form "#RRGGBB".
#------------------------------------------------------------------------------
proc wsb::normalizeColor color {
    lassign [winfo rgb . $color] r g b
    return [format "#%02x%02x%02x" \
	    [expr {$r >> 8}] [expr {$g >> 8}] [expr {$b >> 8}]]
}

#------------------------------------------------------------------------------
# wsb::createElements
#
# Creates the elements WideSpinbox.uparrow, WideSpinbox.downarrow, and
# WideSpinbox.gap of the Wide.TSpinbox layout for a given theme.
#------------------------------------------------------------------------------
proc wsb::createElements theme {
    #
    # Create the WideSpinbox.uparrow element
    #
    variable uparrowImgsArr
    set img  [createImg]
    set dImg [createImg]
    set pImg [createImg]
    set aImg [createImg]
    set uparrowImgsArr($theme) [list $img $dImg $pImg $aImg]
    createElem WideSpinbox.uparrow image [list $img \
	disabled $dImg  pressed $pImg  active $aImg]

    #
    # Create the WideSpinbox.downarrow element
    #
    variable downarrowImgsArr
    set img  [createImg]
    set dImg [createImg]
    set pImg [createImg]
    set aImg [createImg]
    set downarrowImgsArr($theme) [list $img $dImg $pImg $aImg]
    createElem WideSpinbox.downarrow image [list $img \
	disabled $dImg  pressed $pImg  active $aImg]

    #
    # Create the WideSpinbox.gap element
    #
    variable gapImg
    createElem WideSpinbox.gap image $gapImg

    #
    # Create the Wide.TSpinbox layout
    #
    if {$theme eq "classic"} {
	ttk::style layout Wide.TSpinbox {
	    Entry.highlight -sticky nswe -children {
		Entry.field -sticky nswe -children {
		    WideSpinbox.uparrow -side right -sticky e
		    WideSpinbox.gap -side right -sticky e
		    WideSpinbox.downarrow -side right -sticky e
		    Entry.padding -sticky nswe -children {
			Entry.textarea -sticky nsew
		    }
		}
	    }
	}
    } else {
	ttk::style layout Wide.TSpinbox {
	    Entry.field -side top -sticky we -children {
		WideSpinbox.uparrow -side right -sticky e
		WideSpinbox.gap -side right -sticky e
		WideSpinbox.downarrow -side right -sticky e
		Entry.padding -sticky nswe -children {
		    Entry.textarea -sticky nsew
		}
	    }
	}
    }

    set padding [ttk::style lookup TEntry -padding]
    ttk::style configure Wide.TSpinbox -padding $padding
}

#------------------------------------------------------------------------------
# wsb::updateElements
#
# Updates the elements WideSpinbox.uparrow and WideSpinbox.downarrow of the
# Wide.TSpinbox layout for a given theme.
#------------------------------------------------------------------------------
proc wsb::updateElements theme {
    set bg  [normalizeColor [ttk::style lookup . -background]]
    variable onAndroid
    set aBg [expr {$onAndroid ? $bg :
		   [normalizeColor [ttk::style lookup . -background active]]}]
    set fg  [normalizeColor [ttk::style lookup . -foreground {} #000000]]
    set dFg [normalizeColor [ttk::style lookup . -foreground disabled #a3a3a3]]

    if {$theme eq "aqua"} {
	set pBg [normalizeColor systemControlAccentColor]
	set pFg #ffffff
    } else {
	set pBg [ttk::style lookup . -selectbackground focus #000000]
	set pBg [normalizeColor $pBg]
	set pFg [ttk::style lookup . -selectforeground focus #ffffff]
	set pFg [normalizeColor $pFg]
    }

    #
    # Update the WideSpinbox.uparrow element
    #

    variable uparrowImgsArr
    lassign $uparrowImgsArr($theme) img dImg pImg aImg
    variable uparrowImgData

    set imgData $uparrowImgData
    set idx [string first "bg" $imgData]
    set imgData [string replace $imgData $idx $idx+1 $bg]
    append imgData "stroke='$fg'/>\n</svg>"
    $img configure -data $imgData

    set imgData $uparrowImgData
    set imgData [string replace $imgData $idx $idx+1 $bg]
    append imgData "stroke='$dFg'/>\n</svg>"
    $dImg configure -data $imgData

    set imgData $uparrowImgData
    set imgData [string replace $imgData $idx $idx+1 $pBg]
    append imgData "stroke='$pFg'/>\n</svg>"
    $pImg configure -data $imgData

    set imgData $uparrowImgData
    set imgData [string replace $imgData $idx $idx+1 $aBg]
    append imgData "stroke='$fg'/>\n</svg>"
    $aImg configure -data $imgData

    #
    # Update the WideSpinbox.downarrow element
    #

    variable downarrowImgsArr
    lassign $downarrowImgsArr($theme) img dImg pImg aImg
    variable downarrowImgData

    set imgData $downarrowImgData
    set idx [string first "bg" $imgData]
    set imgData [string replace $imgData $idx $idx+1 $bg]
    append imgData "stroke='$fg'/>\n</svg>"
    $img configure -data $imgData

    set imgData $downarrowImgData
    set imgData [string replace $imgData $idx $idx+1 $bg]
    append imgData "stroke='$dFg'/>\n</svg>"
    $dImg configure -data $imgData

    set imgData $downarrowImgData
    set imgData [string replace $imgData $idx $idx+1 $pBg]
    append imgData "stroke='$pFg'/>\n</svg>"
    $pImg configure -data $imgData

    set imgData $downarrowImgData
    set imgData [string replace $imgData $idx $idx+1 $aBg]
    append imgData "stroke='$fg'/>\n</svg>"
    $aImg configure -data $imgData
}

wsb::createBindings
wsb::onThemeChanged
