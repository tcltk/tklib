#!/bin/sh
# -*- tcl -*- \
exec tclsh "$0" ${1+"$@"}
# ### ### ### ######### ######### #########

## DEMO. Uses openstreetmap to show a tile-based world map.

# ### ### ### ######### ######### #########
## Use canvas package relative to example location.

set selfdir  [file dirname [file normalize [info script]]]
set modules [file join [file dirname [file dirname $selfdir]] modules]

source $modules/canvas/canvas_sqmap.tcl
source $selfdir/tiles_xy_store_http.tcl

## Ideas:
## -- Add zoom-control to switch between zoom levels. This has to
##    adjust the scroll-region as well. The control can be something
##    using basic Tk widgets (scale, button), or maybe some constructed
##    from canvas items, to make the map look more like the web-based
##    map displays. For the latter we have to get viewport tracking
##    data out of the canvas::sqmap to move the item-group in sync
##    with scrolling, so that they appaear to stay in place.
##
## -- Add a filesystem based tile cache to speed up their loading. The
##    pure http access is slow (*) OTOH, this makes the workings of
##    sqmap more observable, as things do not happen as fast as for
##    puzzle and city. (*) The xy store generates some output so you
##    can see that something is happening.
##
## -- Yes, it is possible to use google maps as well. Spying on a
##    browser easily shows the urls needed. But, they are commercial,
##    and some of the servers (sat image data) want some auth cookie.
##    Without they deliver a few proper tiles and then return errors.
##
##    Hence this demo uses the freely available openstreetmap(.org)
##    data instead.
##
## -- Select two locations, then compute the geo distance between
##    them. Or, select a series of location, like following a road,
##    and compute the partial and total distances.

# ### ### ### ######### ######### #########
## Other requirements for this example.

package require Tk
package require widget::scrolledwindow
package require canvas::sqmap
package require crosshair
package require img::png

package require snit             ; # canvas::sqmap dependency
package require uevent::onidle   ; # ditto
package require cache::async 0.2 ; # ditto

# ### ### ### ######### ######### #########
## Pixels to geo coordinates, and back. Mercator projection.
## See http://wiki.openstreetmap.org/wiki/Slippy_map_tilenames#Pseudo-Code

proc Goto {lat lon} {
    global scrollw scrollh viewport tile
    # pixels in the scrollregion, then fraction

    set ty [lat2tile $lat]
    set tx [lon2tile $lon]

    set y [lat2pix $lat]
    set x [lon2pix $lon]

    set fy [expr {$y / $scrollh}]
    set fx [expr {$x / $scrollw}]
    # fraction of the scrollregion.

    # Now we need an offset as well, so that the position we got is in
    # the center, and not topleft. This offset is a half the size of
    # the view port in both directions, as fraction of the entire
    # region => We need viewport data out of the canvas. Which we have
    # through TRACK.

    foreach {l t r b} $viewport break
    set ofy [expr {$fy - ($b - $t)/2.0/$scrollh}]
    set ofx [expr {$fx - ($r - $l)/2.0/$scrollw}]

puts $lat\t$ty\t$y\t$fy\t$ofy
puts $lon\t$tx\t$x\t$fx\t$ofx

    .map xview moveto $ofx
    .map yview moveto $ofy
    return
}

set pi 3.1415926535

proc lat2pix {lat} {
    global tile
    return [expr {$tile * [lat2tile $lat]}]
}

proc lon2pix {lon} {
    global tile
    return [expr {$tile * [lon2tile $lon]}]
}

proc lat2tile {lat} {
    global pi tr ; # tr is 2^zoom = 2^12
    # lat in degrees.
    # 1/cos() == sec() in the referenced pseudo code.
    set lat [deg2rad $lat]
    return [expr { (1 - (log(tan($lat) + 1.0/cos($lat)) / $pi)) / 2 * $tr}]
}

proc lon2tile {lon} {
    global tc ; # tc is 2^zoom = 2^12
    return [expr {(($lon + 180.0) / 360.0) * $tc}]
}

proc pix2lat {y} {
    global pi scrollh
    return [rad2deg [expr {atan(sinh($pi * (1 - 2 * $y / $scrollh)))}]]
}

proc pix2lon {x} {
    global scrollw
    return [expr {$x / $scrollw * 360.0 - 180.0}]
}

proc deg2rad {d} {
    global pi
    return [expr {$d * $pi / 180.0}]
}

proc rad2deg {r} {
    global pi
    return [expr {$r * 180.0 / $pi}]
}

# ### ### ### ######### ######### #########

set location {}

proc GUI {} {
    global scrollw scrollh tc tr tile

    # ---------------------------------------------------------
    # OpenStreetMap, Zoom Level 12 (of 18). Mapnik rendered tiles.
    set zoom 12
    set url  http://tile.openstreetmap.org
    #set url  http://tah.openstreetmap.org/Tiles/tile

    tiles::xy::store::http TS $zoom $url/$zoom

    set tile     [TS tileheight] ; # assume quadratic cells.
    set tc       [TS columns]
    set tr       [TS rows]
    set scrollw  [expr {$tile * $tc}]
    set scrollh  [expr {$tile * $tr}]

    puts r/[TS rows]
    puts c/[TS columns]

    # ---------------------------------------------------------

    widget::scrolledwindow .sw
    canvas::sqmap          .map  -viewport-command VPTRACK
    button                 .exit -command exit     -text Exit
    button                 .ac   -command Aachen   -text {Show City of Aachen}
    button                 .grid -command ShowGrid -text {Show Grid}
    entry                  .loc  -textvariable location \
	-bd 2 -relief sunken -bg white -width 80

    .sw setwidget .map

    # Panning via mouse
    bind .map <ButtonPress-2> {%W scan mark   %x %y}
    bind .map <B2-Motion>     {%W scan dragto %x %y}

    # Cross hairs ...
    .map configure -cursor tcross
    crosshair::crosshair .map -width 0 -fill \#999999 -dash {.}
    crosshair::track on  .map TRACK

    if 1 {
	# This routes the requests and results through GOT/GET logging
	# commands.
	.map configure \
	    -grid-cell-command GET \
	    -grid-cell-width  $tile \
	    -grid-cell-height $tile \
	    -scrollregion [list 0 0 $scrollw $scrollh]
    } else {
	# This routes the requests directly to the grid provider, and
	# results back.
	.map configure \
	    -grid-cell-command TS \
	    -grid-cell-width  $tile \
	    -grid-cell-height $tile \
	    -scrollregion [list 0 0 $scrollw $scrollh]
    }

    pack .sw   -expand 1 -fill both -side bottom
    pack .exit -expand 0 -fill both -side left
    pack .ac   -expand 0 -fill both -side left
    pack .grid   -expand 0 -fill both -side left
    pack .loc  -expand 0 -fill both -side left

    return
}

proc ShowGrid {} {
    # Activating the grid leaks items = memory
    .map configure -grid-show-borders 1
    .map flush
    return
}

proc Aachen {} {
    # City of Aachen, NRW. Germany, Europe.
    Goto 50.7764185111 6.086769104
    return
}

# ### ### ### ######### ######### #########
# Basic callback structure, log for logging, facade to transform the
# cache/tiles result into what xcanvas is expecting.

proc GET {__ at donecmd} {
    puts "GET ($at) ($donecmd)"
    TS get $at [list GOT $donecmd]
    return
}

proc GOT {donecmd what at args} {
    puts "\tGOT $donecmd $what ($at) $args"
    if {[catch {
	uplevel #0 [eval [linsert $args 0 linsert $donecmd end $what $at]]
    }]} { puts $::errorInfo }
    return
}

# ### ### ### ######### ######### #########

proc TRACK {win x y args} {
    # args = viewport, pixels, see also canvas::sqmap, SetPixelView.
    global location

    # Convert pixels to geographic location.
    set lat [pix2lat $y]
    set lon [pix2lon $x]

    # Update entry field.
    set location "$lat, $lon"
    return
}

proc VPTRACK {xl yt xr yb} {
    # args = viewport, pixels, see also canvas::sqmap, SetPixelView.
    global viewport
    set viewport [list $xl $yt $xr $yb]
    return
}

# ### ### ### ######### ######### #########
## Basic interface.

GUI
# banff       lat = 51.1653,  lon = -115.5322
# lost lagoon lat = 49.30198, lon = -123.13724
