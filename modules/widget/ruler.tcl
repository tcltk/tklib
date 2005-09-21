# -*- tcl -*-
#
# ruler.tcl
#
#	ruler widget and screenruler dialog
#
# Copyright (c) 2005 Jeffrey Hobbs.  All Rights Reserved.
#

###
# Creation and Options - widget::ruler $path ...
#    -foreground	-default black
#    -font		-default {Helvetica 14}
#    -interval		-default [list 5 25 100]
#    -sizes		-default [list 4 8 12]
#    -showvalues	-default 1
#    -outline		-default 1
#    -grid		-default 0
#    -measure		-default pixels ; # not yet implemented
#    all other options inherited from canvas
#
# Methods
#  All methods passed to canvas
#
# Bindings
#  <Configure> redraws
#

###
# Creation and Options - widget::screenruler $path ...
#    -alpha	-default 0.8
#    -title	-default ""
#    -topmost	-default 0
#
# Methods
#  $path display
#  $path hide
#  All
#
# Bindings
#

if 0 {
    # Samples
    package require widget::screenruler
    set dlg [widget::screenruler .r -grid 1 -title "Screen Ruler"]
    $dlg menu add separator
    $dlg menu add command -label "Exit" -command { exit }
    $dlg display
}

package require widget 3

snit::widgetadaptor widget::ruler {
    delegate option * to hull
    delegate method * to hull

    option -foreground	-default black -configuremethod C-redraw;
    option -font	-default {Helvetica 14};
    option -interval	-default [list 5 25 100] -validatemethod C-list \
	-configuremethod C-redraw;
    option -sizes	-default [list 4 8 12] -validatemethod C-list \
	-configuremethod C-redraw;
    option -showvalues	-default 1 -configuremethod C-redraw;
    option -outline	-default 1 -configuremethod C-redraw;
    option -grid	-default 0 -configuremethod C-redraw;
    option -measure	-default pixels; # -configuremethod C-measure;

    variable shade -array {small gray medium gray large gray}

    constructor {args} {
	installhull using canvas -width 200 -height 50 \
	    -relief flat -bd 0 -background white -highlightthickness 0

	$hull xview moveto 0
	$hull yview moveto 0

	$self _reshade

	bind $win <Configure> [mymethod _resize %W %X %Y]

	#bind $win <Key-minus> [mymethod _adjustinterval -1]
	#bind $win <Key-plus>  [mymethod _adjustinterval 1]
	#bind $win <Key-equal> [mymethod _adjustinterval 1]

	$self configurelist $args

	$self redraw
   }

    ########################################
    ## public methods

    ########################################
    ## configure methods

    variable redrawID {}
    variable width    0
    variable height   0

    method C-interval {option value} {
	if {[llength $value] != 2
	    || ![string is double -strict [lindex $value 0]]
	    || ![string is double -strict [lindex $value 1]]} {
	    return -code error "invalid $option value \"$value\":\
		must be a pair of doubles"
	}
        set options($option) $value
	after cancel $redrawID
	set redrawID [after idle [mymethod redraw]]
    }

    method C-list {option value} {
	if {[llength $value] != 3
	    || ![string is double -strict [lindex $value 0]]
	    || ![string is double -strict [lindex $value 1]]
	    || ![string is double -strict [lindex $value 2]]} {
	    return -code error "invalid $option value \"$value\":\
		must be a list of 3 doubles"
	}
    }
    method C-redraw {option value} {
        set options($option) $value
	if {$option eq "-foreground"} { $self _reshade }
	after cancel $redrawID
	set redrawID [after idle [mymethod redraw]]
    }

    method _reshade {} {
	set bg [$hull cget -bg]
	set fg $options(-foreground)
	set shade(small)  [$self shade $bg $fg 0.15]
	set shade(medium) [$self shade $bg $fg 0.4]
	set shade(large)  [$self shade $bg $fg 0.8]
    }

    ########################################
    ## private methods

    method redraw_x {} {
 	foreach {sms meds lgs} $options(-sizes) { break }
	foreach {smi medi lgi} $options(-interval) { break }
 	for {set x 0} {$x < $width} {set x [expr {$x + $smi}]} {
	    if {fmod($x, $lgi) == 0.0} {
		# draw large tick
		set h $lgs
		set tags [list tick large]
		if {$x && $options(-showvalues) && $height > $lgs} {
		    $hull create text [expr {$x+1}] $h \
			-text [format %g $x] -anchor nw -tags value
		}
		set fill $shade(large)
	    } elseif {fmod($x, $medi) == 0.0} {
		set h $meds
		set tags [list tick medium]
		set fill $shade(medium)
	    } else {
		set h $sms
		set tags [list tick small]
		set fill $shade(small)
	    }
	    if {$options(-grid)} {
		$hull create line $x 0 $x $height -width 1 -tags $tags \
		    -fill $fill
	    } else {
		$hull create line $x 0 $x $h -width 1 -tags $tags \
		    -fill $options(-foreground)
		$hull create line $x $height $x [expr {$height - $h}] \
		    -width 1 -tags $tags -fill $options(-foreground)
	    }
	}
    }

    method redraw_y {} {
 	foreach {sms meds lgs} $options(-sizes) { break }
	foreach {smi medi lgi} $options(-interval) { break }
 	for {set y 0} {$y < $height} {set y [expr {$y + $smi}]} {
	    if {fmod($y, $lgi) == 0.0} {
		# draw large tick
		set w $lgs
		set tags [list tick large]
		if {$y && $options(-showvalues) && $width > $lgs} {
		    $hull create text $w [expr {$y+1}] \
			-text [format %g $y] -anchor nw -tags value
		}
		set fill $shade(large)
	    } elseif {fmod($y, $medi) == 0.0} {
		set w $meds
		set tags [list tick medium]
		set fill $shade(medium)
	    } else {
		set w $sms
		set tags [list tick small]
		set fill $shade(small)
	    }
	    if {$options(-grid)} {
		$hull create line 0 $y $width $y -width 1 -tags $tags \
		    -fill $fill
	    } else {
		$hull create line 0 $y $w $y -width 1 -tags $tags \
		    -fill $options(-foreground)
		$hull create line $width $y [expr {$width - $w}] $y \
		    -width 1 -tags $tags -fill $options(-foreground)
	    }
	}
    }

    method redraw {} {
	$hull delete all
	set width  [winfo width $win]
	set height [winfo height $win]
	$self redraw_x
	$self redraw_y
	if {$options(-outline) || $options(-grid)} {
	    $hull create rect 0 0 [expr {$width-1}] [expr {$height-1}] \
		-width 1 -outline $options(-foreground) -tags outline
	}
	if {$options(-showvalues) && $height > 20} {
	    $hull create text 15 [expr {$height/2.}] \
		-text "${width}x$height pixels" \
		-anchor w -tags [list value label] \
		-fill $options(-foreground)
	}
	$hull raise large
	$hull raise value
    }

    method _resize {w X Y} {
	if {$w ne $win} { return }
	after cancel $redrawID
	set redrawID [after idle [mymethod redraw]]
    }

    method _adjustinterval {dir} {
	set newint {}
	foreach i $options(-interval) {
	    if {$dir < 0} {
		lappend newint [expr {$i/2.0}]
	    } else {
		lappend newint [expr {$i*2.0}]
	    }
	}
	set options(-interval) $newint
	after cancel $redrawID
	set redrawID [after idle [mymethod redraw]]
    }

    method shade {orig dest frac} {
	if {$frac >= 1.0} {return $dest} elseif {$frac <= 0.0} {return $orig}
	foreach {oR oG oB} [winfo rgb $win $orig] \
	    {dR dG dB} [winfo rgb $win $dest] {
	    set color [format "\#%02x%02x%02x" \
			   [expr {int($oR+double($dR-$oR)*$frac)}] \
			   [expr {int($oG+double($dG-$oG)*$frac)}] \
			   [expr {int($oB+double($dB-$oB)*$frac)}]]
	    return $color
	}
    }

}

snit::widget widget::screenruler {
    hulltype toplevel

    component ruler -public ruler
    component menu -public menu

    delegate option * to ruler
    delegate method * to ruler

    option -alpha	-default 0.8 -configuremethod C-alpha;
    option -title	-default "" -configuremethod C-title;
    option -topmost	-default 0 -configuremethod C-topmost;

    variable alpha 0.8 ; # internal opacity value
    variable curinterval 5;
    variable grid 0;

    constructor {args} {
	wm withdraw $win
	wm overrideredirect $win 1
	$hull configure -bg white

	install ruler using widget::ruler $win.ruler -width 200 -height 50 \
	    -relief flat -bd 0 -background white -highlightthickness 0
	install menu using menu $win.menu -tearoff 0

	# avoid 1.0 because we want to maintain
	if {$alpha >= 1.0} { set alpha 0.999 }
	catch {wm attributes $win -alpha $alpha}
	catch {wm attributes $win -topmost $options(-topmost)}

	grid $ruler -sticky news
	grid columnconfigure $win 0 -weight 1
	grid rowconfigure    $win 0 -weight 1

	$menu add checkbutton -label "Show Grid" \
	    -variable [myvar grid] \
	    -command "[list $ruler configure -grid] \$[myvar grid]"
	$menu add checkbutton -label "Keep on Top" \
	    -variable [myvar options(-topmost)] \
	    -command "[list $win configure -topmost] \$[myvar options(-topmost)]"
	set m [menu $menu.interval -tearoff 0]
	$menu add cascade -label "Interval" -menu $m
	foreach interval {
	    {2 10 50} {4 20 100} {5 25 100} {10 50 100}
	} {
	    $m add radiobutton -label [lindex $interval 0] \
		-variable [myvar curinterval] -value [lindex $interval 0] \
		-command [list $ruler configure -interval $interval]
	}
	set m [menu $menu.opacity -tearoff 0]
	$menu add cascade -label "Opacity" -menu $m
	for {set i 10} {$i <= 100} {incr i 10} {
	    set aval [expr {$i/100.}]
	    $m add radiobutton -label "${i}%" \
		-variable [myvar alpha] -value $aval \
		-command [list $win configure -alpha $aval]
	}

	if {[tk windowingsystem] eq "aqua"} {
	    bind $win <Control-ButtonPress-1> [list tk_popup $menu %X %Y]
	    # Aqua switches 2 and 3 ...
	    bind $win <ButtonPress-2>         [list tk_popup $menu %X %Y]
	} else {
	    bind $win <ButtonPress-3>         [list tk_popup $menu %X %Y]
	}
	#bind $win <Configure>     [mymethod _resize %W %X %Y]
	bind $win <ButtonPress-1> [mymethod _dragstart %W %X %Y]
	bind $win <B1-Motion>     [mymethod _drag %W %X %Y]
	bind $win <Motion>        [mymethod _edgecheck %W %x %y]

	$self configurelist $args

	set grid [$ruler cget -grid]
   }

    ########################################
    ## public methods

    method display {} {
	wm deiconify $win
	raise $win
	focus $ruler
    }

    method hide {} {
	wm withdraw $win
    }

    ########################################
    ## configure methods

    method C-alpha {option value} {
	if {![string is double -strict $value]
	    || $value < 0.0 || $value > 1.0} {
	    return -code error "invalid $option value \"$value\":\
		must be a double between 0 and 1"
	}
        set options($option) $value
	set alpha $value
	# avoid 1.0 because we want to maintain
	if {$alpha >= 1.0} { set alpha 0.999 }
	catch {wm attributes $win -alpha $alpha}
    }
    method C-title {option value} {
	wm title $win $value
	wm iconname $win $value
        set options($option) $value
    }
    method C-topmost {option value} {
        set options($option) $value
	catch {wm attributes $win -topmost $value}
    }

    ########################################
    ## private methods

    method _resize {w X Y} {
	if {$w ne $ruler} { return }
	after cancel $redrawID
	set redrawID [after idle [mymethod redraw]]
    }

    variable edge -array {
	at 0
	left   1
	right  2
	top    3
	bottom 4
    }
    method _edgecheck {w x y} {
	if {$w ne $ruler} { return }
	set edge(at) 0
	set cursor ""
	if {$x < 4 || $x > ([winfo width $win] - 4)} {
	    set cursor sb_h_double_arrow
	    set edge(at) [expr {$x < 4 ? $edge(left) : $edge(right)}]
	} elseif {$y < 4 || $y > ([winfo height $win] - 4)} {
	    set cursor sb_v_double_arrow
	    set edge(at) [expr {$y < 4 ? $edge(top) : $edge(bottom)}]
	}
	$win configure -cursor $cursor
    }

    variable drag -array {}
    method _dragstart {w X Y} {
	set drag(X) [expr {$X - [winfo rootx $win]}]
	set drag(Y) [expr {$Y - [winfo rooty $win]}]
	set drag(w) [winfo width $win]
	set drag(h) [winfo height $win]
	$self _edgecheck $ruler $drag(X) $drag(Y)
    }
    method _drag {w X Y} {
	if {$edge(at) == 0} {
	    set dx [expr {$X - $drag(X)}]
	    set dy [expr {$Y - $drag(Y)}]
	    wm geometry $win +$dx+$dy
	} elseif {$edge(at) == $edge(left)} {
	    # need to handle moving root - currently just moves
	    set dx [expr {$X - $drag(X)}]
	    set dy [expr {$Y - $drag(Y)}]
	    wm geometry $win +$dx+$dy
	} elseif {$edge(at) == $edge(right)} {
	    set relx   [expr {$X - [winfo rootx $win]}]
	    set width  [expr {$relx - $drag(X) + $drag(w)}]
	    set height $drag(h)
	    if {$width > 5} {
		wm geometry $win ${width}x${height}
	    }
	} elseif {$edge(at) == $edge(top)} {
	    # need to handle moving root - currently just moves
	    set dx [expr {$X - $drag(X)}]
	    set dy [expr {$Y - $drag(Y)}]
	    wm geometry $win +$dx+$dy
	} elseif {$edge(at) == $edge(bottom)} {
	    set rely   [expr {$Y - [winfo rooty $win]}]
	    set width  $drag(w)
	    set height [expr {$rely - $drag(Y) + $drag(h)}]
	    if {$height > 5} {
		wm geometry $win ${width}x${height}
	    }
	}
    }
}

########################################
## Ready for use

package provide widget::ruler 1.0
package provide widget::screenruler 1.0

if {[info exist ::argv0] && $::argv0 eq [info script]} {
    # We are the main script being run - show ourselves
    wm withdraw .
    set dlg [widget::screenruler .r -grid 1 -title "Screen Ruler"]
    $dlg menu add separator
    $dlg menu add command -label "Exit" -command { exit }
    $dlg display
}
