## -*- tcl -*-
# # ## ### ##### ######## ############# #####################
##
# Canvas Behavior Module. Managing a semi-crosshair circle when dragging. The
# tracers is a unfilled circle centered on the current location of the
# mouse. Purely visual. Driven from the outside. No bindings of its own.
##

# # ## ### ##### ######## ############# #####################
## Requisites

package require Tcl 8.5- 
package require Tk
package require snit

namespace eval ::canvas::track {
    namespace export circle
    namespace ensemble create
}

# # ## ### ##### ######## ############# #####################
## API

snit::type ::canvas::track::circle {
    # # ## ### ##### ######## ############# #####################
    ## Lifecycle management

    constructor {c} { ;# puts [info level 0]
	set mycanvas $c

	bind $self <Destroy> [mymethod off]
	bind $self <Enter>   [mymethod start %x %y]
	bind $self <Leave>   [mymethod done]
	bind $self <Motion>  [mymethod move %x %y]

	$self on
	return
    }

    destructor { ;# puts [info level 0]
	$self off
	$self done
	bind $self <Destroy> {}
	bind $self <Enter>   {}
	bind $self <Leave>   {}
	bind $self <Motion>  {}
	return
    }

    # # ## ### ##### ######## ############# #####################

    method off {} { ;# puts [info level 0]
	set bindtags [bindtags $mycanvas]
	set pos [lsearch -exact $bindtags $self]
	if {$pos < 0} return
	bindtags $mycanvas [lreplace $bindtags $pos $pos]
	return
    }

    method on {} { ;# puts [info level 0]
	bindtags $mycanvas [linsert [bindtags $mycanvas] 1 $self]
	return
    }

    # # ## ### ##### ######## ############# #####################
    ## API.

    method radius {value} { ;# puts [info level 0]
	set myradius $value
	if {!$myactive} return
	if {![info exists mycurrent]} return
	if {![llength $mycurrent]}    return
	$self start {*}$mycurrent
	return
    }

    method start {x y} { ;# puts [info level 0]
	# stop previous tracking, if any
	$self done
	
	# center is current location as mouse position, plus radius of the
	# tracking circle

	set x [$mycanvas canvasx $x]
	set y [$mycanvas canvasy $y]

	set w [expr {$x - $myradius}]
	set n [expr {$y - $myradius}]
	set e [expr {$x + $myradius}]
	set s [expr {$y + $myradius}]
	
	set     myitems  {}
	lappend myitems [$mycanvas create oval $w $n $e $s \
			     -width 1 -outline black -dash .]

	# TODO extension -- circle configuration (outline color, dash mode)

	set myactive yes
	set mycurrent [list $x $y]
	return
    }

    method move {x y} { ;# puts [info level 0]
	if {![llength $myitems]} return

	set x [$mycanvas canvasx $x]
	set y [$mycanvas canvasy $y]

	set w [expr {$x - $myradius}]
	set n [expr {$y - $myradius}]
	set e [expr {$x + $myradius}]
	set s [expr {$y + $myradius}]
	
	foreach item $myitems { $mycanvas coords $item $w $n $e $s }
	set mycurrent [list $x $y]
	return
    }

    method done {} { ;# puts [info level 0]
	if {![llength $myitems]} return
	$mycanvas delete {*}$myitems
	set myitems {}
	set myactive no
	return
    }

    # # ## ### ##### ######## ############# #####################
    ## STATE

    variable mycanvas  {} ; # The canvas we are working with/on.
    variable myitems   {} ; # List of the canvas items representing the circle
    variable myradius  10 ; # Radius of the tracking circle
    variable myactive   0 ; # activity flag
    variable mycurrent {} ; # last mouse position, for restart after radius changes

    ##
    # # ## ### ##### ######## ############# #####################
}

# # ## ### ##### ######## ############# #####################
## Ready

package provide canvas::track::circle 0.1
return

# # ## ### ##### ######## ############# #####################
## Scrap yard.
