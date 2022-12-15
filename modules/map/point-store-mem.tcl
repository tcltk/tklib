## -*- tcl -*-
# # ## ### ##### ######## ############# ######################
## (c) 2022 Andreas Kupries

# @@ Meta Begin
# Package map::point::store::memory 0.1
# Meta author      {Andreas Kupries}
# Meta location    https://core.tcl.tk/tklib
# Meta platform    tcl
# Meta summary	   In-memory store for geo/point definitions
# Meta description In-memory store for geo/point definitions, with
# Meta description memoized calculation of extended attributes.
# Meta description Base data is taken from a backing store.
# Meta description Anything API-compatible to map::point::store::fs
# Meta subject	   {center, geo/point
# Meta subject	   {diameter, geo/point}
# Meta subject	   {geo/point pixels, zoom}
# Meta subject	   {geo/point, center}
# Meta subject	   {geo/point, diameter}
# Meta subject	   {geo/point, memory store}
# Meta subject	   {geo/point, perimeter length}
# Meta subject	   {length, geo/point, perimeter}
# Meta subject	   {memory store, geo/point}
# Meta subject	   {perimeter length, geo/point}
# Meta subject	   {pixels, zoom, geo/point}
# Meta subject	   {store, geo/point, memory}
# Meta subject	   {zoom, geo/point pixels}
# Meta require     {Tcl 8.6-}
# Meta require     debug
# Meta require     debug::caller
# Meta require     {map::slippy 0.8}
# Meta require     snit
# @@ Meta End

package provide map::point::store::memory 0.1

# # ## ### ##### ######## ############# ######################
## API
#
##  <class> OBJ backend-store
#
##  <obj> ids			-> list (id...)
##  <obj> get ID		-> dict (name, geo, kind)
##  <obj> visible GEOBOX ZOOM	-> list (id...)
##  <obj> pixels ID ZOOM	-> list (point...)
#
# # ## ### ##### ######## ############# ######################
## Requirements

package require Tcl 8.6
#
#                               ;# Tcllib
package require debug		;# - Narrative Tracing
package require debug::caller   ;#
package require map::slippy 0.8	;# - Map utilities
package require snit            ;# - OO system

# # ## ### ##### ######## ############# ######################
## Ensemble setup.

namespace eval map               { namespace export point  ; namespace ensemble create }
namespace eval map::point        { namespace export store  ; namespace ensemble create }
namespace eval map::point::store { namespace export memory ; namespace ensemble create }

debug level  tklib/map/point/store/memory
debug prefix tklib/map/point/store/memory {<[pid]> [debug caller] | }

# # ## ### ##### ######## ############# ######################

snit::type ::map::point::store::memory {
    # ..................................................................
    ## System configuration

    # . . .. ... ..... ........ ............. .....................
    ## State
    #
    # - Backing store, command prefix
    # - Pixel store     :: dict (id -> zoom -> point)
    # - Attribute store :: dict (id -> attr)
    #              attr :: dict ("names"    -> list (string...)
    #                            "geo"      -> geo
    #                            "kind"     -> string)

    variable mystore  {}
    variable myattr   {}
    variable mypixels {}

    # . . .. ... ..... ........ ............. .....................
    ## Lifecycle

    constructor {store} {
	debug.tklib/map/point/store/memory {}

	set mystore $store

	# TODO :: load all points from the underlying store and compute the clustering
	return
    }

    destructor {
	debug.tklib/map/point/store/memory {}
	return
    }

    # . . .. ... ..... ........ ............. .....................
    ## API

    delegate method * to mystore except get	;# ids, visible

    method get {id} {
	debug.tklib/map/point/store/memory {}

	if {![dict exists $myattr $id]} {
	    dict set myattr $id [$self Attributes $id]
	}
	return [dict get $myattr $id]
    }

    method pixels {id zoom} {
	debug.tklib/map/point/store/memory {}

	if {![dict exists $mypixels $id $zoom]} {
	    dict set mypixels $id $zoom [$self Pixels $zoom $id]
	}
	return [dict get $mypixels $id $zoom]
    }

    # TODO :: visible - take zoom into account - i.e. deliver clusters as necessary.

    # . . .. ... ..... ........ ............. .....................
    ## Helpers

    method Attributes {id} {
	set attr [DO get $id]
	set geo  [dict get $attr geo]
	set bbox [map slippy geo bbox $geo]

	dict set attr bbox $bbox

	#puts |$id|$attr|

	return $attr
    }

    method Pixels {zoom id} {
	debug.tklib/map/point/store/memory {}

	set attr  [DO get $id]
	set geo   [dict get $attr geo]
	set point [map slippy geo 2point $zoom $geo]

	return $point
    }

    proc DO {args} {
	debug.tklib/map/point/store/memory {}

	upvar 1 mystore mystore
	return [uplevel #0 [list {*}$mystore {*}$args]]
    }

    # . . .. ... ..... ........ ............. .....................
}

# # ## ### ##### ######## ############# ######################
return
