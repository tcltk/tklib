## -*- tcl -*-
# ### ### ### ######### ######### #########

# @@ Meta Begin
# Package zoom 1.0
#
# Meta platform    tcl
# Meta description A mega widget to select one of a finite set of zoom levels.
# Meta description 
# Meta subject     zoom
# Meta require     {Tcl 8.5}
# Meta require     snit
#
# # --- --- --- --------- --------- ---------
# Meta ak::api::desc  
# Meta ak::api::desc  
# Meta ak::api::desc  
# Meta ak::api::desc  
# Meta ak::api::desc  
# Meta ak::api::desc  
# Meta ak::api::desc  
# Meta ak::api::desc  
#
# # --- --- --- --------- --------- ---------
# @@ Meta End

# ### ### ### ######### ######### #########
## Requisites

package require Tcl 8.4        ; # No {*}-expansion :(
package require snit           ; # 
package require uevent::onidle ; # Some defered actions.

# ### ### ### ######### ######### #########
##

snit::widget zoom {
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

    component reconfigure
    method Reconfigure {} {
	eval [linsert [winfo children $win] 0 destroy]

	set side $ourside($options(-orient))
	set n    $options(-levels)

	button $win.outz -text - -command [mymethod ZoomOut]
	pack   $win.outz -side $side -expand 0 -fill both

	set mynormalbg [$win.outz cget -bg]

	for {set l 0} {$l < $n} {incr l} {
	    button $win.l$l -text $l -command [mymethod Zoom $l]
	    pack   $win.l$l -side $side -expand 0 -fill both
	}

	button $win.inz  -text + -command [mymethod ZoomIn]
	pack   $win.inz -side $side -expand 0 -fill both

	if {$mycurrent < 0   } { set mycurrent 0 }
	if {$mycurrent >= $n } { set mycurrent $n ; incr mycurrent -1 }

	$self Notify
	return
    }

    # ### ### ### ######### ######### #########

    method O-command {o v} {
	if {$v eq $options(-command)} return
	set options(-command) $v
	$self Notify
	return
    }

    # ### ### ### ######### ######### #########

    method O-variable {o v} {
	if {$v eq $options(-variable)} return
	if {$options(-variable) ne ""} {
	    trace remove variable $options(-variable) write [mymethod Trace]
	}
	set options(-variable) $v
	if {$options(-variable) ne ""} {
	    upvar #0 $options(-variable) current
	    set current $mycurrent
	    trace add variable $options(-variable) write [mymethod Trace]
	}
	return
    }

    method Trace {args} {
	upvar #0 $options(-variable) current
	$self Reset
	set mycurrent $current
	$self Notify
	return
    }

    # ### ### ### ######### ######### #########

    method ZoomIn {} {
	if {$mycurrent >= $options(-levels)} return
	$self Reset
	incr mycurrent
	$self Notify
	return
    }

    method ZoomOut {} {
	if {$mycurrent <= 0} return
	$self Reset
	incr mycurrent -1
	$self Notify
	return
    }

    method Zoom {newlevel} {
	$self Reset
	set mycurrent $newlevel
	$self Notify
	return
    }

    # ### ### ### ######### ######### #########

    method Reset {} {
	catch { $win.l$mycurrent configure -bg $mynormalbg }
	return
    }

    method Notify {} {
	if {$options(-variable) ne ""} {
	    upvar #0 $options(-variable) current
	    set current $mycurrent
	}
	if {$options(-command) ne ""} {
	    uplevel #0 [linsert $options(-command) end $win $mycurrent]
	}

	catch { $win.l$mycurrent configure -bg steelblue }
	return
    }

    # ### ### ### ######### ######### #########
    ## State

    variable mynormalbg {}

    variable mycurrent 0 ; # Currently chosen zoom level.

    # Map from orientation to widget side to use for packing.

    typevariable ourside -array {
	vertical   bottom
	horizontal right
    }

    # ### ### ### ######### ######### #########
}

# ### ### ### ######### ######### #########
## Ready

package provide zoom 1.0
return

# ### ### ### ######### ######### #########
## Scrap yard.
