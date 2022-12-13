#!/bin/env tclsh8.6
# -*- tcl -*-
# # ## ### ##### ######## ############# #####################
# demo_map.tcl --
#
# This demonstration script shows a basic map.
# Tiles from OpenStreetMap, Mapnik.
# Plus layers - Togglable display of tracks, areas, boxes

# # ## ### ##### ######## ############# #####################
## Requirements

package require Tcl 8.6

# Extend the package search path so that this demonstration works with
# the non-installed tklib packages well. A regular application should
# not require this.

apply {{selfdir} {
    #puts ($selfdir)
    set ::sd $selfdir
    lappend ::auto_path $selfdir
    lappend ::auto_path [file normalize $selfdir/../../modules]
}} [file dirname [file normalize [info script]]]

package require Tk 8.6
package require map::display
package require map::provider::osm
#
package require map::track::map-display
package require map::track::store::fs
package require map::track::store::memory
#
package require map::area::map-display
package require map::area::store::fs
package require map::area::store::memory
#
package require map::box::map-display
package require map::box::store::fs
package require map::box::store::memory
#

## TODO :: notebook, panels for area/track/box tables
## TODO :: panel widget for notebook -> shift sizes of map vs tables
## TODO :: check boxes to enanle/disable the layers
## TODO :: look into stacking - outer areas/boxes can block inner such

# # ## ### ##### ######## ############# #####################

proc main {} {
    do $::env(HOME)/.cache/demo [cmdline]
    vwait __forever__
}

proc cmdline {} {
    global argv sd
    switch -exact -- [llength $argv] {
	0 { global sd ; return $sd/data }
	1 { return [lindex $argv 0] }
	default usage
    }
}

proc usage {} {
    global argv0
    puts stderr "Usage: $argv0 ?datadir?"
    exit 1
}

proc do {cachedir datadir} {
    file mkdir            $cachedir
    map provider osm TILE $cachedir

    wm withdraw .
    toplevel    .m
    wm title    .m "Map Display"
    wm iconname .m "MAP"

    # Layers ... Data sources

    map track store fs     TFS  $datadir
    map track store memory TMEM TFS
    map area store fs      AFS  $datadir
    map area store memory  AMEM AFS
    map box store fs       BFS  $datadir
    map box store memory   BMEM BFS

    # UI elements

    button .m.exit   -command ::exit -text Exit
    button .m.rehome -command rehome -text Home

    map display .m.map \
	-provider     TILE \
	-initial-geo  [home] \
	-initial-zoom [expr {[TILE levels]-1}]

    # Layers ... Display engines attaching to the map

    map track map-display TRACKS .m.map TMEM \
	-color       red \
	-hilit-color SkyBlue2 \
	;#-on-active   track-active-changed

    map area map-display AREAS .m.map AMEM \
	-color       red \
	-hilit-color SkyBlue2 \
	-line-config { -stipple gray12 -fill black } \
	;#-on-active   area-active-changed

    map box map-display BOXES .m.map BMEM \
	-color       red \
	-hilit-color SkyBlue2 \
	-rect-config { -stipple gray12 -fill black } \
	;#-on-active   box-active-changed

    # Show all ... TODO :: check boxes to selectively enable/disable layers
    AREAS  enable
    TRACKS enable
    BOXES enable

    # Layout

    grid rowconfigure    .m 0 -weight 1
    grid rowconfigure    .m 1 -weight 0

    grid columnconfigure .m 0 -weight 0
    grid columnconfigure .m 1 -weight 1
    grid columnconfigure .m 2 -weight 0
    grid columnconfigure .m 3 -weight 0

    grid .m.map    -row 0 -column 0 -columnspan 4 -sticky swen
    grid .m.exit   -row 1 -column 0               -sticky swen
    grid .m.rehome -row 1 -column 1               -sticky swn

    return
}

proc rehome {} { .m.map center [home] }
proc home   {} { return {51.667205 6.451442} } ;# Xanten Ampitheater/Coliseum

main
exit 0
