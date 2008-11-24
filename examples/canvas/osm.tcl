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

## Note: The editing of waypoints shows my inexperience with the
##       canvas. Adding points is with <1>, bound to the canvas
##       itself. Removing is with <3>, bound to the item
##       itself. However, often it doesn't work, or rather, only if a
##       add a new point X via <1> over the point of interest, and
##       then remove both X and the point of interest by using <3>
##       twice.
##
##	 Oh, and removal via <1> bound the item works not at all,
##	 because this triggers the global binding as well, re-adding
##	 the point immediately after its removal. Found no way of
##	 blocking that.
##
## Note: Currently new point can be added only at the end of the
##       trail. No insertion in the middle possible, although deletion
##       in the middle works. No moving points, yet.
##
## Note: This demo is reaching a size there it should be shifted to
##       tclapps for further development, and cleaned up, with many of
##       the messes encapsulated into snit types or other niceties,
##       separate packages, etc.

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

## == DONE == (roughly)
## -- Mark, save, load series of points (gps tracks, own tracks).
##    Name point series. Name individual points (location marks).

# ### ### ### ######### ######### #########
## Other requirements for this example.

package require Tk
package require widget::scrolledwindow
package require canvas::sqmap
package require crosshair
package require img::png
package require tooltip

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
    #puts $lat\t$ty\t$y\t$fy\t$ofy
    #puts $lon\t$tx\t$x\t$fx\t$ofx

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
    global argv cachedir loaddir
    set cachedir ""
    set loaddir [pwd]

    # Nothing to do if no cache is specified
    if {![llength $argv]} return

    # Fail for wrong#args
    if {[llength $argv] > 1} Usage

    set cachedir [lindex $argv 0]
    set loaddir  $cachedir
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
	#puts "OUT OF BOUNDS ($at)"
	after 0 [linsert $donecmd end unset $at]
	return
    }

    if {$cachedir ne ""} {
	#puts "\tCache? ($at) -: $cachedir"

	set tilefile [file join $cachedir $zoom $c $r.png]
	if {[file exists $tilefile]} {
	    #puts "\t\tYES, serve immediately"
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
    #puts "\tCacheExtend $z/ ($donecmd) $what ($at) $args"
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

global zoom
set    zoom -1

proc ZOOM {w level} {
    global zoom tile tc tr scrollw scrollh
    #puts Z=$level/$zoom

    set p [TS $level]

    # Set up the data for map config and lat/lon conversion.
    set tile     [$p tileheight] ; # assume quadratic cells.
    set tc       [$p columns]
    set tr       [$p rows]
    set scrollw  [expr {$tile * $tc}]
    set scrollh  [expr {$tile * $tr}]

    #puts r/$tr
    #puts c/$tc

    # Tell Cache/provider
    set zoom $level

    # Reload map tiles
    .map configure \
	-grid-cell-width  $tile \
	-grid-cell-height $tile \
	-scrollregion [list 0 0 $scrollw $scrollh]

    ShowPoints
    return
}

# ### ### ### ######### ######### #########

proc SavePoints {} {
    global loaddir

    set chosen [tk_getSaveFile -defaultextension .gps \
		    -filetypes {
			{GPS {.gps}}
			{ALL {*}}
		    } \
		    -initialdir $loaddir \
		    -title   {Save waypoints} \
		    -parent .map]

    if {$chosen eq ""} return

    global points
    set lines {}
    foreach p $points {
	foreach {lat lon comment} $p break
	lappend lines [list waypoint $lat $lon $comment]
    }

    fileutil::writeFile $chosen [join $lines \n]\n
    return
}

proc LoadPoints {} {
    global loaddir

    set chosen [tk_getOpenFile -defaultextension .gps \
		    -filetypes {
			{GPS {.gps}}
			{ALL {*}}
		    } \
		    -initialdir $loaddir \
		    -title   {Load waypoints} \
		    -parent .map]

    if {$chosen eq ""} return
    if {[catch {
	set waypoints [fileutil::cat $chosen]
    }]} {
	return
    }

    set loaddir [file dirname $chosen]

    ClearPoints
    # Content is TRUSTED. In a proper app this has to be isolated from
    # the main system through a safe interp.
    eval $waypoints
    ShowPoints
    return
}

proc waypoint {lat lon comment} {
    global  points
    lappend points [list $lat $lon $comment]
    return
}

proc ShowPoints {} {
    global points

    if {![llength $points]} return

    set cmds {}
    set cmd [list .map create line]

    foreach point $points {
	foreach {lat lon comment} $point break
	lappend cmd  [lon2pix $lon] [lat2pix $lat]
	lappend cmds [list POI $lat $lon $comment -fill salmon -tags Series]
    }
    lappend cmd -width 2 -tags Series -capstyle round ;#-smooth 1

    if {[llength $points] > 1} {
	set cmds [linsert $cmds 0 $cmd]
    }

    .map delete Series
    #puts [join $cmds \n]
    eval [join $cmds \n]
    return
}

global pcounter
set pcounter 0
proc RememberPoint {x y} {
    #puts REMEMBER///
    global pcounter
    incr   pcounter
    set lat [pix2lat [.map canvasy $y]]
    set lon [pix2lon [.map canvasx $x]]
    set comment "$pcounter:<$lat,$lon>"
    #puts $x/$y/$lat/$lon/$comment/$pcounter

    global  points
    lappend points [list $lat $lon $comment $pcounter]
    ShowPoints

    # This is handled weird. Placing the mouse on top of a point
    # doesn't trigger, however when I create a new point <1> at the
    # position, and then immediately after use <3> I can remove the
    # new point, and the second click the point underneath triggers as
    # well. Could this be a stacking issue?
    .map bind T/$comment <3> "[list ForgetPoint $pcounter];break"

    # Alternative: Bind <3> and the top level and use 'find
    # overlapping'. In that case however either we, or the sqmap
    # should filter out the background items.

    return
}

proc ForgetPoint {pid} {

    #    puts [.map find overlapping $x $y $x $y]
    #return

    #puts //FORGET//$pid

    global points
    set pos -1
    foreach p $points {
	incr pos
	foreach {lat lon comment id} $p break
	if {$id != $pid} continue
	#puts \tFound/$pos
	set points [lreplace $points $pos $pos]
	if {![llength $points]} {
	    ClearPoints
	} else {
	    ShowPoints
	}
	return
    }
    #puts Missed
    return
}

proc POI {lat lon comment args} {
    set x [lon2pix $lon]
    set y [lat2pix $lat]
    set x1 [expr { $x + 6 }]
    set y1 [expr { $y + 6 }]
    set x  [expr { $x - 6 }]
    set y  [expr { $y - 6 }]

    set id [eval [linsert $args 0 .map create oval $x $y $x1 $y1]]
    if {$comment eq ""} return
    tooltip::tooltip .map -item $id $comment
    .map addtag T/$comment withtag $id 
    return
}

proc ClearPoints {} {
    global points
    set points {}
    .map delete Series
    return
}

proc FindMarks {v} {
    upvar 1 $v file
    global cachedir loaddir selfdir
    set base locationmarks.gps

    foreach d [list $cachedir $loaddir [pwd] $selfdir] {
	set lm [file join $d $base]
	if {![file exists $lm]} continue
	set file $lm
	return 1
    }
    return 0
}

proc LoadMarks {} {
    if {![FindMarks lm]} return

    if {[catch {
	set waypoints [fileutil::cat $lm]
    }]} {
	return
    }

    ClearMarks
    # Content is TRUSTED. In a proper app this has to be isolated from
    # the main system through a safe interp.
    eval $waypoints
    ShowMarks
    return
}

proc ClearMarks {} {
    global lmarks locations
    set lmarks {}
    set locations {}
    return
}

proc poi {lat lon comment} {
    global lmarks locations
    lappend lmarks [list $lat $lon]
    lappend locations $comment
    return
}

proc ShowMarks {} {
    # locations traced by .lm
    return
}

proc GotoMark {} {
    global lmarks
    set sel [.lm curselection]
    if {![llength $sel]} return
    set sel [lindex $sel 0]
    set sel [lindex $lmarks $sel]
    foreach {lat lon} $sel break
    Goto $lat $lon
    return
}

# ### ### ### ######### ######### #########

set location  {} ; # geo location of the mouse in the canvas
set points    {} ; # way-points loaded list (list (lat lon comment))
set locations {} ; # Location markers (locationmark.gps)
set lmarks    {} ; #

proc GUI {} {
    global zoom
    set    zoom -1
    # ---------------------------------------------------------

    widget::scrolledwindow .sw
    canvas::sqmap          .map  -viewport-command VPTRACK -closeenough 3
    button                 .exit -command exit        -text Exit
    #button                 .ac   -command Aachen     -text {Show City of Aachen}
    button                 .goto  -command GotoMark   -text Goto
    button                 .clr  -command ClearPoints -text {Clear Points}
    button                 .ld   -command LoadPoints  -text {Load Points}
    button                 .sv   -command SavePoints  -text {Save Points}
    #button                 .grid -command ShowGrid    -text {Show Grid}
    entry                  .loc  -textvariable location \
	-bd 2 -relief sunken -bg white -width 60
    zoom .z -orient vertical -levels 19 -variable ::zoom -command ZOOM
    .sw setwidget .map

    widget::scrolledwindow .sl
    listbox .lm -listvariable ::locations -selectmode single
    .sl setwidget .lm

    # Panning via mouse
    bind .map <ButtonPress-2> {%W scan mark   %x %y}
    bind .map <B2-Motion>     {%W scan dragto %x %y}

    # Mark/unmark a point on the canvas
    bind .map <1> {RememberPoint %x %y}
    #bind .map <3> {ForgetPoint   %x %y}

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

    grid .sl   -row 1 -column 0 -sticky swen -columnspan 2
    grid .z    -row 1 -column 2 -sticky wen
    grid .sw   -row 1 -column 3 -sticky swen -columnspan 5

    #grid .ac   -row 0 -column 2 -sticky wen
    grid .exit -row 0 -column 0 -sticky wen
    grid .goto -row 0 -column 1 -sticky wen
    grid .clr  -row 0 -column 3 -sticky wen
    grid .ld   -row 0 -column 4 -sticky wen
    grid .sv   -row 0 -column 5 -sticky wen
    #grid .grid -row 0 -column 5 -sticky wen
    grid .loc  -row 0 -column 6 -sticky wen

    grid rowconfigure . 0 -weight 0
    grid rowconfigure . 1 -weight 1

    grid columnconfigure . 0 -weight 0
    grid columnconfigure . 1 -weight 0
    grid columnconfigure . 2 -weight 0
    grid columnconfigure . 3 -weight 0
    grid columnconfigure . 7 -weight 1

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
LoadMarks
after 1000 {
    ZOOM . 12
    after 10 Aachen
}
