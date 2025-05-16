#==============================================================================
# Contains utility procedures for mega-widgets.
#
# Structure of the module:
#   - Namespace initialization
#   - Public utility procedures
#
# Copyright (c) 2000-2025  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

if {[catch {package require Tk 8.4-}]} {
    package require Tk 8.4
}

#
# Namespace initialization
# ========================
#

namespace eval mwutil {
    #
    # Public variables:
    #
    variable version	2.25
    variable library	[file dirname [file normalize [info script]]]

    #
    # Public procedures:
    #
    namespace export	wrongNumArgs getAncestorByClass convEventFields \
			defineKeyNav processTraversal focusNext focusPrev \
			configureWidget fullConfigOpt fullOpt enumOpts \
			configureSubCmd attribSubCmdEx attribSubCmd \
			hasattribSubCmdEx hasattribSubCmd unsetattribSubCmdEx \
			unsetattribSubCmd getScrollInfo getScrollInfo2 \
			isScrollable scrollByUnits genMouseWheelEvent \
			containsPointer hasFocus windowingSystem currentTheme \
			isColorLight normalizeColor parsePadding

    #
    # Make modified versions of the procedures tk_focusNext and
    # tk_focusPrev, to be invoked in the processTraversal command
    #
    proc makeFocusProcs {} {
	#
	# Enforce the evaluation of the Tk library file "focus.tcl"
	#
	tk_focusNext .

	#
	# Build the procedures focusNext and focusPrev
	#
	foreach dir {Next Prev} {
	    set procBody [info body tk_focus$dir]
	    regsub -all {winfo children} $procBody {getChildren $class} procBody
	    proc focus$dir {w class} $procBody
	}
    }
    makeFocusProcs

    #
    # Invoked in the procedures focusNext and focusPrev defined above:
    #
    proc getChildren {class w} {
	if {[winfo class $w] eq $class} {
	    return {}
	} else {
	    return [winfo children $w]
	}
    }
}

package provide mwutil $mwutil::version

#
# Public utility procedures
# =========================
#

#------------------------------------------------------------------------------
# mwutil::wrongNumArgs
#
# Generates a "wrong # args" error message.
#------------------------------------------------------------------------------
proc mwutil::wrongNumArgs args {
    set optList {}
    foreach arg $args {
	lappend optList \"$arg\"
    }
    return -code error "wrong # args: should be [enumOpts $optList]"
}

#------------------------------------------------------------------------------
# mwutil::getAncestorByClass
#
# Gets the path name of the widget of the specified class from the path name w
# of one of its descendants.  It is assumed that all of the ancestors of w
# exist (but w itself needn't exist).
#------------------------------------------------------------------------------
proc mwutil::getAncestorByClass {w class} {
    if {[regexp {^\.[^.]+$} $w]} {
	return [expr {[winfo class .] eq $class ? "." : ""}]
    } elseif {[regexp {^(\..+)\.[^.]+$} $w dummy win]} {
	while {[winfo exists $win]} {
	    if {[winfo class $win] eq $class} {
		return $win
	    } else {
		set win [winfo parent $win]
	    }
	}

	return ""
    } else {
	return ""
    }
}

#------------------------------------------------------------------------------
# mwutil::convEventFields
#
# Gets the path name of the widget of the specified class and the x and y
# coordinates relative to the latter from the path name w of one of its
# descendants and from the x and y coordinates relative to the latter.
#------------------------------------------------------------------------------
proc mwutil::convEventFields {w x y class} {
    set win [getAncestorByClass $w $class]
    set _x  [expr {$x + [winfo rootx $w] - [winfo rootx $win]}]
    set _y  [expr {$y + [winfo rooty $w] - [winfo rooty $win]}]

    return [list $win $_x $_y]
}

#------------------------------------------------------------------------------
# mwutil::defineKeyNav
#
# For a given mega-widget class, the procedure defines the binding tag
# ${class}KeyNav as a partial replacement for "all", by substituting the
# scripts bound to the events <Tab>, <Shift-Tab>, and <<PrevWindow>> with new
# ones which propagate these events to the mega-widget of the given class
# containing the widget to which the event was reported.  (The event
# <Shift-Tab> was replaced with <<PrevWindow>> in Tk 8.3.0.)  This tag is
# designed to be inserted before "all" in the list of binding tags of a
# descendant of a mega-widget of the specified class.
#------------------------------------------------------------------------------
proc mwutil::defineKeyNav class {
    foreach event {<Tab> <Shift-Tab> <<PrevWindow>>} {
	bind ${class}KeyNav $event \
	     [list mwutil::processTraversal %W $class $event]
    }
}

#------------------------------------------------------------------------------
# mwutil::processTraversal
#
# Processes the given traversal event for the mega-widget of the specified
# class containing the widget w if that mega-widget is not the only widget
# receiving the focus during keyboard traversal within its toplevel widget.
#------------------------------------------------------------------------------
proc mwutil::processTraversal {w class event} {
    set win [getAncestorByClass $w $class]

    if {$event eq "<Tab>"} {
	set target [focusNext $win $class]
    } else {
	set target [focusPrev $win $class]
    }

    if {$target ne $win} {
	set focusWin [focus -displayof $win]
	if {$focusWin ne ""} {
	    event generate $focusWin <<TraverseOut>>
	}

	focus $target
	event generate $target <<TraverseIn>>
    }

    return -code break ""
}

#------------------------------------------------------------------------------
# mwutil::configureWidget
#
# Configures the widget win by processing the command-line arguments specified
# in optValPairs and, if the value of initialize is true, also those database
# options that don't match any command-line arguments.
#------------------------------------------------------------------------------
proc mwutil::configureWidget {win configSpecsName configCmd cgetCmd \
			      optValPairs initialize} {
    upvar $configSpecsName configSpecs

    #
    # Process the command-line arguments
    #
    set cmdLineOpts {}
    set savedOptValPairs {}
    set failed 0
    set count [llength $optValPairs]
    foreach {opt val} $optValPairs {
	if {[catch {fullConfigOpt $opt configSpecs} result] != 0} {
	    set failed 1
	    break
	}
	if {$count == 1} {
	    set result "value for \"$opt\" missing"
	    set failed 1
	    break
	}
	set opt $result
	lappend cmdLineOpts $opt
	lappend savedOptValPairs $opt [eval $cgetCmd [list $win $opt]]
	if {[catch {eval $configCmd [list $win $opt $val]} result] != 0} {
	    set failed 1
	    break
	}
	incr count -2
    }

    if {$failed} {
	#
	# Restore the saved values
	#
	foreach {opt val} $savedOptValPairs {
	    eval $configCmd [list $win $opt $val]
	}

	return -code error $result
    }

    if {$initialize} {
	#
	# Process those configuration options that were not
	# given as command-line arguments; use the corresponding
	# values from the option database if available
	#
	foreach opt [lsort [array names configSpecs]] {
	    if {[llength $configSpecs($opt)] == 1 ||
		[lsearch -exact $cmdLineOpts $opt] >= 0} {
		continue
	    }
	    set dbName [lindex $configSpecs($opt) 0]
	    set dbClass [lindex $configSpecs($opt) 1]
	    set dbValue [option get $win $dbName $dbClass]
	    if {$dbValue eq ""} {
		set default [lindex $configSpecs($opt) 3]
		eval $configCmd [list $win $opt $default]
	    } else {
		if {[catch {
		    eval $configCmd [list $win $opt $dbValue]
		} result] != 0} {
		    return -code error $result
		}
	    }
	}
    }

    return ""
}

#------------------------------------------------------------------------------
# mwutil::fullConfigOpt
#
# Returns the full configuration option corresponding to the possibly
# abbreviated option opt.
#------------------------------------------------------------------------------
proc mwutil::fullConfigOpt {opt configSpecsName} {
    upvar $configSpecsName configSpecs

    if {[info exists configSpecs($opt)]} {
	if {[llength $configSpecs($opt)] == 1} {
	    return $configSpecs($opt)
	} else {
	    return $opt
	}
    }

    set optList [lsort [array names configSpecs]]
    set count 0
    foreach elem $optList {
	if {[string first $opt $elem] == 0} {
	    incr count
	    if {$count == 1} {
		set option $elem
	    } else {
		break
	    }
	}
    }

    if {$count == 1} {
	if {[llength $configSpecs($option)] == 1} {
	    return $configSpecs($option)
	} else {
	    return $option
	}
    } elseif {$count == 0} {
	### return -code error "unknown option \"$opt\""
	return -code error \
	       "bad option \"$opt\": must be [enumOpts $optList]"
    } else {
	### return -code error "unknown option \"$opt\""
	return -code error \
	       "ambiguous option \"$opt\": must be [enumOpts $optList]"
    }
}

#------------------------------------------------------------------------------
# mwutil::fullOpt
#
# Returns the full option corresponding to the possibly abbreviated option opt.
#------------------------------------------------------------------------------
proc mwutil::fullOpt {kind opt optList} {
    if {[lsearch -exact $optList $opt] >= 0} {
	return $opt
    }

    set count 0
    foreach elem $optList {
	if {[string first $opt $elem] == 0} {
	    incr count
	    if {$count == 1} {
		set option $elem
	    } else {
		break
	    }
	}
    }

    if {$count == 1} {
	return $option
    } elseif {$count == 0} {
	return -code error \
	       "bad $kind \"$opt\": must be [enumOpts $optList]"
    } else {
	return -code error \
	       "ambiguous $kind \"$opt\": must be [enumOpts $optList]"
    }
}

#------------------------------------------------------------------------------
# mwutil::enumOpts
#
# Returns a string consisting of the elements of the given list, separated by
# commas and spaces.
#------------------------------------------------------------------------------
proc mwutil::enumOpts optList {
    set optCount [llength $optList]
    set n 1
    foreach opt $optList {
	set opt [list $opt]
	if {$n == 1} {
	    set str $opt
	} elseif {$n < $optCount} {
	    append str ", $opt"
	} else {
	    if {$optCount > 2} {
		append str ","
	    }
	    append str " or $opt"
	}

	incr n
    }

    return $str
}

#------------------------------------------------------------------------------
# mwutil::configureSubCmd
#
# This procedure is invoked to process configuration subcommands.
#------------------------------------------------------------------------------
proc mwutil::configureSubCmd {win configSpecsName configCmd cgetCmd argList} {
    upvar $configSpecsName configSpecs

    set argCount [llength $argList]
    if {$argCount > 1} {
	#
	# Set the specified configuration options to the given values
	#
	return [configureWidget $win configSpecs $configCmd $cgetCmd $argList 0]
    } elseif {$argCount == 1} {
	#
	# Return the description of the specified configuration option
	#
	set opt [fullConfigOpt [lindex $argList 0] configSpecs]
	set dbName [lindex $configSpecs($opt) 0]
	set dbClass [lindex $configSpecs($opt) 1]
	set default [lindex $configSpecs($opt) 3]
	return [list $opt $dbName $dbClass $default \
		[eval $cgetCmd [list $win $opt]]]
    } else {
	#
	# Return a list describing all available configuration options
	#
	foreach opt [lsort [array names configSpecs]] {
	    if {[llength $configSpecs($opt)] == 1} {
		set alias $configSpecs($opt)
		lappend result [list $opt $alias]
	    } else {
		set dbName [lindex $configSpecs($opt) 0]
		set dbClass [lindex $configSpecs($opt) 1]
		set default [lindex $configSpecs($opt) 3]
		lappend result [list $opt $dbName $dbClass $default \
				[eval $cgetCmd [list $win $opt]]]
	    }
	}
	return $result
    }
}

#------------------------------------------------------------------------------
# mwutil::attribSubCmdEx
#
# This procedure is invoked to process *attrib subcommands.
#------------------------------------------------------------------------------
proc mwutil::attribSubCmdEx {rootNs win prefix argList} {
    upvar ::${rootNs}::ns${win}::attribs attribs

    set argCount [llength $argList]
    if {$argCount > 1} {
	#
	# Set the specified attributes to the given values
	#
	if {$argCount % 2 != 0} {
	    return -code error "value for \"[lindex $argList end]\" missing"
	}
	foreach {attr val} $argList {
	    set attribs($prefix-$attr) $val
	}
	return ""
    } elseif {$argCount == 1} {
	#
	# Return the value of the specified attribute
	#
	set attr [lindex $argList 0]
	set name $prefix-$attr
	if {[info exists attribs($name)]} {
	    return $attribs($name)
	} else {
	    return ""
	}
    } else {
	#
	# Return the current list of attribute names and values
	#
	set len [string length "$prefix-"]
	set result {}
	foreach name [lsort [array names attribs "$prefix-*"]] {
	    set attr [string range $name $len end]
	    lappend result [list $attr $attribs($name)]
	}
	return $result
    }
}

#------------------------------------------------------------------------------
# mwutil::attribSubCmd
#
# This procedure is invoked to process *attrib subcommands.
#------------------------------------------------------------------------------
proc mwutil::attribSubCmd {win prefix argList} {
    set rootNs [string tolower [winfo class $win]]
    return [attribSubCmdEx $rootNs $win $prefix $argList]
}

#------------------------------------------------------------------------------
# mwutil::hasattribSubCmdEx
#
# This procedure is invoked to process has*attrib subcommands.
#------------------------------------------------------------------------------
proc mwutil::hasattribSubCmdEx {rootNs win prefix attr} {
    upvar ::${rootNs}::ns${win}::attribs attribs

    return [info exists attribs($prefix-$attr)]
}

#------------------------------------------------------------------------------
# mwutil::hasattribSubCmd
#
# This procedure is invoked to process has*attrib subcommands.
#------------------------------------------------------------------------------
proc mwutil::hasattribSubCmd {win prefix attr} {
    set rootNs [string tolower [winfo class $win]]
    return [hasattribSubCmdEx $rootNs $win $prefix $attr]
}

#------------------------------------------------------------------------------
# mwutil::unsetattribSubCmdEx
#
# This procedure is invoked to process unset*attrib subcommands.
#------------------------------------------------------------------------------
proc mwutil::unsetattribSubCmdEx {rootNs win prefix attr} {
    upvar ::${rootNs}::ns${win}::attribs attribs

    set name $prefix-$attr
    if {[info exists attribs($name)]} {
	unset attribs($name)
    }

    return ""
}

#------------------------------------------------------------------------------
# mwutil::unsetattribSubCmd
#
# This procedure is invoked to process unset*attrib subcommands.
#------------------------------------------------------------------------------
proc mwutil::unsetattribSubCmd {win prefix attr} {
    set rootNs [string tolower [winfo class $win]]
    return [unsetattribSubCmdEx $rootNs $win $prefix $attr]
}

#------------------------------------------------------------------------------
# mwutil::getScrollInfo
#
# Parses a list of arguments of the form "moveto <fraction>" or "scroll
# <number> units|pages" and returns the corresponding list consisting of two or
# three properly formatted elements.
#------------------------------------------------------------------------------
proc mwutil::getScrollInfo argList {
    set argCount [llength $argList]
    set opt [lindex $argList 0]

    if {[string first $opt "moveto"] == 0} {
	if {$argCount != 2} {
	    wrongNumArgs "moveto fraction"
	}

	set fraction [lindex $argList 1]
	format "%f" $fraction ;# floating-point number check with error message
	return [list moveto $fraction]
    } elseif {[string first $opt "scroll"] == 0} {
	if {$argCount != 3} {
	    wrongNumArgs "scroll number units|pages"
	}

	set number [lindex $argList 1]
	format "%f" $number   ;# floating-point number check with error message
	set number [expr {int($number > 0 ? ceil($number) : floor($number))}]
	set what [lindex $argList 2]
	if {[string first $what "units"] == 0} {
	    return [list scroll $number units]
	} elseif {[string first $what "pages"] == 0} {
	    return [list scroll $number pages]
	} else {
	    return -code error "bad argument \"$what\": must be units or pages"
	}
    } else {
	return -code error "unknown option \"$opt\": must be moveto or scroll"
    }
}

#------------------------------------------------------------------------------
# mwutil::getScrollInfo2
#
# Parses a list of arguments of the form "moveto <fraction>" or "scroll
# <number> units|pages" and returns the corresponding list consisting of two or
# three properly formatted elements.
#------------------------------------------------------------------------------
proc mwutil::getScrollInfo2 {cmd argList} {
    set argCount [llength $argList]
    set opt [lindex $argList 0]

    if {[string first $opt "moveto"] == 0} {
	if {$argCount != 2} {
	    wrongNumArgs "$cmd moveto fraction"
	}

	set fraction [lindex $argList 1]
	format "%f" $fraction ;# floating-point number check with error message
	return [list moveto $fraction]
    } elseif {[string first $opt "scroll"] == 0} {
	if {$argCount != 3} {
	    wrongNumArgs "$cmd scroll number units|pages"
	}

	set number [lindex $argList 1]
	format "%f" $number   ;# floating-point number check with error message
	set number [expr {int($number > 0 ? ceil($number) : floor($number))}]
	set what [lindex $argList 2]
	if {[string first $what "units"] == 0} {
	    return [list scroll $number units]
	} elseif {[string first $what "pages"] == 0} {
	    return [list scroll $number pages]
	} else {
	    return -code error "bad argument \"$what\": must be units or pages"
	}
    } else {
	return -code error "unknown option \"$opt\": must be moveto or scroll"
    }
}

#------------------------------------------------------------------------------
# mwutil::isScrollable
#
# Returns a boolean value indicating whether the widget w is scrollable along a
# given axis (x or y).
#------------------------------------------------------------------------------
proc mwutil::isScrollable {w axis} {
    set viewCmd ${axis}view
    return [expr {
	[catch {$w cget -${axis}scrollcommand}] == 0 &&
	[catch {$w $viewCmd} view] == 0 &&
	[catch {$w $viewCmd moveto [lindex $view 0]}] == 0 &&
	[catch {$w $viewCmd scroll 0 units}] == 0 &&
	[catch {$w $viewCmd scroll 0 pages}] == 0
    }]
}

#------------------------------------------------------------------------------
# mwutil::scrollByUnits
#
# Scrolls the widget w along a given axis (x or y) by units.  The number of
# units is obtained by converting the fraction built from the last two
# arguments to an integer, rounded away from 0.
#------------------------------------------------------------------------------
proc mwutil::scrollByUnits {w axis delta divisor} {
    set number [expr {$delta/$divisor}]
    set number [expr {int($number > 0 ? ceil($number) : floor($number))}]
    $w ${axis}view scroll $number units
}

#------------------------------------------------------------------------------
# mwutil::genMouseWheelEvent
#
# Generates a mouse wheel event with the given root coordinates and delta on
# the widget w.
#------------------------------------------------------------------------------
proc mwutil::genMouseWheelEvent {w event rootX rootY delta} {
    set needsFocus [expr {($::tk_version < 8.6 ||
	[package vcompare $::tk_patchLevel "8.6b2"] < 0) &&
	$::tcl_platform(platform) eq "windows"}]

    if {$needsFocus} {
	set focusWin [focus -displayof $w]
	focus $w
    }

    event generate $w $event -rootx $rootX -rooty $rootY -delta $delta

    if {$needsFocus} {
	focus $focusWin
    }
}

#------------------------------------------------------------------------------
# mwutil::containsPointer
#
# Returns a boolean value indicating whether the widget w contains the mouse
# pointer.
#------------------------------------------------------------------------------
proc mwutil::containsPointer w {
    if {![winfo viewable $w]} {
	return 0
    }

    foreach {ptrX ptrY} [winfo pointerxy $w] {}
    set wX [winfo rootx $w]
    set wY [winfo rooty $w]
    return [expr {
	$ptrX >= $wX && $ptrX < $wX + [winfo width  $w] &&
	$ptrY >= $wY && $ptrY < $wY + [winfo height $w]
    }]
}

#------------------------------------------------------------------------------
# mwutil::hasFocus
#
# Returns a boolean value indicating whether the focus window is (a descendant
# of) the widget w and has the same toplevel.
#------------------------------------------------------------------------------
proc mwutil::hasFocus w {
    set focusWin [focus -displayof $w]
    if {$focusWin eq ""} {
	return 0
    }

    return [expr {
	($w eq "." || [string first $w. $focusWin.] == 0) &&
	[winfo toplevel $w] eq [winfo toplevel $focusWin]
    }]
}

#------------------------------------------------------------------------------
# mwutil::windowingSystem
#
# Returns the windowing system ("x11", "win32", or "aqua").
#------------------------------------------------------------------------------
proc mwutil::windowingSystem {} {
    return [tk windowingsystem]
}

#------------------------------------------------------------------------------
# mwutil::currentTheme
#
# Returns the current tile theme.
#------------------------------------------------------------------------------
proc mwutil::currentTheme {} {
    if {[catch {ttk::style theme use} result] == 0} {
	return $result
    } elseif {[info exists ::ttk::currentTheme]} {
	return $::ttk::currentTheme
    } elseif {[info exists ::tile::currentTheme]} {
	return $::tile::currentTheme
    } else {
	return ""
    }
}

#------------------------------------------------------------------------------
# mwutil::isColorLight
#
# A quick & dirty method to check whether a given color can be classified as
# light.  Inspired by article "Support Dark and Light themes in Win32 apps"
# (see https://learn.microsoft.com/en-us/windows/apps/desktop/modernize/ui/
# apply-windows-themes).
#------------------------------------------------------------------------------
proc mwutil::isColorLight color {
    foreach {r g b} [winfo rgb . $color] {}
    return [expr {5 * ($g >> 8) + 2 * ($r >> 8) + ($b >> 8) > 8 * 128}]
}

#------------------------------------------------------------------------------
# mwutil::normalizeColor
#
# Returns the representation of a given color in the form "#RRGGBB".
#------------------------------------------------------------------------------
proc mwutil::normalizeColor color {
    foreach {r g b} [winfo rgb . $color] {}
    return [format "#%02x%02x%02x" \
	    [expr {$r >> 8}] [expr {$g >> 8}] [expr {$b >> 8}]]
}

#------------------------------------------------------------------------------
# mwutil::parsePadding
#
# Returns the 4-elements list of pixels corresponding to a given padding
# specification.
#------------------------------------------------------------------------------
proc mwutil::parsePadding {w padding} {
    switch [llength $padding] {
	0 {
	    set l 0; set t 0; set r 0; set b 0
	}
	1 {
	    set l [winfo pixels $w $padding]
	    set t $l; set r $l; set b $l
	}
	2 {
	    foreach {l t} $padding {}
	    set l [winfo pixels $w $l]
	    set t [winfo pixels $w $t]
	    set r $l; set b $t
	}
	3 {
	    foreach {l t r} $padding {}
	    set l [winfo pixels $w $l]
	    set t [winfo pixels $w $t]
	    set r [winfo pixels $w $r]
	    set b $t
	}
	4 {
	    foreach {l t r b} $padding {}
	    set l [winfo pixels $w $l]
	    set t [winfo pixels $w $t]
	    set r [winfo pixels $w $r]
	    set b [winfo pixels $w $b]
	}
	default {
	    return -code error "wrong # elements in padding spec \"$padding\""
	}
    }

    set result [list $l $t $r $b]
    foreach pad $result {
	if {$pad < 0} {
	    return -code error "bad pad value \"$pad\""
	}
    }

    return $result
}
