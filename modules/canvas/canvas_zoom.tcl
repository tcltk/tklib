## -*- tcl -*-
# ### ### ### ######### ######### #########

## A discrete zoom-control widget based on buttons. The API is similar
## to a scale.

# ### ### ### ######### ######### #########
## Requisites

package require Tcl 8.4        ; # No {*}-expansion :(
package require snit           ; # 
package require uevent::onidle ; # Some defered actions.

# ### ### ### ######### ######### #########
##

snit::widget canvas::zoom {
    # ### ### ### ######### ######### #########
    ## API

    option -orient   -default vertical -configuremethod O-orient -type {snit::enum -values {vertical horizontal}}
    option -levels   -default 0        -configuremethod O-levels -type {snit::integer -min 0}
    option -variable -default {}       -configuremethod O-variable
    option -command  -default {}       -configuremethod O-command

    constructor {args} {
	install reconfigure using uevent::onidle ${selfns}::reconfigure \
	    [mymethod Reconfigure]

	$self configurelist $args
	return
    }

    # ### ### ### ######### ######### #########
    ## Option processing. Any changes force a refresh of the grid
    ## information, and then a redraw.

    method O-orient {o v} {
	#puts $o=$v
	if {$options($o) eq $v} return
	set  options($o) $v
	$reconfigure request
	return
    }

    method O-levels {o v} {
	#puts $o=$v
	if {$options($o) == $v} return
	set  options($o) $v
	$reconfigure request
	return
    }

    method O-variable {o v} {
	if {$v eq $options(-variable)} return
	if {$options(-variable) ne ""} {
	    # Drop tracing of now disconnected variable.
	    trace remove variable $options(-variable) write [mymethod ZoomChanged]
	}
	set options(-variable) $v
	if {$options(-variable) ne ""} {
	    # Start to trace the now connected variable. Also import
	    # the zoomlevel external value.
	    upvar #0 $options(-variable) zoomlevel
	    set myzoomlevel $zoomlevel
	    trace add variable $options(-variable) write [mymethod ZoomChanged]
	}
	$reconfigure request
	return
    }

    method O-command {o v} {
	if {$v eq $options(-command)} return
	set options(-command) $v
	# Export current zoom level through the new callback.
	$self Callback
	return
    }

    # ### ### ### ######### ######### #########

    component reconfigure
    method Reconfigure {} {
	# (Re)generate the user interface.

	eval [linsert [winfo children $win] 0 destroy]

	set side $ourside($options(-orient))
	set max  $options(-levels)

	button $win.outz -text - -command [mymethod ZoomOut]
	pack   $win.outz -side $side -expand 0 -fill both

	set mynormalbg [$win.outz cget -bg]

	for {set level 0} {$level < $max} {incr level} {
	    button $win.l$level -text $level -command [mymethod ZoomSet $level]
	    pack   $win.l$level -side $side  -expand 0 -fill both
	}

	button $win.inz -text + -command [mymethod ZoomIn]
	pack   $win.inz -side $side -expand 0 -fill both

	# Validate the current zoom level, it may have become invalid
	# due to a change to max allowed levels.

	set z [Cap $myzoomlevel]
	if {$z == $myzoomlevel} return
	$self Update $z
	return
    }

    # ### ### ### ######### ######### #########
    ## Handle option changes

    # ### ### ### ######### ######### #########
    ## Events from inside and outside which act on the zoomlevel.

    method ZoomChanged {args} {
	upvar #0 $options(-variable) zoomlevel
	set z [Cap $zoomlevel]
	if {$myzoomlevel == $z} return
	$self Update $z
	return
    }

    method ZoomSet {new} {
	if {$new == $myzoomlevel} return
	$self Update $new
	return
    }

    method ZoomIn {} {
	if {$myzoomlevel >= ($options(-levels)-1)} return
	set  new $myzoomlevel
	incr new
	$self Update $new
	return
    }

    method ZoomOut {} {
	if {$myzoomlevel <= 0} return
	set  new $myzoomlevel
	incr new -1
	$self Update $new
	return
    }

    proc Cap {n} {
	upvar 1 options(-levels) max
	if {$n < 0 } { return 0 }
	if {$n >= $max } { return [expr {$max - 1}] }
	return $n
    }

    # ### ### ### ######### ######### #########
    ## Helper, update visible widget state for new level, and
    ## propagate new level to the model as well, via either -variable
    ## or -command.

    method Update {newlevel} {
	catch { $win.l$myzoomlevel configure -bg $mynormalbg }
	set myzoomlevel $newlevel
	catch { $win.l$myzoomlevel configure -bg steelblue }

	if {$options(-variable) ne ""} {
	    upvar #0 $options(-variable) zoomlevel
	    set zoomlevel $myzoomlevel
	}

	$self Callback
	return
    }

    method Callback {} {
	if {![llength $options(-command)]} return
	uplevel #0 [linsert $options(-command) end $win $myzoomlevel]
	return
    }

    # ### ### ### ######### ######### #########
    ## State

    variable mynormalbg {} ; # Color of non-highlighted button.
    variable myzoomlevel 0 ; # Currently chosen zoom level.

    # Map from the -orientation to the widget -side to use for
    # pack'ing.

    typevariable ourside -array {
	vertical   bottom
	horizontal right
    }

    # ### ### ### ######### ######### #########
}

# ### ### ### ######### ######### #########
## Ready

package provide canvas::zoom 0.1
return

# ### ### ### ######### ######### #########
## Scrap yard.
