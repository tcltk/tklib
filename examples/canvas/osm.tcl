#!/bin/sh
# -*- tcl -*- \
exec tclsh "$0" ${1+"$@"}
# ### ### ### ######### ######### #########

## DEMO. Uses openstreetmap to show a tile-based world map.

## Call without arguments for a plain web-served map.
## Call with single argument (dir path) to use a tile cache.

## Syntax: osm ?cachedir?

## -- Note: The cache may not exist, it is automatically filled and/or
##    extended from the web-served data. This cache can grow very
##    large very quickly (I have currently seen ranging in size from
##    4K (water) to 124K (dense urban area)).

# ### ### ### ######### ######### #########
## Use canvas package relative to example location.

set selfdir  [file dirname [file normalize [info script]]]
set modules [file join [file dirname [file dirname $selfdir]] modules]

source $modules/canvas/canvas_sqmap.tcl ; # The main map support
source $selfdir/tiles_xy_store_http.tcl ; # Retrieving tiles from the web
source $selfdir/osm_zoom.tcl            ; # Simple zoom-control (button based)

## Ideas:
## == DONE ==
## -- Add zoom-control to switch between zoom levels. This has to
##    adjust the scroll-region as well. The control can be something
##    using basic Tk widgets (scale, button), or maybe some constructed
##    from canvas items, to make the map look more like the web-based
##    map displays. For the latter we have to get viewport tracking
##    data out of the canvas::sqmap to move the item-group in sync
##    with scrolling, so that they appaear to stay in place.
##
## == DONE ==
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

## -- Mark, save, load series of points (gps tracks, own tracks).
##    Name point series. Name individual points (location marks).

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

    # Show lat/lon, tile coord, pix coord, region fractionals
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

proc TS {level} {
    global ts
    if {![info exists ts($level)]} {
	# Core tile provider, http to openstreetmap tile server.
	# ---------------------------------------------------------
	# OpenStreetMap. Mapnik rendered tiles.

	set url  http://tile.openstreetmap.org
	#set url  http://tah.openstreetmap.org/Tiles/tile
	set ts($level) [tiles::xy::store::http TS/$level $level $url/$level]
    }
    return $ts($level)
}

proc Init {} {
    global argv cachedir
    set cachedir ""

    # Nothing to do if no cache is specified
    if {![llength $argv]} return

    # Fail for wrong#args
    if {[llength $argv] > 1} Usage

    set cachedir [lindex $argv 0]
    return
}

proc Usage {} {
    global argv0
    puts stderr "wrong\#args, expected: $argv0 ?cachedir?"
    exit 1
}

# ### ### ### ######### ######### #########
## Manage a filesystem cache of tiles.

## AK FUTURE: Put this into a generalized snit::type, i.e. for all
## types of keys, like with cache::async. Then we can simply chain
## objects to set everything up.

proc Cache {__ at donecmd} {
    global zoom cachedir tc tr

    foreach {r c} $at break

    if {
	($r < 0) ||
	($r >= $tr) ||
	($c < 0) ||
	($c >= $tc)
    } {
	puts "OUT OF BOUNDS ($at)"
	after 0 [linsert $donecmd end unset $at]
	return
    }

    if {$cachedir ne ""} {
	puts "\tCache? ($at) -: $cachedir"

	set tilefile [file join $cachedir $zoom $c $r.png]
	if {[file exists $tilefile]} {
	    puts "\t\tYES, serve immediately"
	    set tile [image create photo -file $tilefile]
	    after 0 [linsert $donecmd end set $at $tile]
	    return
	}
    }

    # Not in the cache, or no cache. Invoke the original provider and
    # route results back to us so that we can extend the cache.

    [TS $zoom] get $at [list CacheExtend $zoom $donecmd]
    return
}

proc CacheExtend {z donecmd what at args} {
    # note: z = zoom, at the time the request was made. In case the
    # zoom level was changed by the user between start of the request
    # and return of the result form the server.
    global cachedir
    puts "\tCacheExtend $z/ ($donecmd) $what ($at) $args"
    if {$what eq "set"} {
	# Enter the newly retrieved tile into the local cache
	foreach {r c} $at break
	set tile     [lindex $args 0]
	set tilefile [file join $cachedir $z $c $r.png]
	file mkdir [file dirname $tilefile]
	$tile write $tilefile -format png
    }
    if {[catch {
	uplevel #0 [eval [linsert $args 0 linsert $donecmd end $what $at]]
    }]} { puts $::errorInfo }
    return
}

proc ZOOM {w level} {
    global zoom tile tc tr scrollw scrollh
    puts Z=$level

    set p [TS $level]

    # Set up the data for map config and lat/lon conversion.
    set tile     [$p tileheight] ; # assume quadratic cells.
    set tc       [$p columns]
    set tr       [$p rows]
    set scrollw  [expr {$tile * $tc}]
    set scrollh  [expr {$tile * $tr}]

    puts r/$tr
    puts c/$tc

    # Tell Cache/provider
    set zoom $level

    # Reload map tiles
    .map configure \
	-grid-cell-width  $tile \
	-grid-cell-height $tile \
	-scrollregion [list 0 0 $scrollw $scrollh]
    return
}

# ### ### ### ######### ######### #########

set location {}

proc GUI {} {
    # ---------------------------------------------------------

    widget::scrolledwindow .sw
    canvas::sqmap          .map  -viewport-command VPTRACK
    button                 .exit -command exit     -text Exit
    button                 .ac   -command Aachen   -text {Show City of Aachen}
    button                 .grid -command ShowGrid -text {Show Grid}
    entry                  .loc  -textvariable location \
	-bd 2 -relief sunken -bg white -width 80
    zoom .z -orient vertical -levels 19 -variable ::zoom -command ZOOM
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
	.map configure -grid-cell-command GET
    } else {
	# This routes the requests directly to the grid provider, and
	# results back.
	.map configure -grid-cell-command Cache
    }

    grid .z    -row 1 -column 0 -sticky wen
    grid .sw   -row 1 -column 1 -sticky swen -columnspan 4
    grid .exit -row 0 -column 1 -sticky wen
    grid .ac   -row 0 -column 2 -sticky wen
    grid .grid -row 0 -column 3 -sticky wen
    grid .loc  -row 0 -column 4 -sticky wen

    grid rowconfigure . 0 -weight 0
    grid rowconfigure . 1 -weight 1

    grid columnconfigure . 0 -weight 0
    grid columnconfigure . 1 -weight 0
    grid columnconfigure . 2 -weight 0
    grid columnconfigure . 3 -weight 0
    grid columnconfigure . 4 -weight 1

    ZOOM . 0
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
    Cache get $at [list GOT $donecmd]
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

Init
GUI
# banff       lat = 51.1653,  lon = -115.5322
# lost lagoon lat = 49.30198, lon = -123.13724
after 1000 {ZOOM . 12 ; after 10 Aachen}
