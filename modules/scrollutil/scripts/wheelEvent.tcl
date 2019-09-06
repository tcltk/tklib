#==============================================================================
# Contains procedures for mouse wheel event handling in scrollable widget
# containers like BWidget ScrollableFrame and iwidgets::scrolledframe.  Tested
# also with the scrolledframe::scrolledframe command of the Scrolledframe
# package by Maurice Bredelet (ulis) and its optimized and enhanced version
# contributed by Keith Nash, as well as with the sframe command implemented by
# Paul Walton (see https://wiki.tcl-lang.org/page/A+scrolled+frame).
#
# Structure of the module:
#   - Namespace initialization
#   - Public procedures
#   - Private procedures
#
# Copyright (c) 2019  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

if {[string compare $tcl_platform(platform) "windows"] == 0} {
    package require Tk 8.6b2
} else {
    package require Tk 8.4
}

#
# Namespace initialization
# ========================
#

namespace eval scrollutil {
    #
    # Mouse wheel event bindings for the binding
    # tags "WheeleventRedir" and "WheeleventBreak":
    #
    set eventList [list <MouseWheel> <Shift-MouseWheel>]
    switch [tk windowingsystem] {
	aqua {
	    lappend eventList <Option-MouseWheel> <Shift-Option-MouseWheel>
	}
	x11 {
	    lappend eventList <Button-4> <Button-5> \
			      <Shift-Button-4> <Shift-Button-5>
	}
    }
    foreach event $eventList {
	if {[string match <*Button-?> $event]} {
	    bind WheeleventRedir $event [format {
		if {![scrollutil::hasFocus %%W] ||
		    ![scrollutil::isCompatible %s %%W]} {
		    event generate [winfo toplevel %%W] %s \
			  -rootx %%X -rooty %%Y
		    break
		}
	    } $event $event]
	} else {
	    bind WheeleventRedir $event [format {
		if {![scrollutil::hasFocus %%W] ||
		    ![scrollutil::isCompatible %s %%W]} {
		    event generate [winfo toplevel %%W] %s \
			  -rootx %%X -rooty %%Y -delta %%D
		    break
		}
	    } $event $event]
	}

	bind WheeleventBreak $event { break }
    }

    #
    # The list of scrollable widget containers that are
    # registered for scrolling by the mouse wheel event
    # bindings created by the createWheelEventBindings command:
    #
    variable scrlWidgetContList {}

    #
    # <Destroy> event binding for the binding tag "ScrlWidgetCont":
    #
    bind ScrlWidgetCont <Destroy> {
	scrollutil::onScrlWidgetContDestroy %W
    }

    #
    # <Destroy> event binding for the binding tag "WheeleventWidget":
    #
    bind WheeleventWidget <Destroy> {
	unset -nocomplain scrollutil::focusCheckWinArr(%W)
    }
}

#
# Public procedures
# =================
#

#------------------------------------------------------------------------------
# scrollutil::createWheelEventBindings
#
# Usage: scrollutil::createWheelEventBindings ?tag tag ...?
#
# Creates mouse wheel event bindings for the specified binding tags such that
# if the widget under the pointer is (a descendant of) one of the registered
# scrollable widget containers then these events will trigger a scrolling of
# that widget container.  Each tag argument must be "all" or the path name of
# an existing toplevel widget.
#------------------------------------------------------------------------------
proc scrollutil::createWheelEventBindings args {
    set winSys [tk windowingsystem]
    foreach tag $args {
	if {[string match .* $tag]} {
	    if {![winfo exists $tag]} {
		return -code error "bad window path name \"$tag\""
	    }

	    if {[winfo toplevel $tag] ne $tag} {
		return -code error "\"$tag\" is not a toplevel widget"
	    }
	} elseif {$tag ne "all"} {
	    return -code error "unsupported tag \"$tag\": must be \"all\" or\
		the path name of an existing toplevel widget"
	}

	if {$winSys eq "aqua"} {
	    bind $tag <MouseWheel> {
		scrollutil::scrollByUnits %W %X %Y y [expr {-%D}]
	    }
	    bind $tag <Option-MouseWheel> {
		scrollutil::scrollByUnits %W %X %Y y [expr {-10 * %D}]
	    }

	    bind $tag <Shift-MouseWheel> {
		scrollutil::scrollByUnits %W %X %Y x [expr {-%D}]
	    }
	    bind $tag <Shift-Option-MouseWheel> {
		scrollutil::scrollByUnits %W %X %Y x [expr {-10 * %D}]
	    }
	} else {
	    bind $tag <MouseWheel> {
		scrollutil::scrollByUnits %W %X %Y y [expr {-(%D/120) * 4}]
	    }
	    bind $tag <Shift-MouseWheel> {
		scrollutil::scrollByUnits %W %X %Y x [expr {-(%D/120) * 4}]
	    }

	    if {$winSys eq "x11"} {
		bind $tag <Button-4> {
		    scrollutil::scrollByUnits %W %X %Y y -5
		}
		bind $tag <Button-5> {
		    scrollutil::scrollByUnits %W %X %Y y  5
		}
		bind $tag <Shift-Button-4> {
		    scrollutil::scrollByUnits %W %X %Y x -5
		}
		bind $tag <Shift-Button-5> {
		    scrollutil::scrollByUnits %W %X %Y x  5
		}
	    }
	}
    }
}

#------------------------------------------------------------------------------
# scrollutil::enableScrollingByWheel
#
# Usage: scrollutil::enableScrollingByWheel ?scrlWidgetCont scrlWidgetCont ...?
#
# Adds the specified scrollable widget containers to the internal list of
# widget containers that are registered for scrolling by the mouse wheel event
# bindings created by the createWheelEventBindings command.
#------------------------------------------------------------------------------
proc scrollutil::enableScrollingByWheel args {
    variable scrlWidgetContList
    foreach swc $args {
	if {![winfo exists $swc]} {
	    return -code error "bad window path name \"$swc\""
	}

	if {[catch {$swc xview scroll 0 units}] != 0} {
	    return -code error "\"$swc\" fails to support horizontal scrolling\
		by units"
	}

	if {[catch {$swc yview scroll 0 units}] != 0} {
	    return -code error "\"$swc\" fails to support vertical scrolling\
		by units"
	}

	if {[lsearch -exact $scrlWidgetContList $swc] >= 0} {
	    continue
	}

	lappend scrlWidgetContList $swc

	set tagList [bindtags $swc]
	if {[lsearch -exact $tagList "ScrlWidgetCont"] < 0} {
	    bindtags $swc [linsert $tagList 1 ScrlWidgetCont]
	}
    }
}

#------------------------------------------------------------------------------
# scrollutil::adaptWheelEventHandling
#
# Usage: scrollutil::adaptWheelEventHandling ?widget widget ...?
#
# For each widget argument, the command performs the following actions:
#
#   * If $widget is a tablelist then it sets the latter's -xmousewheelwindow
#     and -ymousewheelwindow options to the path name of the containing
#     toplevel window (for Tablelist versions 6.4 and later).
#
#   * Otherwise it locates the (first) binding tag that has mouse wheel event
#     bindings and is different from both the path name of the containing
#     toplevel window and "all".  If the search for this tag was successful
#     then the command modifies the widget's list of binding tags by prepending
#     the tag "WheeleventRedir" and appending the tag "WheeleventBreak" to this
#     binding tag.  As a result, a mouse wheel event sent to this widget will
#     be handled as follows:
#
#       - If the focus is on or inside the window [focusCheckWindow $widget]
#         then the event will be handled by the binding script associated with
#         this tag and no further processing of the event will take place.
#
#       - If the focus is outside the window [focusCheckWindow $widget] then
#         the event will be redirected to the containing toplevel window via
#         event generate rather than being handled by the binding script
#         associated with the above-mentioned tag.
#------------------------------------------------------------------------------
proc scrollutil::adaptWheelEventHandling args {
    set winSys [tk windowingsystem]
    foreach w $args {
	if {![winfo exists $w]} {
	    return -code error "bad window path name \"$w\""
	}

	set wTop [winfo toplevel $w]
	if {[winfo class $w] eq "Tablelist"} {
	    if {[package vcompare $::tablelist::version "6.4"] >= 0} {
		$w configure -xmousewheelwindow $wTop -ymousewheelwindow $wTop
	    }
	} else {
	    set tagList [bindtags $w]
	    if {[lsearch -exact $tagList "WheeleventRedir"] >= 0} {
		continue
	    }

	    foreach tag $tagList {
		if {$tag eq $wTop || $tag eq "all" ||
		    ($winSys eq "x11" && [bind $tag <Button-4>] eq "") ||
		    ($winSys ne "x11" && [bind $tag <MouseWheel>] eq "")} {
		    continue
		}

		set tagIdx [lsearch -exact $tagList $tag]
		bindtags $w [lreplace $tagList $tagIdx $tagIdx \
			     WheeleventRedir $tag WheeleventBreak]
		break
	    }
	}
    }
}

#------------------------------------------------------------------------------
# scrollutil::setFocusCheckWindow
#
# Usage: scrollutil::setFocusCheckWindow widget ?widget ...? otherWidget
#
# For each widget argument, the command sets the associated "focus check
# window" to otherWidget.  This is the window to be used instead of the widget
# when checking whether the focus is on/inside or outside that window.  It must
# be an ancestor of or identical to widget.
#------------------------------------------------------------------------------
proc scrollutil::setFocusCheckWindow args {
    set argCount [llength $args]
    if {$argCount < 2} {
	return -code error "wrong # args: should be\
	    \"scrollutil::setFocusCheckWindow widget ?widget ...? otherWidget\""
    }

    foreach w $args {
	if {![winfo exists $w]} {
	    return -code error "bad window path name \"$w\""
	}
    }

    set w2 [lindex $args end]

    variable focusCheckWinArr
    set n 0
    foreach w $args {
	if {$n == $argCount - 1} {
	    return ""
	}

	if {[string first $w2. $w.] != 0} {
	    return -code error \
		"\"$w2\" is neither an ancestor of nor is identical to \"$w\""
	}

	set focusCheckWinArr($w) $w2

	set tagList [bindtags $w]
	if {[lsearch -exact $tagList "WheeleventWidget"] < 0} {
	    bindtags $w [linsert $tagList 1 WheeleventWidget]
	}

	incr n
    }
}

#------------------------------------------------------------------------------
# scrollutil::focusCheckWindow
#
# Usage: scrollutil::focusCheckWindow widget
#
# Returns the "focus check window" associated with widget.  This is the window
# that is used instead of the widget when checking whether the focus is
# on/inside or outside that window.  If the command setFocusCheckWindow was not
# invoked for widget then the return value is widget itself.
#------------------------------------------------------------------------------
proc scrollutil::focusCheckWindow w {
    if {![winfo exists $w]} {
	return -code error "bad window path name \"$w\""
    }

    variable focusCheckWinArr
    return [expr {[info exists focusCheckWinArr($w)] ?
		  $focusCheckWinArr($w) : $w}]
}

#
# Private procedures
# ==================
#

#------------------------------------------------------------------------------
# scrollutil::hasFocus
#------------------------------------------------------------------------------
proc scrollutil::hasFocus w {
    set focusWin [focus -displayof $w]
    if {$focusWin eq ""} {
	set focusTop ""
    } else {
	set focusTop [winfo toplevel $focusWin]
    }

    set focusCheckWin [focusCheckWindow $w]
    if {[string first $focusCheckWin. $focusWin.] == 0 &&
	[winfo toplevel $focusCheckWin] eq $focusTop} {
	return 1
    } elseif {[string match "*Scrollbar" [winfo class $w]]} {
	set w2 [lindex [$w cget -command] 0]	;# the associated widget
	set focusCheckWin2 [focusCheckWindow $w2]
	return [expr {[winfo exists $w2] &&
		      [string first $focusCheckWin2. $focusWin.] == 0 &&
		      [winfo toplevel $focusCheckWin2] eq $focusTop}]
    } else {
	return 0
    }
}

#------------------------------------------------------------------------------
# scrollutil::isCompatible
#------------------------------------------------------------------------------
proc scrollutil::isCompatible {event w} {
    set tagList [bindtags $w]
    set idx [lsearch -exact $tagList "WheeleventRedir"]
    set tag [lindex $tagList [incr idx]]
    if {[bind $tag $event] eq ""} {
	return 0
    } elseif {[string match "*Scrollbar" [winfo class $w]]} {
	set orient [$w cget -orient]
	return [expr {
	    ($orient eq "horizontal" &&  [string match "<Shift-*>" $event]) ||
	    ($orient eq "vertical"   && ![string match "<Shift-*>" $event])
	}]
    } else {
	return 1
    }
}

#------------------------------------------------------------------------------
# scrollutil::scrollByUnits
#------------------------------------------------------------------------------
proc scrollutil::scrollByUnits {w rootX rootY axis units} {
    set w [winfo containing -displayof $w $rootX $rootY]
    variable scrlWidgetContList
    foreach swc $scrlWidgetContList {
	if {[mayScroll $swc $w]} {
	    $swc ${axis}view scroll $units units
	    return ""
	}
    }
}

#------------------------------------------------------------------------------
# scrollutil::mayScroll
#------------------------------------------------------------------------------
proc scrollutil::mayScroll {swc w} {
    if {[string first $swc. $w.] != 0} {    ;# $w is not (a descendant of) $swc
	return 0
    }

    set swcTop [winfo toplevel $swc]
    set wTop [winfo toplevel $w]
    if {$swcTop ne $wTop} {		;# $swc and $w have different toplevels
	return 0
    }

    if {[winfo class $swc] eq "Scrolledframe" &&
	[llength [info commands ::iwidgets::scrolledframe]] != 0 &&
	($w eq [$swc component horizsb] || $w eq [$swc component vertsb])} {
	return 0
    }

    #
    # Don't scroll the window $swc if the toplevel window of any
    # combobox widget contained in it is currently popped down
    #
    set swcTop [winfo toplevel $swc]
    set toplevelList [wm stackorder $swcTop]
    if {[llength $toplevelList] == 1} {
	return 1
    } else {
	foreach top $toplevelList {
	    if {$top eq $swcTop} {
		continue
	    }

	    #
	    # Check whether the toplevel $top is a child of a
	    # ttk::combobox, BWidget ComboBox or Oakley combobox
	    # widget, or is a descendant of an iwidgets::combobox
	    #
	    set topName [winfo name $top]
	    set topPar  [winfo parent $top]
	    set topParClass [winfo class $topPar]
	    set topParName  [winfo name $topPar]
	    if {($topParClass eq "TCombobox"  && $topName eq "popdown") ||
		($topParClass eq "ComboBox"   && $topName eq "shell") ||
		($topParClass eq "Combobox"   && $topName eq "top") ||
		($topParName eq "efchildsite" && $topName eq "popup")} {
		return 0
	    }
	}

	return 1
    }
}

#------------------------------------------------------------------------------
# scrollutil::onScrlWidgetContDestroy
#------------------------------------------------------------------------------
proc scrollutil::onScrlWidgetContDestroy swc {
    variable scrlWidgetContList
    set idx [lsearch -exact $scrlWidgetContList $swc]
    set scrlWidgetContList [lreplace $scrlWidgetContList $idx $idx]
}
