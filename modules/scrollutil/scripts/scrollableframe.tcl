#==============================================================================
# Contains the implementation of the scrollableframe widget.
#
# Structure of the module:
#   - Namespace initialization
#   - Private procedure creating the default bindings
#   - Public procedure creating a new scrollableframe widget
#   - Private configuration procedures
#   - Private procedures implementing the scrollableframe widget command
#   - Private procedures used in bindings
#
# Copyright (c) 2019  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

#
# Namespace initialization
# ========================
#

namespace eval scrollutil::sf {
    #
    # The array configSpecs is used to handle configuration options.  The names
    # of its elements are the configuration options for the Scrollableframe
    # class.  The value of an array element is either an alias name or a list
    # containing the database name and class as well as an indicator specifying
    # the widget to which the option applies: f stands for the outer frame and
    # w for the scrollableframe widget itself.
    #
    #	Command-Line Name	 {Database Name		  Database Class     W}
    #	-----------------------------------------------------------------------
    #
    variable configSpecs
    array set configSpecs {
	-background		{background		Background	     f}
	-bg			-background
	-borderwidth		{borderWidth		BorderWidth	     f}
	-bd			-borderwidth
	-cursor			{cursor			Cursor		     f}
	-contentheight		{contentHeight		ContentHeight	     w}
	-contentwidth		{contentWidth		ContentWidth	     w}
	-fitcontentheight	{fitContentHeight	FitContentHeight     w}
	-fitcontentwidth	{fitContentWidth	FitContentWidth      w}
	-height			{height			Height		     f}
	-highlightbackground	{highlightBackground	HighlightBackground  f}
	-highlightcolor		{highlightColor		HighlightColor	     f}
	-highlightthickness	{highlightThickness	HighlightThickness   f}
	-relief			{relief			Relief		     f}
	-takefocus		{takeFocus		TakeFocus	     f}
	-width			{width			Width		     f}
	-xscrollcommand		{xScrollCommand		ScrollCommand	     w}
	-xscrollincrement	{xScrollIncrement	ScrollIncrement	     w}
	-yscrollcommand		{yScrollCommand		ScrollCommand	     w}
	-yscrollincrement	{yScrollIncrement	ScrollIncrement	     w}
    }

    #
    # Extend the elements of the array configSpecs
    #
    proc extendConfigSpecs {} {
	variable ::scrollutil::usingTile
	variable configSpecs

	if {$usingTile} {
	    foreach opt {-background -bg -highlightbackground -highlightcolor
			 -highlightthickness} {
		unset configSpecs($opt)
	    }
	} else {
	    set helpFrm .__helpFrm
	    for {set n 2} {[winfo exists $helpFrm]} {incr n} {
		set helpFrm .__helpFrm$n
	    }
	    tk::frame $helpFrm
	    foreach opt {-background -highlightbackground -highlightcolor
			 -highlightthickness} {
		set configSet [$helpFrm configure $opt]
		lappend configSpecs($opt) [lindex $configSet 3]
	    }
	    destroy $helpFrm
	}

	lappend configSpecs(-borderwidth) 0
	lappend configSpecs(-cursor) ""
	lappend configSpecs(-contentheight) 0
	lappend configSpecs(-contentwidth) 0
	lappend configSpecs(-fitcontentheight) 0
	lappend configSpecs(-fitcontentwidth) 0
	lappend configSpecs(-height) 100
	lappend configSpecs(-relief) flat
	lappend configSpecs(-takefocus) 0
	lappend configSpecs(-width) 100
	lappend configSpecs(-xscrollcommand) ""
	lappend configSpecs(-xscrollincrement) 0
	lappend configSpecs(-yscrollcommand) ""
	lappend configSpecs(-yscrollincrement) 0
    }
    extendConfigSpecs 

    variable configOpts [lsort [array names configSpecs]]

    #
    # Use lists to facilitate the handling of
    # the command options and corner values
    #
    variable cmdOpts [list cget configure contentframe see xview yview]
    variable corners [list nw ne sw se]
}

#
# Private procedure creating the default bindings
# ===============================================
#

#------------------------------------------------------------------------------
# scrollutil::sf::createBindings
#
# Creates the default bindings for the binding tags Scrollableframe and
# ScrollableContent.
#------------------------------------------------------------------------------
proc scrollutil::sf::createBindings {} {
    bind Scrollableframe <KeyPress> continue
    bind Scrollableframe <FocusIn> {
        if {[string compare [focus -lastfor %W] %W] == 0} {
            focus [%W contentframe]
        }
    }
    bind Scrollableframe <Configure> {
	scrollutil::sf::onScrollableframeConfigure %W %w %h
    }
    bind Scrollableframe <Map> {
	scrollutil::sf::updateHorizPlaceOpts %W
	scrollutil::sf::updateVertPlaceOpts  %W
    }
    bind Scrollableframe <Destroy> {
	namespace delete scrollutil::ns%W
	catch {rename %W ""}
    }

    bind ScrollableContent <Configure> {
	scrollutil::sf::onScrollableContentConfigure %W %w %h
    }
}

#
# Public procedure creating a new scrollableframe widget
# ======================================================
#

#------------------------------------------------------------------------------
# scrollutil::scrollableframe
#
# Creates a new scrollableframe widget whose name is specified as the first
# command-line argument, and configures it according to the options and their
# values given on the command line.  Returns the name of the newly created
# widget.
#------------------------------------------------------------------------------
proc scrollutil::scrollableframe args {
    variable usingTile
    variable sf::configSpecs
    variable sf::configOpts

    if {[llength $args] == 0} {
	mwutil::wrongNumArgs "scrollableframe pathName ?options?"
    }

    #
    # Create a frame of the class Scrollableframe
    #
    set win [lindex $args 0]
    if {[catch {
	if {$usingTile} {
	    ttk::frame $win -class Scrollableframe -padding 0
	} else {
	    tk::frame $win -class Scrollableframe -container 0
	    catch {$win configure -padx 0 -pady 0}
	}
    } result] != 0} {
	return -code error $result
    }

    #
    # Create a namespace within the current one to hold the data of the widget
    #
    namespace eval ns$win {
	#
	# The folowing array holds various data for this widget
	#
	variable data
	array set data {
	    xOffset	0
	    contWidth	0
	    winWidth	0
	    yOffset	0
	    contHeight	0
	    winHeight	0
	}
    }

    #
    # Initialize some further components of data
    #
    upvar ::scrollutil::ns${win}::data data
    foreach opt $configOpts {
	set data($opt) [lindex $configSpecs($opt) 3]
    }
    set data(content) $win.content

    #
    # Create the content frame of the class ScrollableContent
    #
    set cf $data(content)
    if {$usingTile} {
	ttk::frame $cf -class ScrollableContent -borderwidth 0 -height 0 \
		       -padding 0 -relief flat -takefocus 0 -width 0
    } else {
	tk::frame $cf -class ScrollableContent -borderwidth 0 -container 0 \
		      -height 0 -highlightthickness 0 -relief flat \
		      -takefocus 0 -width 0
	catch {$w configure -padx 0 -pady 0}
    }
    place $cf -x 0 -y 0

    #
    # Configure the widget according to the command-line
    # arguments and to the available database options
    #
    if {[catch {
	mwutil::configureWidget $win configSpecs scrollutil::sf::doConfig \
				scrollutil::sf::doCget [lrange $args 1 end] 1
    } result] != 0} {
	destroy $win
	return -code error $result
    }

    #
    # Move the original widget command into the namespace sf within the current
    # one and create an alias of the original name for a new widget procedure
    #
    rename ::$win sf::$win
    interp alias {} ::$win {} scrollutil::sf::scrollableframeWidgetCmd $win

    return $win
}

#
# Private configuration procedures
# ================================
#

#------------------------------------------------------------------------------
# scrollutil::sf::doConfig
#
# Applies the value val of the configuration option opt to the scrollableframe
# widget win.
#------------------------------------------------------------------------------
proc scrollutil::sf::doConfig {win opt val} {
    variable configSpecs
    upvar ::scrollutil::ns${win}::data data

    #
    # Apply the value to the widget corresponding to the given option
    #
    switch [lindex $configSpecs($opt) 2] {
	f {
	    #
	    # Apply the value to the outer frame and save the
	    # properly formatted value of val in data($opt)
	    #
	    $win configure $opt $val
	    set data($opt) [$win cget $opt]

	    switch -- $opt {
		-background -
		-cursor {
		    $data(content) configure $opt $val
		}
	    }
	}

	w {
	    switch -- $opt {
		-contentheight {
		    set data($opt) [winfo pixels $win $val]
		    updateVertPlaceOpts $win
		}
		-contentwidth {
		    set data($opt) [winfo pixels $win $val]
		    updateHorizPlaceOpts $win
		}
		-fitcontentheight {
		    set data($opt) [expr {$val ? 1 : 0}]
		    updateVertPlaceOpts $win
		}
		-fitcontentwidth {
		    set data($opt) [expr {$val ? 1 : 0}]
		    updateHorizPlaceOpts $win
		}
		-xscrollcommand -
		-yscrollcommand {
		    set data($opt) $val
		}
		-xscrollincrement -
		-yscrollincrement {
		    set data($opt) [winfo pixels $win $val]
		}
	    }
	}
    }
}

#------------------------------------------------------------------------------
# scrollutil::sf::doCget
#
# Returns the value of the configuration option opt for the scrollableframe
# widget win.
#------------------------------------------------------------------------------
proc scrollutil::sf::doCget {win opt} {
    upvar ::scrollutil::ns${win}::data data
    return $data($opt)
}

#------------------------------------------------------------------------------
# scrollutil::sf::updateHorizPlaceOpts
#------------------------------------------------------------------------------
proc scrollutil::sf::updateHorizPlaceOpts win {
    upvar ::scrollutil::ns${win}::data data
    set cf $data(content)

    if {$data(-fitcontentwidth)} {
	#
	# For an improved user experience delay the use
	# of "-relwidth 1" until the widget gets mapped
	#
	if {[winfo ismapped $win]} {
	    place configure $cf -relwidth 1  -width ""
	} else {
	    place configure $cf -relwidth "" -width ""
	}
    } elseif {$data(-contentwidth) > 0} {
	place configure $cf -relwidth "" -width $data(-contentwidth)
    } else {
	place configure $cf -relwidth "" -width ""
    }
}

#------------------------------------------------------------------------------
# scrollutil::sf::updateVertPlaceOpts
#------------------------------------------------------------------------------
proc scrollutil::sf::updateVertPlaceOpts win {
    upvar ::scrollutil::ns${win}::data data
    set cf $data(content)

    if {$data(-fitcontentheight)} {
	#
	# For an improved user experience delay the use
	# of "-relheight 1" until the widget gets mapped
	#
	if {[winfo ismapped $win]} {
	    place configure $cf -relheight 1  -height ""
	} else {
	    place configure $cf -relheight "" -height ""
	} 
    } elseif {$data(-contentheight) > 0} {
	place configure $cf -relheight "" -height $data(-contentheight)
    } else {
	place configure $cf -relheight "" -height ""
    }
}

#
# Private procedures implementing the scrollableframe widget command
# ==================================================================
#

#------------------------------------------------------------------------------
# scrollutil::sf::scrollableframeWidgetCmd
#
# Processes the Tcl command corresponding to a scrollableframe widget.
#------------------------------------------------------------------------------
proc scrollutil::sf::scrollableframeWidgetCmd {win args} {
    set argCount [llength $args]
    if {$argCount == 0} {
	mwutil::wrongNumArgs "$win option ?arg arg ...?"
    }

    variable cmdOpts
    set cmd [mwutil::fullOpt "option" [lindex $args 0] $cmdOpts]
    switch $cmd {
	cget {
	    if {$argCount != 2} {
		mwutil::wrongNumArgs "$win $cmd option"
	    }

	    #
	    # Return the value of the specified configuration option
	    #
	    upvar ::scrollutil::ns${win}::data data
	    variable configSpecs
	    set opt [mwutil::fullConfigOpt [lindex $args 1] configSpecs]
	    return $data($opt)
	}

	configure {
	    variable configSpecs
	    return [mwutil::configureSubCmd $win configSpecs \
		    scrollutil::sf::doConfig scrollutil::sf::doCget \
		    [lrange $args 1 end]]
	}

	contentframe {
	    if {$argCount != 1} {
		mwutil::wrongNumArgs "$win $cmd"
	    }

	    upvar ::scrollutil::ns${win}::data data
	    return $data(content)
	}

	see   { return [seeSubCmd $win [lrange $args 1 end]] }

	xview { return [xviewSubCmd $win [lrange $args 1 end]] }

	yview { return [yviewSubCmd $win [lrange $args 1 end]] }
    }
}

#------------------------------------------------------------------------------
# scrollutil::sf::seeSubCmd
#
# Processes the scrollableframe see subcommmand.
#------------------------------------------------------------------------------
proc scrollutil::sf::seeSubCmd {win argList} {
    set argCount [llength $argList]
    if {$argCount < 1 || $argCount > 2} {
	mwutil::wrongNumArgs "$win see widget ?nw|ne|sw|se?
    }

    set w [lindex $argList 0]
    if {![winfo exists $w]} {
	return -code error "bad window path name \"$w\""
    }

    upvar ::scrollutil::ns${win}::data data
    set cf $data(content)
    if {[string first $cf. $w] != 0} {
	return -code error \
	    "widget \"$w\" is not a descendant of the content frame of \"$win\""
    }
    if {[string compare [winfo toplevel $w] [winfo toplevel $win]] != 0} {
	return -code error \
	    "widgets \"$w\" and \"$win\" have different toplevels"
    }
    if {[string length [winfo manager $w]] == 0} {
	return -code error \
	    "widget \"$w\" is not managed by any geometry manager"
    }

    #
    # Parse the optional argument
    #
    if {$argCount == 1} {
	set xSide w
	set ySide n
    } else {
	variable corners
	set corner [mwutil::fullOpt "corner" [lindex $argList 1] $corners]
	set xSide [string range $corner 1 1]
	set ySide [string range $corner 0 0]
    }

    #
    # Get the coordinates of the top-left and
    # bottom-right corners of w relative to cf
    #
    set wx1 [expr {[winfo rootx $w] - [winfo rootx $cf]}]
    set wy1 [expr {[winfo rooty $w] - [winfo rooty $cf]}]
    set wx2 [expr {$wx1 + [winfo width  $w]}]
    set wy2 [expr {$wy1 + [winfo height $w]}]

    set xOffset   $data(xOffset)
    set winWidth  $data(winWidth)
    set xScrlIncr $data(-xscrollincrement)
    set yOffset   $data(yOffset)
    set winHeight $data(winHeight)
    set yScrlIncr $data(-yscrollincrement)

    #
    # Get the coordinates of the top-left and
    # bottom-right corners of win relative to cf
    #
    set winx1 $xOffset
    set winy1 $yOffset
    set winx2 [expr {$winx1 + $winWidth}]
    set winy2 [expr {$winy1 + $winHeight}]

    #
    # Make the left or right part of w visible in the window
    #
    switch $xSide {
	w {
	    if {$wx2 > $winx2} {
		incr winx1 [expr {$wx2 - $winx2}]
		roundUp winx1 $xScrlIncr
	    }
	    if {$wx1 < $winx1} {
		incr winx1 [expr {$wx1 - $winx1}]
		roundDn winx1 $xScrlIncr
	    }
	}
	e {
	    if {$wx1 < $winx1} {
		incr winx1 [expr {$wx1 - $winx1}]
		roundDn winx1 $xScrlIncr
		set winx2 [expr {$winx1 + $winWidth}]
	    }
	    if {$wx2 > $winx2} {
		incr winx1 [expr {$wx2 - $winx2}]
		roundUp winx1 $xScrlIncr
	    }
	}
    }
    applyOffset $win x $winx1 0

    #
    # Make the top or bottom part of w visible in the window
    #
    switch $ySide {
	n {
	    if {$wy2 > $winy2} {
		incr winy1 [expr {$wy2 - $winy2}]
		roundUp winy1 $yScrlIncr
	    }
	    if {$wy1 < $winy1} {
		incr winy1 [expr {$wy1 - $winy1}]
		roundDn winy1 $yScrlIncr
	    }
	}
	s {
	    if {$wy1 < $winy1} {
		incr winy1 [expr {$wy1 - $winy1}]
		roundDn winy1 $yScrlIncr
		set winy2 [expr {$winy1 + $winHeight}]
	    }
	    if {$wy2 > $winy2} {
		incr winy1 [expr {$wy2 - $winy2}]
		roundUp winy1 $yScrlIncr
	    }
	}
    }
    applyOffset $win y $winy1 0

    return ""
}

#------------------------------------------------------------------------------
# scrollutil::sf::xviewSubCmd
#
# Processes the scrollableframe xview subcommmand.
#------------------------------------------------------------------------------
proc scrollutil::sf::xviewSubCmd {win argList} {
    upvar ::scrollutil::ns${win}::data data
    set xOffset   $data(xOffset)
    set contWidth $data(contWidth)
    set winWidth  $data(winWidth)

    switch [llength $argList] {
	0 {
	    #
	    # Command: $win xview
	    #
	    if {$contWidth == 0} {
		return [list 0 1]
	    }
	    set first [expr {double($xOffset) / $contWidth}]
	    set last  [expr {double($xOffset + $winWidth) / $contWidth}]
	    if {$last > 1.0} {
		set last 1.0
	    }
	    return [list $first $last]
	}

	default {
	    #
	    # Command: $win xview moveto <fraction>
	    #	       $win xview scroll <number> units|pages
	    #
	    set argList [mwutil::getScrollInfo2 "$win xview" $argList]
	    if {[string compare [lindex $argList 0] "moveto"] == 0} {
		set number ""
		set fraction [lindex $argList 1]
		set xOffset [expr {int($fraction * $contWidth + 0.5)}]
	    } else {
		set number [lindex $argList 1]
		if {[string compare [lindex $argList 2] "units"] == 0} {
		    set xScrlIncr $data(-xscrollincrement)
		    if {$xScrlIncr > 0} {
			set xOffset [expr {$xOffset + $number * $xScrlIncr}]
		    } else {
			set xOffset \
			    [expr {int($xOffset + $number * 0.1 * $winWidth)}]
		    }
		} else {
		    set xOffset \
			[expr {int($xOffset + $number * 0.9 * $winWidth)}]
		}
	    }
	    applyOffset $win x $xOffset [expr {$number == 0}]
	    return ""
	}
    }
}

#------------------------------------------------------------------------------
# scrollutil::sf::yviewSubCmd
#
# Processes the scrollableframe yview subcommmand.
#------------------------------------------------------------------------------
proc scrollutil::sf::yviewSubCmd {win argList} {
    upvar ::scrollutil::ns${win}::data data
    set yOffset    $data(yOffset)
    set contHeight $data(contHeight)
    set winHeight  $data(winHeight)

    switch [llength $argList] {
	0 {
	    #
	    # Command: $win yview
	    #
	    if {$contHeight == 0} {
		return [list 0 1]
	    }
	    set first [expr {double($yOffset) / $contHeight}]
	    set last  [expr {double($yOffset + $winHeight) / $contHeight}]
	    if {$last > 1.0} {
		set last 1.0
	    }
	    return [list $first $last]
	}

	default {
	    #
	    # Command: $win yview moveto <fraction>
	    #	       $win yview scroll <number> units|pages
	    #
	    set argList [mwutil::getScrollInfo2 "$win yview" $argList]
	    if {[string compare [lindex $argList 0] "moveto"] == 0} {
		set number ""
		set fraction [lindex $argList 1]
		set yOffset [expr {int($fraction * $contHeight + 0.5)}]
	    } else {
		set number [lindex $argList 1]
		if {[string compare [lindex $argList 2] "units"] == 0} {
		    set yScrlIncr $data(-yscrollincrement)
		    if {$yScrlIncr > 0} {
			set yOffset [expr {$yOffset + $number * $yScrlIncr}]
		    } else {
			set yOffset \
			    [expr {int($yOffset + $number * 0.1 * $winHeight)}]
		    }
		} else {
		    set yOffset \
			[expr {int($yOffset + $number * 0.9 * $winHeight)}]
		}
	    }
	    applyOffset $win y $yOffset [expr {$number == 0}]
	    return ""
	}
    }
}

#------------------------------------------------------------------------------
# scrollutil::sf::roundUp
#------------------------------------------------------------------------------
proc scrollutil::sf::roundUp {pixelsName scrlIncr} {
    upvar $pixelsName pixels
    if {$pixels < 0} {
	set pixels 0
    } elseif {$scrlIncr > 0} {
	set remainder [expr {$pixels % $scrlIncr}]
	if {$remainder != 0} {
	    incr pixels [expr {$scrlIncr - $remainder}]
	}
    }
}

#------------------------------------------------------------------------------
# scrollutil::sf::roundDn
#------------------------------------------------------------------------------
proc scrollutil::sf::roundDn {pixelsName scrlIncr} {
    upvar $pixelsName pixels
    if {$pixels < 0} {
	set pixels 0
    } elseif {$scrlIncr > 0} {
	incr pixels [expr {-($pixels % $scrlIncr)}]
    }
}

#------------------------------------------------------------------------------
# scrollutil::sf::roundUpOrDn
#------------------------------------------------------------------------------
proc scrollutil::sf::roundUpOrDn {pixelsName scrlIncr} {
    upvar $pixelsName pixels
    if {$pixels < 0} {
	set pixels 0
    } elseif {$scrlIncr > 0} {
	incr pixels [expr {$scrlIncr / 2}]
	incr pixels [expr {-($pixels % $scrlIncr)}]
    }
}

#------------------------------------------------------------------------------
# scrollutil::sf::applyOffset
#------------------------------------------------------------------------------
proc scrollutil::sf::applyOffset {win axis offset force} {
    upvar ::scrollutil::ns${win}::data data
    set scrlIncr $data(-${axis}scrollincrement)

    #
    # Round the offset up or down to the nearest
    # multiple of scrlIncr if the latter is > 0
    #
    roundUpOrDn offset $scrlIncr

    #
    # Adjust the offset if necessary
    #
    switch $axis {
	x { set maxOffset [expr {$data(contWidth)  - $data(winWidth)}] }
	y { set maxOffset [expr {$data(contHeight) - $data(winHeight)}] }
    }
    if {$maxOffset < 0} {
	set offset 0
    } elseif {$offset > $maxOffset} {
	set offset $maxOffset
	roundUp offset $scrlIncr
    }

    if {$offset != $data(${axis}Offset) || $force} {
	#
	# Save the offset, update the -(x|y) place option, and invoke the
	# command specified as the value of the -(x|y)scrollcommand opton
	#
	set data(${axis}Offset) $offset
	place configure $data(content) -$axis -$offset
	if {[string length $data(-${axis}scrollcommand)] != 0} {
	    eval $data(-${axis}scrollcommand) [${axis}viewSubCmd $win {}]
	}
    }
}

#
# Private procedures used in bindings
# ===================================
#

#------------------------------------------------------------------------------
# scrollutil::sf::onScrollableframeConfigure
#------------------------------------------------------------------------------
proc scrollutil::sf::onScrollableframeConfigure {win width height} {
    if {![array exists ::scrollutil::ns${win}::data]} {
	return ""
    }

    upvar ::scrollutil::ns${win}::data data
    if {$width != $data(winWidth)} {
	set data(winWidth) $width
	if {$data(-fitcontentwidth)} {
	    set data(contWidth) $width
	}
	xviewSubCmd $win {scroll 0 units}
    }
    if {$height != $data(winHeight)} {
	set data(winHeight) $height
	if {$data(-fitcontentheight)} {
	    set data(contHeight) $height
	}
	yviewSubCmd $win {scroll 0 units}
    }
}

#------------------------------------------------------------------------------
# scrollutil::sf::onScrollableContentConfigure
#------------------------------------------------------------------------------
proc scrollutil::sf::onScrollableContentConfigure {cont width height} {
    set win [winfo parent $cont]
    if {![array exists ::scrollutil::ns${win}::data]} {
	return ""
    }

    upvar ::scrollutil::ns${win}::data data
    if {$width != $data(contWidth)} {
	set data(contWidth) $width
	xviewSubCmd $win {scroll 0 units}
    }
    if {$height != $data(contHeight)} {
	set data(contHeight) $height
	yviewSubCmd $win {scroll 0 units}
    }
}
