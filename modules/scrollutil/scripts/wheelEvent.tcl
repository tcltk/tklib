#==============================================================================
# Contains procedures related to mouse wheel event handling in scrollable
# widgets and scrollable widget containers like scrollutil::scrollableframe,
# BWidget ScrollableFrame, and iwidgets::scrolledframe.  Tested also with the
# scrolledframe::scrolledframe command of the Scrolledframe package by Maurice
# Bredelet (ulis) and its optimized and enhanced version contributed by Keith
# Nash, as well as with the sframe command implemented by Paul Walton (see
# https://wiki.tcl-lang.org/page/A+scrolled+frame).
#
# Structure of the module:
#   - Namespace initialization
#   - Private procedure creating mouse wheel and <Destroy> event bindings
#   - Public procedures
#   - Private procedures
#
# Copyright (c) 2019-2025  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

#
# Namespace initialization
# ========================
#

namespace eval scrollutil {
    #
    # The list of scrollable widget containers that are
    # registered for scrolling by the mouse wheel event
    # bindings created by the createWheelEventBindings command:
    #
    variable scrlWidgetContList {}

    variable uniformWheelSupport [expr {$::tk_version >= 8.7 &&
	[package vcompare $::tk_patchLevel "8.7a4"] >= 0}]

    variable touchpadScrollSupport [expr {
	[llength [info commands ::tk::PreciseScrollDeltas]] != 0}]
}

#
# Private procedure creating mouse wheel and <Destroy> event bindings
# ===================================================================
#

#------------------------------------------------------------------------------
# scrollutil::createBindings
#
# Creates mouse wheel event bindings for the binding tags Scrollbar,
# TScrollbar, WheeleventRedir, and WheeleventBreak, as well as <Destroy> event
# bindings for the binding tags ScrlWidgetCont and WheeleventWidget.
#------------------------------------------------------------------------------
proc scrollutil::createBindings {} {
    variable winSys
    variable uniformWheelSupport

    #
    # On the windowing systems win32 and x11 there are no built-in mouse wheel
    # event bindings for the binding tag Scrollbar if the Tk version is earlier
    # than 8.6 -- create them here.  In addition, implement the behavior
    # specified by TIP 563 (i.e., the mouse wheel should scroll a horizontal or
    # vertical scrollbar regardless of whether the "Shift" key is down or not)
    #
    bind Scrollbar <Enter> {+
	if {![info exists tk::Priv(xEvents)]} {
	    set scrollutil::xWheelEvents 0; set scrollutil::yWheelEvents 0
	}
    }
    if {$uniformWheelSupport} {
	bind Scrollbar <MouseWheel> {
	    scrollutil::condScrollByUnits %W vh %D -40.0
	}
	bind Scrollbar <Option-MouseWheel> {
	    scrollutil::condScrollByUnits %W vh %D -12.0
	}
	bind Scrollbar <Shift-MouseWheel> {
	    scrollutil::condScrollByUnits %W hv %D -40.0
	}
	bind Scrollbar <Shift-Option-MouseWheel> {
	    scrollutil::condScrollByUnits %W hv %D -12.0
	}
    } else {
	if {$winSys eq "aqua"} {
	    bind Scrollbar <MouseWheel> {
		scrollutil::condScrollByUnits %W vh [expr {-(%D)}]
	    }
	    bind Scrollbar <Option-MouseWheel> {
		scrollutil::condScrollByUnits %W vh [expr {-10 * (%D)}]
	    }
	    bind Scrollbar <Shift-MouseWheel> {
		scrollutil::condScrollByUnits %W hv [expr {-(%D)}]
	    }
	    bind Scrollbar <Shift-Option-MouseWheel> {
		scrollutil::condScrollByUnits %W hv [expr {-10 * (%D)}]
	    }
	} else {
	    bind Scrollbar <MouseWheel> {
		scrollutil::condScrollByUnits %W vh \
		    [expr {%D >= 0 ? (-%D) / 30 : (-(%D) + 29) / 30}]
	    }
	    bind Scrollbar <Shift-MouseWheel> {
		scrollutil::condScrollByUnits %W hv \
		    [expr {%D >= 0 ? (-%D) / 30 : (-(%D) + 29) / 30}]
	    }

	    if {$winSys eq "x11"} {
		bind Scrollbar <Button-4> {
		    scrollutil::condScrollByUnits %W vh -5
		}
		bind Scrollbar <Button-5> {
		    scrollutil::condScrollByUnits %W vh  5
		}
		bind Scrollbar <Shift-Button-4> {
		    scrollutil::condScrollByUnits %W hv -5
		}
		bind Scrollbar <Shift-Button-5> {
		    scrollutil::condScrollByUnits %W hv  5
		}

		if {$::tk_patchLevel eq "8.7a3"} {
		    bind Scrollbar <Button-6> {
			scrollutil::condScrollByUnits %W hv -5
		    }
		    bind Scrollbar <Button-7> {
			scrollutil::condScrollByUnits %W hv  5
		    }
		}
	    }
	}
    }

    set eventList [list <MouseWheel> <Shift-MouseWheel>]
    if {$uniformWheelSupport} {
	lappend eventList <Option-MouseWheel> <Shift-Option-MouseWheel>
    } else {
	switch $winSys {
	    aqua {
		lappend eventList <Option-MouseWheel> <Shift-Option-MouseWheel>
	    }
	    x11 {
		lappend eventList \
		    <Button-4> <Button-5> <Shift-Button-4> <Shift-Button-5>
		if {$::tk_patchLevel eq "8.7a3"} {
		    lappend eventList <Button-6> <Button-7>
		}
	    }
	}
    }

    #
    # Copy the mouse wheel event bindings of the widget
    # class Scrollbar to the binding tag TScrollbar
    #
    bind TScrollbar <Enter> {+
	if {![info exists tk::Priv(xEvents)]} {
	    set scrollutil::xWheelEvents 0; set scrollutil::yWheelEvents 0
	}
    }
    foreach event $eventList {
	bind TScrollbar $event [bind Scrollbar $event]
    }

    if {$winSys eq "win32" && ($::tk_version < 8.6 ||
	[package vcompare $::tk_patchLevel "8.6b2"] < 0)} {
	return ""
    }

    #
    # The rest is for scrollable widget containers.
    #

    foreach event $eventList {
	if {[string match <*Button-?> $event]} {
	    ##nagelfar ignore
	    bind WheeleventRedir $event [format {
		if {![scrollutil::hasFocus %%W] ||
		    ![scrollutil::isCompatible %s %%W]} {
		    event generate [winfo toplevel %%W] %s \
			-rootx %%X -rooty %%Y
		    break
		}
	    } $event $event]
	} else {
	    ##nagelfar ignore
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

    variable touchpadScrollSupport
    if {$touchpadScrollSupport} {
	bind WheeleventRedir <TouchpadScroll> {
	    if {![scrollutil::hasFocus %W] ||
		![scrollutil::isCompatible <TouchpadScroll> %W]} {
		lassign [tk::PreciseScrollDeltas %D] \
		    scrollutil::dX scrollutil::dY
		if {%# %% 5 == 0 && $scrollutil::dX != 0} {
		    event generate [winfo toplevel %W] <Shift-MouseWheel> \
			-rootx %X -rooty %Y -delta [expr {40 * $scrollutil::dX}]
		}
		if {%# %% 5 == 0 && $scrollutil::dY != 0} {
		    event generate [winfo toplevel %W] <MouseWheel> \
			-rootx %X -rooty %Y -delta [expr {40 * $scrollutil::dY}]
		}
		break
	    }
	}

	bind WheeleventBreak <TouchpadScroll> { break }
    }

    bind ScrlWidgetCont <Destroy> { scrollutil::onScrlWidgetContDestroy %W }

    bind WheeleventWidget <Destroy> {
	unset -nocomplain scrollutil::focusCheckWinArr(%W)
    }
}

#
# Public procedures
# =================
#

#------------------------------------------------------------------------------
# scrollutil::addMouseWheelSupport
#
# Usage: scrollutil::addMouseWheelSupport tag ?(xy|x|y)?
#
# Creates mouse wheel event bindings for the specified binding tag and optional
# axes, which must be "xy" (the default), "x", or "y".
#------------------------------------------------------------------------------
proc scrollutil::addMouseWheelSupport {tag {axes "xy"}} {
    if {$axes ne "xy" && $axes ne "x" && $axes ne "y"} {
	return -code error "bad axes \"$axes\": must be xy, x, or y"
    }

    set isWindow [string match .* $tag]
    if {$isWindow} {
	if {![winfo exists $tag]} {
	    return -code error "bad window path name \"$tag\""
	}

	set isMenubtn	 [expr {[winfo class $tag] eq "Menubutton"}]
	set isTtkMenubtn [expr {[winfo class $tag] eq "TMenubutton"}]

	set isScale	[expr {[winfo class $tag] eq "Scale"}]
	set isTtkScale	[expr {[winfo class $tag] eq "TScale"}]

	if {!($isMenubtn || $isTtkMenubtn || $isScale || $isTtkScale)} {
	    if {[string first "x" $axes] >= 0 &&
		[catch {$tag xview scroll 0 units}] != 0} {
		return -code error \
		    "widget $tag fails to support horizontal scrolling by units"
	    }

	    if {[string first "y" $axes] >= 0 &&
		[catch {$tag yview scroll 0 units}] != 0} {
		return -code error \
		    "widget $tag fails to support vertical scrolling by units"
	    }
	}

	set tail "; break"
    } else {
	set isMenubtn	 [expr {$tag eq "Menubutton"}]
	set isTtkMenubtn [expr {$tag eq "TMenubutton"}]

	set isScale	[expr {$tag eq "Scale"}]
	set isTtkScale	[expr {$tag eq "TScale"}]

	set tail ""
    }

    if {$isMenubtn} {
	set script {
	    if {[%W cget -state] eq "disabled"} continue
	    scrollutil::cycleMenuEntry1 %W}
	bindMouseWheel $tag $script $tail
    } elseif {$isTtkMenubtn} {
	set script {
	    %W instate disabled continue
	    scrollutil::cycleMenuEntry1 %W}
	bindMouseWheel $tag $script $tail
    } elseif {$isScale} {
	bind $tag <Enter> {
	    set scrollutil::xWheelEvents 0; set scrollutil::yWheelEvents 0
	}

	set script {
	    if {[%W cget -state] eq "disabled"} continue
	    scrollutil::scaleIncrement1 %W}
	bindMouseWheel $tag $script $tail
    } elseif {$isTtkScale} {
	bind $tag <Enter> {
	    set scrollutil::xWheelEvents 0; set scrollutil::yWheelEvents 0
	}

	set script {
	    %W instate disabled continue
	    scrollutil::ttkScaleIncrement1 %W}
	bindMouseWheel $tag $script $tail
    } else {
	variable winSys
	variable uniformWheelSupport

	if {[string first "y" $axes] >= 0} {
	    if {$uniformWheelSupport} {
		bind $tag <MouseWheel> \
		    "mwutil::scrollByUnits %W y %D -40.0 $tail"
		bind $tag <Option-MouseWheel> \
		    "mwutil::scrollByUnits %W y %D -12.0 $tail"
	    } elseif {$winSys eq "aqua"} {
		bind $tag <MouseWheel> \
		    "mwutil::scrollByUnits %W y %D  -1.0 $tail"
		bind $tag <Option-MouseWheel> \
		    "mwutil::scrollByUnits %W y %D  -0.1 $tail"
	    } else {
		bind $tag <MouseWheel> \
		    "mwutil::scrollByUnits %W y %D -30.0 $tail"

		if {$winSys eq "x11"} {
		    bind $tag <Button-4> "%W yview scroll -5 units $tail"
		    bind $tag <Button-5> "%W yview scroll  5 units $tail"
		}
	    }
	} else {
	    if {$uniformWheelSupport || $winSys eq "aqua"} {
		bind $tag <MouseWheel>		{ # nothing }
		bind $tag <Option-MouseWheel>	{ # nothing }
	    } else {
		bind $tag <MouseWheel>		{ # nothing }

		if {$winSys eq "x11"} {
		    bind $tag <Button-4>	{ # nothing }
		    bind $tag <Button-5>	{ # nothing }
		}
	    }
	}

	if {[string first "x" $axes] >= 0} {
	    if {$uniformWheelSupport} {
		bind $tag <Shift-MouseWheel> \
		    "mwutil::scrollByUnits %W x %D -40.0 $tail"
		bind $tag <Shift-Option-MouseWheel> \
		    "mwutil::scrollByUnits %W x %D -12.0 $tail"
	    } elseif {$winSys eq "aqua"} {
		bind $tag <Shift-MouseWheel> \
		    "mwutil::scrollByUnits %W x %D  -1.0 $tail"
		bind $tag <Shift-Option-MouseWheel> \
		    "mwutil::scrollByUnits %W x %D  -0.1 $tail"
	    } else {
		bind $tag <Shift-MouseWheel> \
		    "mwutil::scrollByUnits %W x %D -30.0 $tail"

		if {$winSys eq "x11"} {
		    bind $tag <Shift-Button-4> "%W xview scroll -5 units $tail"
		    bind $tag <Shift-Button-5> "%W xview scroll  5 units $tail"

		    if {$::tk_patchLevel eq "8.7a3"} {
			bind $tag <Button-6> "%W xview scroll -5 units $tail"
			bind $tag <Button-7> "%W xview scroll  5 units $tail"
		    }
		}
	    }
	} else {
	    if {$uniformWheelSupport || $winSys eq "aqua"} {
		bind $tag <Shift-MouseWheel>		{ # nothing }
		bind $tag <Shift-Option-MouseWheel>	{ # nothing }
	    } else {
		bind $tag <Shift-MouseWheel>	{ # nothing }

		if {$winSys eq "x11"} {
		    bind $tag <Shift-Button-4>	{ # nothing }
		    bind $tag <Shift-Button-5>	{ # nothing }

		    if {$::tk_patchLevel eq "8.7a3"} {
			bind $tag <Button-6>	{ # nothing }
			bind $tag <Button-7>	{ # nothing }
		    }
		}
	    }
	}
    }

    variable touchpadScrollSupport
    if {!$touchpadScrollSupport} {
	return ""
    }

    if {$isMenubtn} {
	set script {
	    if {[%W cget -state] eq "disabled"} continue
	    if {%# %% 15 == 0} {
		scrollutil::cycleMenuEntry2 %W %D
	    }
	}
    } elseif {$isTtkMenubtn} {
	set script {
	    %W instate disabled continue
	    if {%# %% 15 == 0} {
		scrollutil::cycleMenuEntry2 %W %D
	    }
	}
    } elseif {$isScale} {
	set script {
	    if {[%W cget -state] eq "disabled"} continue
	    if {%# %% 15 == 0} {
		scrollutil::scaleIncrement2 %W %D
	    }
	}
    } elseif {$isTtkScale} {
	set script {
	    %W instate disabled continue
	    if {%# %% 15 == 0} {
		scrollutil::ttkScaleIncrement2 %W %D
	    }
	}
    } else {
	set script "if {%# %% 5 != 0} "
	append script [expr {$isWindow ? "break" : "return"}]
	append script {
	    lassign [tk::PreciseScrollDeltas %D] scrollutil::dX scrollutil::dY
	}
	switch $axes {
	    xy {
		append script {
		    if {$scrollutil::dX != 0} {
			%W xview scroll [expr {-$scrollutil::dX}] units
		    }
		    if {$scrollutil::dY != 0} {
			%W yview scroll [expr {-$scrollutil::dY}] units
		    }
		}
	    }
	    x {
		append script {
		    if {$scrollutil::dX != 0} {
			%W xview scroll [expr {-$scrollutil::dX}] units
		    }
		}
	    }
	    y {
		append script {
		    if {$scrollutil::dY != 0} {
			%W yview scroll [expr {-$scrollutil::dY}] units
		    }
		}
	    }
	}
    }

    if {$isWindow} {
	append script break
    }
    bind $tag <TouchpadScroll> $script
}

#------------------------------------------------------------------------------
# scrollutil::createWheelEventBindings
#
# Usage: scrollutil::createWheelEventBindings ?tag tag ...?
#
# Creates mouse wheel event bindings for the specified binding tags such that
# if the widget under the pointer is (a descendant of) one of the registered
# scrollable widget containers then these events will trigger a scrolling of
# that widget container.  In case of several nested registered scrollable
# widget containers fulfilling this condition the innermost one will be
# scrolled.  Each tag argument must be "all" or the path name of an existing
# toplevel widget.
#------------------------------------------------------------------------------
proc scrollutil::createWheelEventBindings args {
    variable winSys
    if {$winSys eq "win32"} {
	package require Tk 8.6b2-
    }
    variable uniformWheelSupport
    variable touchpadScrollSupport

    foreach tag $args {
	if {[string match .* $tag]} {
	    if {![winfo exists $tag]} {
		return -code error "bad window path name \"$tag\""
	    }

	    if {[winfo toplevel $tag] ne $tag} {
		return -code error "$tag is not a toplevel widget"
	    }
	} elseif {$tag ne "all"} {
	    return -code error "unsupported tag \"$tag\": must be all or the\
		path name of an existing toplevel widget"
	}

	if {$uniformWheelSupport} {
	    bind $tag <MouseWheel> {
		scrollutil::scrollByUnits %W %X %Y y %D -40.0
	    }
	    bind $tag <Option-MouseWheel> {
		scrollutil::scrollByUnits %W %X %Y y %D -12.0
	    }
	    bind $tag <Shift-MouseWheel> {
		scrollutil::scrollByUnits %W %X %Y x %D -40.0
	    }
	    bind $tag <Shift-Option-MouseWheel> {
		scrollutil::scrollByUnits %W %X %Y x %D -12.0
	    }
	} elseif {$winSys eq "aqua"} {
	    bind $tag <MouseWheel> {
		scrollutil::scrollByUnits %W %X %Y y %D  -1.0
	    }
	    bind $tag <Option-MouseWheel> {
		scrollutil::scrollByUnits %W %X %Y y %D  -0.1
	    }
	    bind $tag <Shift-MouseWheel> {
		scrollutil::scrollByUnits %W %X %Y x %D  -1.0
	    }
	    bind $tag <Shift-Option-MouseWheel> {
		scrollutil::scrollByUnits %W %X %Y x %D  -0.1
	    }
	} else {
	    bind $tag <MouseWheel> {
		scrollutil::scrollByUnits %W %X %Y y %D -30.0
	    }
	    bind $tag <Shift-MouseWheel> {
		scrollutil::scrollByUnits %W %X %Y x %D -30.0
	    }

	    if {$winSys eq "x11"} {
		bind $tag <Button-4> {
		    scrollutil::scrollByUnits %W %X %Y y -5 1.0
		}
		bind $tag <Button-5> {
		    scrollutil::scrollByUnits %W %X %Y y  5 1.0
		}
		bind $tag <Shift-Button-4> {
		    scrollutil::scrollByUnits %W %X %Y x -5 1.0
		}
		bind $tag <Shift-Button-5> {
		    scrollutil::scrollByUnits %W %X %Y x  5 1.0
		}

		if {$::tk_patchLevel eq "8.7a3"} {
		    bind $tag <Button-6> {
			scrollutil::scrollByUnits %W %X %Y x -5 1.0
		    }
		    bind $tag <Button-7> {
			scrollutil::scrollByUnits %W %X %Y x  5 1.0
		    }
		}
	    }
	}

	if {$touchpadScrollSupport} {
	    bind $tag <TouchpadScroll> {
		if {%# %% 5 != 0} {
		    continue
		}
		lassign [tk::PreciseScrollDeltas %D] \
		    scrollutil::dX scrollutil::dY
		if {$scrollutil::dX != 0} {
		    event generate %W <Shift-MouseWheel> -rootx %X -rooty %Y \
			-delta [expr {40 * $scrollutil::dX}]
		}
		if {$scrollutil::dY != 0} {
		    event generate %W <MouseWheel> -rootx %X -rooty %Y \
			-delta [expr {40 * $scrollutil::dY}]
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
    variable winSys
    if {$winSys eq "win32"} {
	package require Tk 8.6b2-
    }

    variable scrlWidgetContList
    foreach swc $args {
	if {![winfo exists $swc]} {
	    return -code error "bad window path name \"$swc\""
	}

	if {[catch {$swc xview scroll 0 units}] != 0} {
	    return -code error \
		"widget $swc fails to support horizontal scrolling by units"
	}

	if {[catch {$swc yview scroll 0 units}] != 0} {
	    return -code error \
		"widget $swc fails to support vertical scrolling by units"
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

    set scrlWidgetContList [lsort -command comparePaths $scrlWidgetContList]
}

#------------------------------------------------------------------------------
# scrollutil::disableScrollingByWheel
#
# Usage: scrollutil::disableScrollingByWheel ?scrlWidgetCont scrlWidgetCont ...?
#
# Removes the specified scrollable widget containers from the internal list of
# widget containers that are registered for scrolling by the mouse wheel event
# bindings created by the createWheelEventBindings command.
#------------------------------------------------------------------------------
proc scrollutil::disableScrollingByWheel args {
    variable winSys
    if {$winSys eq "win32"} {
	package require Tk 8.6b2-
    }

    variable scrlWidgetContList
    foreach swc $args {
	if {![winfo exists $swc]} {
	    return -code error "bad window path name \"$swc\""
	}

	if {[set idx [lsearch -exact $scrlWidgetContList $swc]] < 0} {
	    continue
	}

	set scrlWidgetContList [lreplace $scrlWidgetContList $idx $idx]

	set tagList [bindtags $swc]
	set idx [lsearch -exact $tagList "ScrlWidgetCont"]
	bindtags $swc [lreplace $tagList $idx $idx]
    }

    set scrlWidgetContList [lsort -command comparePaths $scrlWidgetContList]
}

#------------------------------------------------------------------------------
# scrollutil::adaptWheelEventHandling
#
# Usage: scrollutil::adaptWheelEventHandling ?-ignorefocus? ?widget widget ...?
#
# If the -ignorefocus option is not present then, for each widget argument, the
# command performs the following actions:
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
#
# If the -ignorefocus option is specified then, for each widget argument, the
# command performs the following actions:
#
#   * If $widget is a tablelist then it resets the latter's -xmousewheelwindow
#     and -ymousewheelwindow options (for Tablelist versions 6.4 and later).
#
#   * Otherwise it locates the (first) binding tag that has mouse wheel event
#     bindings and is different from both the path name of the containing
#     toplevel window and "all".  If the search for this tag was successful
#     then the command modifies the widget's list of binding tags by appending
#     the tag "WheeleventBreak" to this binding tag.  As a result, a mouse
#     wheel event sent to this widget will be handled by the binding script
#     associated with this tag and no further processing of the event will take
#     place.
#------------------------------------------------------------------------------
proc scrollutil::adaptWheelEventHandling args {
    variable winSys
    if {$winSys eq "win32"} {
	package require Tk 8.6b2-
    }
    variable uniformWheelSupport

    set ignoreFocus 0
    set arg0 [lindex $args 0]
    if {[string length $arg0] > 1 && [string first $arg0 "-ignorefocus"] == 0} {
	set ignoreFocus 1
	set args [lrange $args 1 end]
    }

    foreach w $args {
	if {![winfo exists $w]} {
	    return -code error "bad window path name \"$w\""
	}

	set class [winfo class $w]
	set wTop [winfo toplevel $w]
	if {$class eq "Tablelist"} {
	    if {[package vcompare $::tablelist::version "6.4"] >= 0} {
		if {$ignoreFocus} {
		    $w configure -xmousewheelwindow "" -ymousewheelwindow ""
		} else {
		    $w configure -xmousewheelwindow $wTop \
				 -ymousewheelwindow $wTop
		}
	    }
	} else {
	    set w2 [expr {$class eq "Ctext" ? "$w.t" : $w}]
	    set tagList [bindtags $w2]
	    foreach tag {WheeleventRedir WheeleventBreak} {
		if {[set idx [lsearch -exact $tagList $tag]] >= 0} {
		    set tagList [lreplace $tagList $idx $idx]
		}
	    }

	    set idx 0
	    foreach tag $tagList {
		if {$tag eq $wTop || $tag eq "all"} {
		    incr idx
		    continue
		}

		if {$winSys ne "x11" || $uniformWheelSupport} {
		    set hasWheelBindings [expr {
			[bind $tag <MouseWheel>] ne "" ||
			[bind $tag <TouchpadScroll>] ne ""}]
		} else {
		    set hasWheelBindings [expr {[bind $tag <Button-4>] ne ""}]
		}
		if {!$hasWheelBindings} {
		    incr idx
		    continue
		}

		if {$ignoreFocus} {
		    bindtags $w2 [lreplace $tagList $idx $idx \
				  $tag WheeleventBreak]
		} else {
		    bindtags $w2 [lreplace $tagList $idx $idx \
				  WheeleventRedir $tag WheeleventBreak]
		}
		break

	    }
	}

	#
	# If $w is embedded into a scrollarea then invoke this
	# procedure for the scrollbars of that scrollarea, too
	#
	if {[set sa [getscrollarea $w]] ne "" && ([info level] == 1 ||
	    [lindex [info level -1] 0] ne
	    "scrollutil::prepareScrollingByWheel")} {
	    if {$ignoreFocus} {
		adaptWheelEventHandling -ignorefocus $sa.hsb $sa.vsb
	    } else {
		adaptWheelEventHandling $sa.hsb $sa.vsb
	    }
	}
    }
}

#------------------------------------------------------------------------------
# scrollutil::prepareScrollingByWheel
#
# Usage: scrollutil::prepareScrollingByWheel ?-ignorefocus?
#	 ?scrlWidgetCont scrlWidgetCont ...?
#
# For each scrollable widget container specified as argument, this command
# passes its descendants located in the same toplevel and having bindings for
# mouse wheel or <TouchpadScroll> events to scrollutil::adaptWheelEventHandling.
#------------------------------------------------------------------------------
proc scrollutil::prepareScrollingByWheel args {
    variable winSys
    if {$winSys eq "win32"} {
	package require Tk 8.6b2-
    }

    set ignoreFocus 0
    set arg0 [lindex $args 0]
    if {[string length $arg0] > 1 && [string first $arg0 "-ignorefocus"] == 0} {
	set ignoreFocus 1
	set args [lrange $args 1 end]
    }

    foreach swc $args {
	if {![winfo exists $swc]} {
	    return -code error "bad window path name \"$swc\""
	}

	if {[catch {$swc xview scroll 0 units}] != 0} {
	    return -code error \
		"widget $swc fails to support horizontal scrolling by units"
	}

	if {[catch {$swc yview scroll 0 units}] != 0} {
	    return -code error \
		"widget $swc fails to support vertical scrolling by units"
	}

	set widgetList {}
	set swcTop [winfo toplevel $swc]

	#
	# Level-order traversal
	#
	set lst1 [winfo children $swc]
	while {[llength $lst1] != 0} {
	    set lst2 {}
	    foreach w $lst1 {
		if {[winfo toplevel $w] eq $swcTop &&
		    ([winfo class $w] eq "Tablelist" ||
		     [hasWheelBindings $w])} {
		    lappend widgetList $w
		}
		foreach child [winfo children $w] {
		    lappend lst2 $child
		}
	    }
	    set lst1 $lst2
	}

	if {$ignoreFocus} {
	    eval adaptWheelEventHandling -ignorefocus $widgetList
	} else {
	    eval adaptWheelEventHandling $widgetList
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
		"widget $w2 is neither an ancestor of nor is identical to $w"
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

#------------------------------------------------------------------------------
# scrollutil::bindMouseWheel
#
# Usage: scrollutil::bindMouseWheel tag command
#
# Our own version of the ttk::bindMouseWheel procedure, which was not present
# in tile before Dec. 2008 and doesn't distinguish between the two axes.  Adds
# basic mouse wheel support to the specified binding tag.
#------------------------------------------------------------------------------
proc scrollutil::bindMouseWheel {tag cmd {tail ""}} {
    variable winSys
    variable uniformWheelSupport

    if {$cmd eq "break" || $cmd eq "continue" || $cmd eq ""} {
	if {$uniformWheelSupport} {
	    bind $tag <MouseWheel>		$cmd
	    bind $tag <Option-MouseWheel>	$cmd
	    bind $tag <Shift-MouseWheel>	$cmd
	    bind $tag <Shift-Option-MouseWheel>	$cmd
	} elseif {$winSys eq "aqua"} {
	    bind $tag <MouseWheel>		$cmd
	    bind $tag <Option-MouseWheel>	$cmd
	    bind $tag <Shift-MouseWheel>	$cmd
	    bind $tag <Shift-Option-MouseWheel>	$cmd
	} else {
	    bind $tag <MouseWheel>		$cmd
	    bind $tag <Shift-MouseWheel>	$cmd

	    if {$winSys eq "x11"} {
		bind $tag <Button-4>		$cmd
		bind $tag <Button-5>		$cmd
		bind $tag <Shift-Button-4>	$cmd
		bind $tag <Shift-Button-5>	$cmd

		if {$::tk_patchLevel eq "8.7a3"} {
		    bind $tag <Button-6>	$cmd
		    bind $tag <Button-7>	$cmd
		}
	    }
	}
    } else {
	if {$uniformWheelSupport} {
	    bind $tag <MouseWheel>		"$cmd y %D -120.0 $tail"
	    bind $tag <Option-MouseWheel>	"$cmd y %D -12.0 $tail"
	    bind $tag <Shift-MouseWheel>	"$cmd x %D -120.0 $tail"
	    bind $tag <Shift-Option-MouseWheel>	"$cmd x %D -12.0 $tail"
	} elseif {$winSys eq "aqua"} {
	    bind $tag <MouseWheel>		"$cmd y \[expr {-%D}\] $tail"
	    bind $tag <Option-MouseWheel>	"$cmd y \[expr {-10*%D}\] $tail"
	    bind $tag <Shift-MouseWheel>	"$cmd x \[expr {-%D}\] $tail"
	    bind $tag <Shift-Option-MouseWheel>	"$cmd x \[expr {-10*%D}\] $tail"
	} else {
	    bind $tag <MouseWheel> \
		"$cmd y \[expr {%D >= 0 ? -%D/120 : (-%D + 119)/120}\] $tail"
	    bind $tag <Shift-MouseWheel> \
		"$cmd x \[expr {%D >= 0 ? -%D/120 : (-%D + 119)/120}\] $tail"

	    if {$winSys eq "x11"} {
		bind $tag <Button-4>		"$cmd y -1 $tail"
		bind $tag <Button-5>		"$cmd y +1 $tail"
		bind $tag <Shift-Button-4>	"$cmd x -1 $tail"
		bind $tag <Shift-Button-5>	"$cmd x +1 $tail"

		if {$::tk_patchLevel eq "8.7a3"} {
		    bind $tag <Button-6>	"$cmd x -1 $tail"
		    bind $tag <Button-7>	"$cmd x +1 $tail"
		}
	    }
	}
    }
}

#
# Private procedures
# ==================
#

#------------------------------------------------------------------------------
# scrollutil::condScrollByUnits
#------------------------------------------------------------------------------
proc scrollutil::condScrollByUnits {w orient amount {divisor 1.0}} {
    if {![info exists ::tk::Priv(xEvents)]} {
	#
	# Count both the <MouseWheel> and <Shift-MouseWheel>
	# events, and ignore the non-dominant ones
	#
	variable xWheelEvents
	variable yWheelEvents
	set axis [expr {[string index $orient 0] eq "h" ? "x" : "y"}]
	incr ${axis}WheelEvents
	if {($xWheelEvents + $yWheelEvents > 10) &&
	    ($axis eq "x" && $xWheelEvents < $yWheelEvents ||
	     $axis eq "y" && $yWheelEvents < $xWheelEvents)} {
	    return ""
	}
    }

    variable uniformWheelSupport
    if {$uniformWheelSupport} {
	tk::ScrollByUnits $w $orient $amount $divisor
    } else {						
	tk::ScrollByUnits $w $orient $amount
    }
}

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
    if {[string match "*Scrollbar" [winfo class $w]] &&
	[string match {<Shift-*>} $event]} {
	return 1
    } else {
	set tagList [bindtags $w]
	set idx [lsearch -exact $tagList "WheeleventRedir"]
	set tag [lindex $tagList [incr idx]]
	if {$tag eq "Btn2EventRedir"} {
	    set tag [lindex $tagList [incr idx]]
	}
	return [expr {[bind $tag $event] ne ""}]
    }
}

#------------------------------------------------------------------------------
# scrollutil::cycleMenuEntry1
#------------------------------------------------------------------------------
proc scrollutil::cycleMenuEntry1 {w axis delta {divisor 1.0}} {
    set menu [$w cget -menu]
    if {$menu eq "" || $axis eq "x"} {
	return ""
    }
 
    set d [expr {$delta/$divisor}]
    set d [expr {int($d > 0 ? ceil($d) : floor($d))}]
    tk::MenuNextEntry $menu $d

    set entryType [$menu type active]
    if {$entryType ne "cascade" && $entryType ne "tearoff"} {
	uplevel #0 [list $menu invoke active]
    }
}

#------------------------------------------------------------------------------
# scrollutil::cycleMenuEntry2
#------------------------------------------------------------------------------
proc scrollutil::cycleMenuEntry2 {w dxdy} {
    set menu [$w cget -menu]
    if {$menu eq ""} {
	return ""
    }

    lassign [tk::PreciseScrollDeltas $dxdy] deltaX deltaY
    if {$deltaY != 0} {
	tk::MenuNextEntry $menu [expr {$deltaY > 0 ? -1 : 1}]

	set entryType [$menu type active]
	if {$entryType ne "cascade" && $entryType ne "tearoff"} {
	    uplevel #0 [list $menu invoke active]
	}
    }
}

#------------------------------------------------------------------------------
# scrollutil::scaleIncrement1
#------------------------------------------------------------------------------
proc scrollutil::scaleIncrement1 {w axis delta {divisor 1.0}} {
    #
    # Count both the <MouseWheel> and <Shift-MouseWheel>
    # events, and ignore the non-dominant ones
    #
    variable ::scrollutil::xWheelEvents
    variable ::scrollutil::yWheelEvents
    incr ${axis}WheelEvents
    if {($xWheelEvents + $yWheelEvents > 10) &&
	($axis eq "x" && $xWheelEvents < $yWheelEvents ||
	 $axis eq "y" && $yWheelEvents < $xWheelEvents)} {
	return ""
    }

    set d [expr {$delta/$divisor}]
    set dir [expr {$d < 0 ? "up" : "down"}]
    set size [expr {abs($d) < 10 ? "little" : "big"}]
    tk::ScaleIncrement $w $dir $size noRepeat
}

#------------------------------------------------------------------------------
# scrollutil::ttkScaleIncrement1
#------------------------------------------------------------------------------
proc scrollutil::ttkScaleIncrement1 {w axis delta {divisor 1.0}} {
    #
    # Count both the <MouseWheel> and <Shift-MouseWheel>
    # events, and ignore the non-dominant ones
    #
    variable ::scrollutil::xWheelEvents
    variable ::scrollutil::yWheelEvents
    incr ${axis}WheelEvents
    if {($xWheelEvents + $yWheelEvents > 10) &&
	($axis eq "x" && $xWheelEvents < $yWheelEvents ||
	 $axis eq "y" && $yWheelEvents < $xWheelEvents)} {
	return ""
    }

    set d [expr {$delta/$divisor}]
    set d [expr {int($d > 0 ? ceil($d) : floor($d))}]
    ttk::scale::Increment $w $d
}

#------------------------------------------------------------------------------
# scrollutil::scaleIncrement2
#------------------------------------------------------------------------------
proc scrollutil::scaleIncrement2 {w dxdy} {
    set orient [$w cget -orient]
    lassign [tk::PreciseScrollDeltas $dxdy] deltaX deltaY

    if {$orient eq "horizontal" && $deltaX != 0} {
	set dir [expr {$deltaX > 0 ? "up" : "down"}]
	tk::ScaleIncrement $w $dir little noRepeat
    } elseif {$orient eq "vertical" && $deltaY != 0} {
	set dir [expr {$deltaY > 0 ? "up" : "down"}]
	tk::ScaleIncrement $w $dir little noRepeat
    }
}

#------------------------------------------------------------------------------
# scrollutil::ttkScaleIncrement2
#------------------------------------------------------------------------------
proc scrollutil::ttkScaleIncrement2 {w dxdy} {
    set orient [$w cget -orient]
    lassign [tk::PreciseScrollDeltas $dxdy] deltaX deltaY

    if {$orient eq "horizontal" && $deltaX != 0} {
	ttk::scale::Increment $w [expr {$deltaX > 0 ? -1 : 1}]
    } elseif {$orient eq "vertical" && $deltaY != 0} {
	ttk::scale::Increment $w [expr {$deltaY > 0 ? -1 : 1}]
    }
}

#------------------------------------------------------------------------------
# scrollutil::comparePaths
#------------------------------------------------------------------------------
proc scrollutil::comparePaths {w1 w2} {
    if {[string first $w2. $w1] == 0} {		;# $w1 is a descendant of $w2
	return -1
    } elseif {[string first $w1. $w2] == 0} {	;# $w2 is a descendant of $w1
	return 1
    } else {
	return 0
    }
}

#------------------------------------------------------------------------------
# scrollutil::scrollByUnits
#------------------------------------------------------------------------------
proc scrollutil::scrollByUnits {w rootX rootY axis delta divisor} {
    if {[hasWheelBindings $w]} {
	return ""
    }

    set w [winfo containing -displayof $w $rootX $rootY]
    variable scrlWidgetContList
    foreach swc $scrlWidgetContList {
	if {[mayScroll $swc $w]} {
	    set number [expr {$delta/$divisor}]
	    set number \
		[expr {int($number > 0 ? ceil($number) : floor($number))}]
	    $swc ${axis}view scroll $number units
	    return -code break ""
	}
    }
}

#------------------------------------------------------------------------------
# scrollutil::hasWheelBindings
#------------------------------------------------------------------------------
proc scrollutil::hasWheelBindings w {
    variable winSys
    variable uniformWheelSupport

    set wTop [winfo toplevel $w]
    foreach tag [bindtags $w] {
	if {$tag eq $wTop || $tag eq "all"} {
	    continue
	}

	if {$winSys ne "x11" || $uniformWheelSupport} {
	    if {[bind $tag <MouseWheel>] ne "" ||
		[bind $tag <TouchpadScroll>] ne ""} {
		return 1
	    }
	} else {
	    if {[bind $tag <Button-4>] ne ""} {
		return 1
	    }
	}
    }

    return 0
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
    # Don't scroll the widget $swc if the toplevel window of any
    # combobox widget contained in it is currently popped down
    #
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
