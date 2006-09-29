# -*- tcl -*-
#
#  statusbar.tcl -
#	Create a status bar Tk widget
#
# RCS: @(#) $Id: statusbar.tcl,v 1.6 2006/09/29 16:25:07 hobbs Exp $
#

# Creation and Options - widget::scrolledwindow $path ...
#
#  -separator -default 1 ; show horizontal separator on top of statusbar
#  -resize    -default 1 ; show resize control on bottom right
#  -resizeseparator -default 1 ; show separator for resize control
#  ## Padding can be a list of {padx pady}
#  -ipad -default 1 ; provides padding around each status bar item
#  -pad  -default 0 ; provides general padding around the status bar
#
#  All other options to frame
#
# Methods
#  $path getframe           => $frame
#  $path add $widget ?args? => $widget
#  All other methods to frame
#
# Bindings
#  NONE
#
#  Provides a status bar to be placed at the bottom of a toplevel.
#  Currently does not support being placed in a toplevel that has
#  gridding applied (via widget -setgrid or wm grid).
#
#  Ensure that the widget is placed at the very bottom of the toplevel,
#  otherwise the resize behavior may behave oddly.
#

package require widget
package require tile

if {0} {
    proc sample {} {
    # sample usage
    eval destroy [winfo children .]
    pack [text .t -width 0 -height 0] -fill both -expand 1

    set sbar .s
    widget::statusbar $sbar
    pack $sbar -side bottom -fill x
    set f [$sbar getframe]

    # Specify -width 1 for the label widget so it truncates nicely
    # instead of requesting large sizes for long messages
    set w [label $f.status -width 1 -anchor w -textvariable ::STATUS]
    set ::STATUS "This is a status message"
    # give the entry weight, as we want it to be the one that expands
    $sbar add $w -weight 1

    # BWidget's progressbar
    set w [ProgressBar $f.bpbar -orient horizontal \
	       -variable ::PROGRESS -bd 1 -relief sunken]
    set ::PROGRESS 50
    $sbar add $w
    }
}

namespace eval ::widget {
    variable HaveSizegrip [llength [info commands ::ttk::sizegrip]]
    if {!$HaveSizegrip} {
	variable HaveMarlett \
	    [expr {[lsearch -exact [font families] "Marlett"] != -1}]

	# PNG version has partial alpha transparency for better look
	variable resizer_pngdata {
	    iVBORw0KGgoAAAANSUhEUgAAAA8AAAAPCAYAAAFM0aXcAAAABGdBTUEAAYagM
	    eiWXwAAAGJJREFUGJW9kVEOgCAMQzs8GEezN69fkKlbUAz2r3l5NGTA+pCU+Q
	    IA5sv39wGgZKClZGBhJMVTklRr3VNwMz04mVfQzQiEm79EkrYZycxIkq8kkv2
	    v6RFGku9TUrj8RGr9AGy6mhv2ymLwAAAAAElFTkSuQmCC
	}
	variable resizer_gifdata {
	    R0lGODlhDwAPAJEAANnZ2f///4CAgD8/PyH5BAEAAAAALAAAAAAPAA8AAAJEh
	    I+py+1IQvh4IZlG0Qg+QshkAokGQfAvZCBIhG8hA0Ea4UPIQJBG+BAyEKQhCH
	    bIQAgNEQCAIA0hAyE0AEIGgjSEDBQAOw==
	}
	if {[package provide img::png] != ""} {
	    set resizer_gifdata {}
	    image create photo ::widget::img_resizer \
		-format PNG -data $resizer_pngdata
	} else {
	    image create photo ::widget::img_resizer \
		-format GIF -data $resizer_gifdata
	}
    }
}

snit::widget widget::statusbar {
    hulltype ttk::frame

    component resizer
    component separator
    component sepresize
    component frame

    # -background, -borderwidth and -relief apply to outer frame, but relief
    # should be left flat for proper look
    delegate option * to hull
    delegate method * to hull
    #delegate option -padding to frame

    option -separator -default 1 \
	-configuremethod C-separator -validatemethod isa
    option -resize -default 1 \
	-configuremethod C-resize -validatemethod isa
    option -resizeseparator -default 1 \
	-configuremethod C-resize -validatemethod isa
    # -pad provides general padding around the status bar
    # -ipad provides padding around each status bar item
    # Padding can be a list of {padx pady}
    option -ipad -default 2 -configuremethod C-ipad -validatemethod isa
    option -pad  -default 0 -configuremethod C-pad -validatemethod isa

    variable ITEMS -array {}
    variable resize -array {}

    constructor args {
	$hull configure -height 18

	install frame using ttk::frame $win.frame

	if {$::widget::HaveSizegrip} {
	    # As of tile 0.7.7
	    install resizer using ttk::sizegrip $win.resizer
	} else {
	    if {$::tcl_platform(platform) eq "windows"} {
		set cursor size_nw_se
	    } else {
		set cursor sizing; # bottom_right_corner ??
	    }
	    install resizer using ttk::label $win.resizer \
		-borderwidth 0 -relief flat \
		-anchor se -cursor $cursor -padding 0
	    if {$::widget::HaveMarlett} {
		$resizer configure -font "Marlett -16" -text \u006f
	    } else {
		$resizer configure -image ::widget::img_resizer
	    }

	    bind $resizer <1>		[mymethod begin_resize %W %X %Y]
	    bind $resizer <B1-Motion>	[mymethod continue_resize %W %X %Y]
	    bind $resizer <ButtonRelease-1>	[mymethod end_resize %W %X %Y]

	    if {$::widget::resizer_gifdata ne ""
		&& [package provide img::png] ne ""} {
		# Try to instantiate this as PNG after first source
		set resizer_gifdata ""
		::widget::img_resizer configure \
		    -format PNG -data $::widget::pngdata
	    }
	}

	install separator using ttk::separator $win.separator \
	    -orient horizontal

	install sepresize using ttk::separator $win.sepresize \
	    -orient vertical

	grid $separator -row 0 -column 0 -columnspan 3 -sticky ew
	grid $frame     -row 1 -column 0 -sticky news
	grid $sepresize -row 1 -column 1 -sticky ns;# -padx $ipadx -pady $ipady
	grid $resizer   -row 1 -column 2 -sticky se
	grid columnconfigure $win 0 -weight 1

	$self configurelist $args
    }

    method isa {option value} {
	set cmd widget::isa
	switch -exact -- $option {
	    -separator - -resize - -resizeseparator {
		return [uplevel 1 [list $cmd boolean $option $value]]
	    }
	    -ipad - -pad {
		return [uplevel 1 [list $cmd listofint 4 $option $value]]
	    }
	}
    }

    method C-ipad {option value} {
	set options($option) $value
	# returns pad values - each will be a list of 2 ints
	foreach {px py} [$self _padval $value] { break }
	foreach w [grid slaves $frame] {
	    if {[string match _sep* $w]} {
		grid configure $w -padx $px -pady 0
	    } else {
		grid configure $w -padx $px -pady $py
	    }
	}
    }

    method C-pad {option value} {
	set options($option) $value
	# we can pass this directly to the frame
	$frame configure -padding $value
    }

    method C-separator {option value} {
	set options($option) $value
	if {$value} {
	    grid $separator
	} else {
	    grid remove $separator
	}
    }

    method C-resize {option value} {
	set options($option) $value
	if {$options(-resize)} {
	    if {$options(-resizeseparator)} {
		grid $sepresize
	    }
	    grid $resizer
	} else {
	    grid remove $sepresize $resizer
	}
    }

    # Use this or 'add' - but not both
    method getframe {} { return $win.frame }

    method add {w args} {
	array set opts [list \
			    -weight    0 \
			    -separator 0 \
			    -sticky    news \
			    -pad       $options(-ipad) \
			   ]
	foreach {key val} $args {
	    if {[info exists opts($key)]} {
		set opts($key) $val
	    } else {
		set msg "unknown option \"$key\", must be one of: "
		append msg [join [lsort [array names opts]] {, }]
		return -code error $msg
	    }
	}
	$self isa -pad $opts(-pad)
	# returns pad values - each will be a list of 2 ints
	foreach {px py} [$self _padval $opts(-pad)] { break }

	# Add defined item and append to ordered list
	set ITEMS($w) {}
	lappend ITEMS() $w

	# get cols,rows extent
	foreach {cols rows} [grid size $frame] break
	# Add separator if requested, and we aren't the first element
	if {$opts(-separator) && $cols != 0} {
	    set sep [ttk::separator $frame._sep[winfo name $w] \
			 -orient vertical]
	    # Make the separator entry known
	    set ITEMS($w) $sep
	    # No pady for separators, and adjust padx for separator space
	    set sx $px
	    if {[lindex $sx 0] < 2} { lset sx 0 2 }
	    lset px 1 0
	    grid $sep -row 0 -column $cols -sticky ns -padx $sx -pady 0
	    incr cols
	}

	grid $w -in $frame -row 0 -column $cols -sticky $opts(-sticky) \
	    -padx $px -pady $py
	grid columnconfigure $frame $cols -weight $opts(-weight)

	return $w
    }

    method remove {args} {
	set destroy [string equal [lindex $args 0] "-destroy"]
	if {$destroy} {
	    set args [lrange $args 1 end]
	}
	foreach w $args {
	    if {$w eq ""} { continue }
	    if {![info exists ITEMS($w)] || ![winfo exists $w]} {
		# destroy any possible left-over separator
		catch {destroy $ITEMS($w)}
		# and make sure the item name is removed
		catch {unset ITEMS($w)}
		# otherwise ignore unknown or non-widget items
		continue
	    }
	    # separator is always previous item
	    set sep $ITEMS($w)
	    if {[winfo exists $sep]} {
		# destroy separator on remove or destroy
		destroy $sep
	    }
	    if {$destroy} {
		destroy $w
	    } else {
		grid forget $w
	    }
	    unset ITEMS($w)
	    set idx [lsearch -exact $ITEMS() $w]
	    set ITEMS() [lreplace $ITEMS() $idx $idx]
	    if {$idx == 0 && [llength $ITEMS()]} {
		# separator of next item is no longer necessary, if it exists
		set w [lindex $ITEMS() 0]
		set sep $ITEMS($w)
		set ITEMS($w) {}
		destroy $sep
	    }
	}
    }

    method delete {args} {
	eval [linsert $args 0 $self remove -destroy]
    }

    method items {{ptn *}} {
	# return from ordered list
	if {$ptn ne "*"} {
	    return [lsearch -all -inline $ITEMS() $ptn]
	}
	return $ITEMS()
    }

    method _padval {val} {
	set len [llength $val]
	if {$len == 0} {
	    return [list 0 0 0 0]
	} elseif {$len == 1} {
	    return [list [list $val $val] [list $val $val]]
	} elseif {$len == 2} {
	    set x [lindex $val 0] ; set y [lindex $val 1]
	    return [list [list $x $x] [list $y $y]]
	} elseif {$len == 3} {
	    return [list [list [lindex $val 0] [lindex $val 2]] \
			[list [lindex $val 1] [lindex $val 1]]]
	} else {
	    return $val
	}
    }

    # The following proc handles the mouse click on the resize control if we
    # aren't using the ttk::sizegrip.
    # It stores the original size of the window and the initial coords of the
    # mouse relative to the root.
    method begin_resize {w rootx rooty} {
	set t    [winfo toplevel $w]
	set relx [expr {$rootx - [winfo rootx $t]}]
	set rely [expr {$rooty - [winfo rooty $t]}]
	set resize($w,x) $relx
	set resize($w,y) $rely
	set resize($w,w) [winfo width $t]
	set resize($w,h) [winfo height $t]
	set resize($w,winc) 1
	set resize($w,hinc) 1
	set resize($w,grid) [wm grid $t]
    }

    # The following proc handles mouse motion on the resize control by asking
    # the wm to adjust the size of the window.
    method continue_resize {w rootx rooty} {
	if {[llength $resize($w,grid)]} {
	    # at this time, we don't know how to handle gridded resizing
	    return
	}
	set t      [winfo toplevel $w]
	set relx   [expr {$rootx - [winfo rootx $t]}]
	set rely   [expr {$rooty - [winfo rooty $t]}]
	set width  [expr {$relx - $resize($w,x) + $resize($w,w)}]
	set height [expr {$rely - $resize($w,y) + $resize($w,h)}]
	if {$width  < 0} { set width 0 }
	if {$height < 0} { set height 0 }
	wm geometry $t ${width}x${height}
    }

    # The following proc cleans up when the user releases the mouse button.
    method end_resize {w rootx rooty} {
	#continue_resize $w $rootx $rooty
	#wm grid $t $resize($w,grid)
	array unset resize $w,*
    }
}

package provide widget::statusbar 1.1
