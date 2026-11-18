#! /usr/bin/env tclsh
# -*- tcl -*-
# # ## ### ##### ######## ############# #####################
# demo_editpoints.tcl --
#
# This demonstration script creates a canvas widget where you can edit
# a cloud of points, i.e. add, remove, and drag point markers.

# # ## ### ##### ######## ############# #####################
## Bindings
#
# Button-1 : Create new point at mouse position.
# Button-2 : Remove point at mouse position.
# Button-3 : Start drag of point at mouse position.

# # ## ### ##### ######## ############# #####################
## Requirements

package require Tcl 8.5-

# Extend the package search path so that this demonstration works with
# the non-installed tklib packages well. A regular application should
# not require this.

apply {{selfdir} {
    #puts ($selfdir)
    lappend ::auto_path $selfdir
    lappend ::auto_path [file normalize $selfdir/../../modules/canvas]
}} [file dirname [file normalize [info script]]]

package require Tk
package require canvas::edit::points
package require canvas::track::circle

# # ## ### ##### ######## ############# #####################
## Radius management

set radius    10
set shadow    10
set threshold  5

trace add variable radius write {apply {{name detail op} {
    global shadow radius threshold timer
    if {![string is int -strict $radius]} { set radius $shadow ; return }    
    set threshold [expr {$radius / 2.}]
    EDITOR configure -radius $radius

    catch { after cancel $timer }
    set timer [after 200 tracker]
    return
}}}

# # ## ### ##### ######## ############# #####################
## GUI

set w .plot
catch {destroy $w}
wm withdraw .

toplevel       $w
wm title       $w "Canvas :: Editor :: Points"
wm iconname    $w "CEPC"
set c          $w.c

label  $w.msg   -text {} -relief raised -bd 2 -anchor w

button $w.exit  -command ::exit    -text Exit
button $w.flip  -command flip      -text Disabled
button $w.clear -command clear     -text Clear
button $w.mode  -command next-mode -text Click+Drag
button $w.dump  -command dump      -text Dump

entry  $w.rad -relief sunken -bd 2 -bg white -textvariable radius

canvas $c -relief raised -width 450 -height 300 -bd 2

grid rowconfigure    $w 0 -weight 0
grid rowconfigure    $w 1 -weight 1
grid rowconfigure    $w 2 -weight 0

grid columnconfigure $w 0 -weight 0
grid columnconfigure $w 1 -weight 1
grid columnconfigure $w 2 -weight 0
grid columnconfigure $w 3 -weight 0

grid $w.msg   -row 0 -column 0 -columnspan 6 -sticky swen
grid $c       -row 1 -column 0 -columnspan 6 -sticky swen

grid $w.exit  -row 2 -column 0               -sticky swen
grid $w.rad   -row 2 -column 1               -sticky swn
grid $w.dump  -row 2 -column 2               -sticky sen
grid $w.mode  -row 2 -column 3               -sticky sen
grid $w.flip  -row 2 -column 4               -sticky swen
grid $w.clear -row 2 -column 5               -sticky swen

# TODO -- MAYBE pen shape changes ? - square, rhombus/square

# # ## ### ##### ######## ############# #####################
## Setup the behavioral triggers and responses ...

canvas::edit points EDITOR $c -data-cmd M  -radius $radius
#global radius ; set radius [EDITOR cget -radius]
global last   ; set last {}

canvas::track circle TC $c
TC radius $radius

proc M {args} { ;# puts (($args))
    
    global w
    $w.msg configure -text $args
    set args [lassign $args c]
    M.$c {*}$args
}

proc M.add-query {_ x y} { ;# puts [info level 0]
    # admittance query for location

    global last threshold
    # reject fast when not far enough away from the last added point
    if {($last ne {}) && ([distance $x $y {*}$last] <= $threshold)} {
	return 0
    }

    # not bailed - check everything
    if {[min-distance $x $y] < $threshold} { return 0 }

    # admitted
    return 1

}

proc M.add-end {_} { global last ; set last {} }

proc M.add {_ tag x y} { ;# puts [info level 0]
    # ignore adds except in draw mode
    if {[EDITOR cget -mode] ne "draw"} {
	#puts /not-drawing/
	return
    }

    global points tagged last radius
    # confirmed add, extend data

    set last [list $x $y $radius]
    dict set tagged $tag $last
    lappend last $tag ; lappend points $last
    return
}

proc M.remove-query {_ x y} {
    global points radius
    #puts QQ||$points||
    
    # locate and return points to remove -- naive
    lmap p $points {
	lassign $p px py pradius
	if {$radius <= [distance $x $y $px $py]} continue
	lindex $p end ;# report just tags
    }
}

proc M.remove {_ tag} { ;# puts [info level 0]
    # ignore removals except in draw mode
    if {[EDITOR cget -mode] ne "draw"} {
	#puts /non-drawing/
	return
    }

    global points tagged
    # naive removal
    dict unset tagged $tag
    
    set points [lmap p $points {
	if {[lindex $p end] eq $tag} {
	    #puts DROP/$tag
	    continue
	}
	set p
    }]
    return
}

proc M.remove-end {_} {}

proc M.move {method args} { M.move.$method {*}$args }

proc M.move.start {_ tag} { return 1 }

proc M.move.delta {_ tag x y cdx cdy} {
    global dx dy
    set dx $cdx
    set dy $cdy
    #puts "|$dx $dy|"
    return 1
}

proc M.move.done {_ tag} {
    global dx dy
    #puts "|$dx $dy|[expr {hypot($dx,$dy)}]"
    if {hypot($dx,$dy) > 200} { return 0 }
    return 1
}

# # ## ### ##### ######## ############# #####################
## manage point clouds for drawing mode

global points ;# list (point...), point = tuple(x, y)
global last   ;# point
global tagged ;# dict (tag -> point)

proc min-distance {x y} {
    global points
    set min Inf
    # naive search -- for large clouds look towards kd-tree or similar
    foreach p $points {
	set d [distance $x $y {*}$p]
	if {$d >= $min} continue
	set min $d
    }
    return $min
}

proc distance {x y px py args} { expr {hypot($x-$px,$y-$py)} }

# # ## ### ##### ######## ############# #####################
##

proc flip {} {
    global w
    if {[EDITOR active]} {
	EDITOR disable ; $w.flip configure -text Disabled
    } else {
	EDITOR enable ;  $w.flip configure -text Enabled
    }
    return
}

proc clear {} {
    EDITOR clear
    # drawing state
    global points
    set    points {}
    return
}

proc next-mode {} {
    global w
    set sequence {
	click+drag  {click      Click     }
	click       {draw       Draw      }
	draw        {click+drag Click+Drag}
    }
    lassign [dict get $sequence [EDITOR cget -mode]] next nextlabel
    # Switch to next mode in sequence, ...
    EDITOR  configure -mode $next
    $w.mode configure -text $nextlabel
}

proc tracker {} { global radius ; TC radius $radius ; return }

proc dump {} {
    global points
    if {![llength $points]} return
    
    puts -nonewline "# centers"
    # collect by radius - emit variable assignments for radii and centers
    set var 0
    set lastr .
    foreach p [lsort -real -index 2 [lsort -real -index 1 [lsort -real -index 0 $points]]] {
	lassign $p x y r
	if {$r != $lastr} { puts -nonewline "\nset vradius$var $r\nset vcenter$var \{" ; incr var ; set prefix {} }
	puts -nonewline "$prefix\{$x $y\}"
	set prefix { }
	if {[incr emitted] > 10} { set prefix \n\t ; set emitted 0 }
	set lastr $r
    }
    puts "\}"
    # emit code to compute the bboxes
    puts ""
    puts "# boxes"
    for {set k 0} {$k < $var} {incr k} { puts "set box$k \[aktive point box {*}\$vcenter$k\]" }
    # emit code to unify the boxes into one
    puts -nonewline "set box \[aktive rectangle union"
    for {set k 0} {$k < $var} {incr k} {
	puts -nonewline " \$box$k"
    }
    puts "\]"
    # emit code to make the box suitable for image gen
    puts ""
    puts "lassign \$box x y w h"
    # emit base images, per radius
    puts ""
    for {set k 0} {$k < $var} {incr k} {
	puts "set image$k \[aktive image sdf circles x \$x y \$y w \$w h \$h radius \$vrad$k centers {*}\$vcenter$k"
    }
    # emit unifying image
    puts -nonewline "set image \[aktive op sdf or"
    for {set k 0} {$k < $var} {incr k} {
	puts -nonewline " \$image$k"
    }
    puts "\]"
    puts ""

    # aktive op sdf 2image pixelated
}

# # ## ### ##### ######## ############# #####################
## Invoke event loop.

clear
flip ;# enable

vwait __forever__
exit
