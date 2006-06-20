# -*- tcl -*-
#
# toolbar - /snit::widget
#	Manage items in a toolbar.
#
#  ## Padding can be a list of {padx pady}
#  -ipad -default 1 ; provides padding around each status bar item
#  -pad  -default 0 ; provides general padding around the status bar
#  -separator -default {} ; one of {top left bottom right {}}
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

if 0 {
    # Example
    lappend auto_path ~/cvs/tcllib/tklib/modules/widget

    package require widget::toolbar
    set f [ttk::frame .f -padding 4]
    pack $f -fill both -expand 1
    set tb [widget::toolbar .f.tb]
    pack $tb -fill both -expand 1
    $tb add button foo -text Foo
    $tb add button bar -text Bar -separator 1
    $tb add button baz -text Baz
    set b [ttk::button $tb.zippy -text Zippy -state disabled]
    $tb add $b
}

package require widget
package require tile
#package require tooltip

snit::widget widget::toolbar {
    hulltype ttk::frame

    component separator
    component frame

    delegate option * to hull
    delegate method * to hull

    option -wrap -default 0 -validatemethod isa
    option -separator -default {} \
	-configuremethod C-separator -validatemethod isa
    # -pad provides general padding around the status bar
    # -ipad provides padding around each status bar item
    # Padding can be a list of {padx pady}
    option -ipad -default 1 -configuremethod C-ipad -validatemethod isa
    option -pad  -default 0 -configuremethod C-pad -validatemethod isa

    variable ITEMS -array {}
    typevariable septypes {top left bottom right {}}

    constructor {args} {
	$hull configure -height 18

	install frame using ttk::frame $win.frame

	install separator using ttk::separator $win.separator

	grid $frame -row 1 -column 1 -sticky news
	grid columnconfigure $win 1 -weight 1

	$self configurelist $args
    }

    method isa {option value} {
	set cmd widget::isa
	switch -exact -- $option {
	    -separator {
		return [uplevel 1 [list $cmd list $septypes $option $value]]
	    }
	    -wrap {
		return [uplevel 1 [list $cmd boolean $option $value]]
	    }
	    -ipad - -pad {
		return [uplevel 1 [list $cmd listofint 2 $option $value]]
	    }
	}
    }

    method C-ipad {option value} {
	set options($option) $value
	# double value to ensure a single int value covers pad x and y
	foreach {padx pady} [concat $value $value] { break }
	foreach w [grid slaves $frame] {
	    grid configure $w -padx $padx -pady $pady
	}
    }

    method C-pad {option value} {
	set options($option) $value
	# double value to ensure a single int value covers pad x and y
	foreach {padx pady} [concat $value $value] { break }
	$frame configure -padding [list $padx $pady]
    }

    method C-separator {option value} {
	set options($option) $value
	switch -exact -- $value {
	    top {
		$separator configure -orient horizontal
		grid $separator -row 0 -column 1 -sticky ew
	    }
	    left {
		$separator configure -orient vertical
		grid $separator -row 1 -column 0 -sticky ns
	    }
	    bottom {
		$separator configure -orient horizontal
		grid $separator -row 2 -column 1 -sticky ew
	    }
	    right {
		$separator configure -orient vertical
		grid $separator -row 1 -column 2 -sticky ns
	    }
	    {} {
		grid remove $separator
	    }
	}
    }

    # Use this or 'add' - but not both
    method getframe {} { return $win.frame }

    method add {what args} {
	if {[winfo exists $what]} {
	    set w $what
	    set symbol $w
	} else {
	    set w $frame._$col
	    set symbol [lindex $args 0]
	    set args [lrange $args 1 end]
	    if {$what eq "button"} {
		set w [ttk::button $w -style Toolbutton -takefocus 0]
	    } elseif {$what eq "checkbutton"} {
		set w [ttk::checkbutton $w -style Toolbutton -takefocus 0]
	    } else {
		return -code error "unknown toolbar item type '$what'"
	    }
	}
	set opts(-weight)	0
	set opts(-separator)	0
	set opts(-sticky)	news
	set opts(-pad)		$options(-ipad)
	set cmdargs [list]
	set len [llength $args]
	for {set i 0} {$i < $len} {incr i} {
	    set key [lindex $args $i]
	    set val [lindex $args [incr i]]
	    if {$key eq "--"} {
		eval [list lappend cmdargs] [lrange $args $i end]
		break
	    }
	    if {[info exists opts($key)]} {
		set opts($key) $val
	    } else {
		# no error - pass to command
		lappend cmdargs $key $val
	    }
	}
	if {[catch {eval [linsert $cmdargs 0 $w configure]} err]} {
	    if {[info exists symbol]} { destroy $w }
	    return -code error $err
	}
	set ITEMS($symbol) $w
	foreach {padx pady} [concat $options(-ipad) $options(-ipad)] { break }

	# get cols,rows extent
	foreach {cols rows} [grid size $frame] break
	# Add separator if requested, and we aren't the first element
	if {$opts(-separator) && $cols != 0} {
	    set sep [ttk::separator $frame.sep[winfo name $w] -orient vertical]
	    # only append name, to distinguish us from them
	    #set ITEMS([winfo name $sep]) $sep
	    grid $sep -in $frame -row 0 -column $cols \
		-sticky ns -padx $padx -pady $pady
	    incr cols
	}

	grid $w -in $frame -row 0 -column $cols -sticky $opts(-sticky) \
	    -pady $pady -padx $padx
	grid columnconfigure $frame $cols -weight $opts(-weight)

	# we should have a <Configure> binding to wrap long toolbars
	#bind $win <Configure> [mymethod resize [list $win] %w]

	#tooltip::tooltip $w $text
	return $symbol
    }

    method remove {args} {
	set destroy [string equal [lindex $args 0] "-destroy"]
	if {$destroy} {
	    set args [lrange $args 1 end]
	}
	foreach sym $args {
	    set w $ITEMS($sym)
	    # separator is always previous item
	    set sep $frame.sep[winfo name $w]
	    if {[winfo exists $sep]} {
		# destroy separator for remove or destroy case
		destroy $sep
	    }
	    if {$destroy} {
		destroy $w
	    } else {
		grid forget $w
	    }
	    unset ITEMS($sym)
	}
    }

    method delete {args} {
	eval [linsert $args 0 $self remove -destroy]
    }

    method itemconfigure {symbol args} {
	if {$symbol eq "all"} {
	    # configure all, return # that failed the configure (0 == OK)
	    set code 0
	    foreach sym [array names ITEMS -glob $symbol] {
		incr code [catch { eval [linsert $args 0 \
					     $ITEMS($sym) configure] }]
	    }
	    return $code
	} elseif {[info exists ITEMS($symbol)]} {
	    # configure exact item
	    return [eval [linsert $args 0 $ITEMS($symbol) configure]]
	} else {
	    return -code error "unknown toolbar item '$symbol'"
	}
    }

    method itemcget {symbol option} {
	return [$ITEMS($symbol) cget $option]
    }

    method items {{ptn *}} {
	if {$ptn ne "*"} {
	    return [lsearch -all -inline [array names ITEMS] $ptn]
	}
	return [array names ITEMS]
    }

    method resize {w width} {
	if {$w ne $win} { return }
	if {$width < [winfo reqwidth $win]} {
	    # Take the last column item and move it down
	}
    }

}

package provide widget::toolbar 1.0
